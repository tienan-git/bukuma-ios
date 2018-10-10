//
//  Transaction.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/06.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

private let transactionCreatedAt: String = "transactionCreatedAt"
let TransactionRefreshKey: String = "TransactionRefreshKey"

public enum TransactionListType : Int{
    case initial = 0
    case sellerPrepareShipping = 1
    case sellerShipped = 2
    case buyerItemArried = 3
    case sellerReviewBuyer = 4
    case finishedTransaction = 5
    case pendingReviewByStuff = 6  // only when Bukuma staff needs to review the order
    case cancelled = 7
    case unknown
    
    mutating func typeFromParameter(_ string: String?) {
        if string == nil {
            return
        }
        switch string! {
        case "initial":
            self = .initial
            break
        case "seller_prepare":
            self = .sellerPrepareShipping
            break
        case "seller_shipped":
            self = .sellerShipped
            break
        case "buyer_item_arrived":
            self = .buyerItemArried
            break
        case "seller_review_buyer":
            self = .sellerReviewBuyer
            break
        case "finished":
            self = .finishedTransaction
            break
        case "pending_review":
            self = .pendingReviewByStuff
            break
        case "cancelled":
            self = .cancelled
        default:
            self = .unknown
            break
        }
    }
    
    mutating func typeFromInt(_ int: Int?) {
        if int == nil {
            return
        }
        switch int! {
        case 0:
            self = .initial
            break
        case 1:
            self = .sellerPrepareShipping
            break
        case 2:
            self = .sellerShipped
            break
        case 3:
            self = .buyerItemArried
            break
        case 4:
            self = .sellerReviewBuyer
            break
        case 5:
            self = .finishedTransaction
            break
        case 6:
            self = .pendingReviewByStuff
            break
        case 7:
            self = .cancelled
        default:
            self = .unknown
            break
        }
    }
}

//item transaction
open class Transaction: BaseModelObject {
    var id: String?
    var date: NSDate?
    var updatedAt: NSDate?
    var status: String?
    var remark: String?
    var user: User?
    var boughtBy: User?
    var actionAxpireAt: Int?
    var type: TransactionListType?
    var merchandise: Merchandise?
    var book: Book?
    var buyerAdress: Adress?
    var seller: User?
    var contactId: String?
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {        
        id = attributes?["id"].map{String(describing: $0)}
        attributes?["updated_at"].map{String(describing: $0)}.flatMap{Int($0)}.flatMap{Double($0)}.map{updatedAt = NSDate(timeIntervalSince1970: $0)}
        attributes?["created_at"].map{String(describing: $0)}.flatMap{Int($0)}.flatMap{Double($0)}.map{date = NSDate(timeIntervalSince1970: $0)}

        type = TransactionListType(rawValue: 0)
        type?.typeFromParameter(attributes?["status"].map{String(describing: $0)})
        user = User(dictionary: attributes?["user"] as? [String: AnyObject])
        seller = User(dictionary: attributes?["seller"] as? [String: AnyObject])
        boughtBy = User(dictionary: attributes?["merchandise"]?["bought_by"] as? [String: AnyObject])
        buyerAdress = Adress(dictionary: attributes?["user_address"] as? [String: AnyObject])
        merchandise = Merchandise(dictionary: attributes?["merchandise"] as? [String: AnyObject])
        book = Book.generatedBookFromStore(attributes?["merchandise"]?["book"] as? [String: AnyObject])
        
        contactId = attributes?["unique_id"].map{String(describing: $0)}
        
        self.savePurchaseDay()
    }
    
    open class func transaction(_ attributes: [String: AnyObject]?, update: Bool) ->Transaction? {
        let identifier: String? = attributes?["id"].map{ String(describing: $0) }
        if identifier?.isEmpty == true || identifier == nil {
            return nil
        }
        
        var transaction: Transaction? = TransactionStore.shared.storedTransaction(identifier ?? "-1")
        
        if transaction == nil {
            transaction = Transaction(dictionary: attributes)
            TransactionStore.shared.storeTransaction(transaction ?? Transaction())
            
        } else {
            if update == true {
                transaction?.updatePropertyWithAttributes(attributes)
            }
        }
        return transaction
    }
    
    open class func generatedTransactionFromStore(_ attributes: [String: AnyObject]?) ->Transaction? {
        return self.transaction(attributes, update: true)
    }
    
    open func isBuyer() ->Bool? {
        return boughtBy?.identifier == Me.sharedMe.identifier
    }
    
    open func oppositeUser() ->User? {
        if user == nil || seller == nil || boughtBy == nil || user?.identifier == nil || seller?.identifier == nil || boughtBy?.identifier == nil {
            return nil
        }
        
        if user?.identifier != Me.sharedMe.identifier {
            return user!
        }
        
        if boughtBy?.identifier != Me.sharedMe.identifier {
            return boughtBy!
        }
        
        if seller?.identifier != Me.sharedMe.identifier {
            return seller!
        }
        return nil
    }
    
    open func bookTitle() ->String {
        return merchandise?.book?.titleText() ?? ""
    }
    
    open func buyerName() ->String {
        if boughtBy?.nickName != nil {
            return boughtBy!.nickName!
        }
        return "退会したユーザー"
    }
    
    func shouldShowCancelFlow() ->Bool {
        let gap: Int = self.date?.daysAfterDate(date: NSDate()) ?? -999
        
        return -gap >= 9 && self.type == TransactionListType.sellerPrepareShipping && boughtBy?.identifier == Me.sharedMe.identifier
    }
    
    func savePurchaseDay() {
        let key: String = transactionCreatedAt + (id ?? "0")
        UserDefaults.standard.set(date, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    open class func getTransactionFromMerchandiseId(_ merId: String,completion: @escaping (_ transaction: Transaction?) ->Void) {
        let transaction: Transaction? = self.searchTransactionFromId(merId)
        
        if transaction != nil {
            completion(transaction)
            return
        }
        
        self.getItemTransactionList(50, page: 0) { (transactions, error) in
            let transaction: Transaction? = transactions?.filter({ (t) -> Bool in
                return t.merchandise?.id == merId
            }).first
            completion(transaction)
        }
    }
    
    open class func getTransactionFromBookId(_ bookId: String,completion: @escaping (_ transaction: Transaction?) ->Void) {
        self.getItemTransactionList(50, page: 0) { (transactions, error) in
            let transaction: Transaction? = transactions?.filter({ (t) -> Bool in
                return t.book?.identifier == bookId
            }).first ?? nil
            completion(transaction)
        }
    }

    open class func getItemTransactionList(_ number: Int, page: Int, completion:((_ transactions: [Transaction]?, _ error: Error?) ->Void)?) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = number
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/item_transactions",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)

                                        guard let items = responceObject!["item_transactions"] else {
                                            JSONCache.cacheArray([], key: TransactionsListCacheKey)
                                            completion?(nil, nil)
                                            return
                                        }

                                        let jsonArray = SwiftyJSON.JSON(items).arrayObject!
                                        JSONCache.cacheArray(jsonArray, key: TransactionsListCacheKey)

                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TransactionRefreshKey), object: self)
                                                                                
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let transactions: [Transaction] = jsonDic.map({ (dic) in
                                            let transaction: Transaction? = self.generatedTransactionFromStore(dic)
                                            return transaction!
                                        })
                                        
                                        completion?(transactions, nil)
                                
                                    } else {
                                        
                                        DBLog(error)
                                        completion?(nil, error)
                                    }
        }
    }
    
    open class func getBoughtItemTransactionList(_ page: Int, completion:@escaping (_ transactions: [Transaction]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/item_transactions/myself",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        if responceObject!["item_transactions"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["item_transactions"]!).arrayObject!
                                        JSONCache.cacheArray(jsonArray, key: BoughtTransactionsListCacheKey)
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let transactions: [Transaction] = jsonDic.map({ (dic) in
                                            let transaction: Transaction? = self.generatedTransactionFromStore(dic)
                                            return transaction!
                                        })
                                        completion(transactions, nil)
                                    } else {
                                        
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    open class func getSoldItemTransactionList(_ page: Int, completion:@escaping (_ transactions: [Transaction]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/item_transactions/selling",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        if responceObject!["item_transactions"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["item_transactions"]!).arrayObject!
                                        JSONCache.cacheArray(jsonArray, key: SoldTransactionsListCacheKey)
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let transactions: [Transaction] = jsonDic.map({ (dic) in
                                            let transaction: Transaction? = self.generatedTransactionFromStore(dic)
                                            return transaction!
                                        })
                                        completion(transactions, nil)
                                    } else {
                                        
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }

    open func getItemTransactionInfo(_ completion: @escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/item_transactions/\(self.idString(id))",
                                   parameters: [:]) { (responceObject, error) in
                                    if error == nil {
                                        
                                        DBLog(responceObject)
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["item_transactions"]!).arrayObject!
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        _ = jsonDic.map({ (dic) in
                                        self.updatePropertyWithAttributes(dic)
                                        })
                                        
                                        completion(nil)
                                    } else {
                                        DBLog(error)
                                        completion(error)
                                    }
        }
    }
    
    open class func getItemTransactionInfoFromId(_ transactionId: String, completion: @escaping (_ transaction: Transaction?, _ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/item_transactions/\(transactionId)",
                                   parameters: [:]) { (responceObject, error) in
                                    if error == nil {
                                        
                                        DBLog(responceObject)
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["item_transactions"]!).arrayObject!
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        var transaction: Transaction?
                                        _ = jsonDic.map({ (dic) in
                                             transaction = self.generatedTransactionFromStore(dic)
                                        })
                                        completion(transaction, nil)
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    open func sellerShipped(_ completion: @escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.POST("v1/item_transactions/\(self.idString(id))/shipped",
                                    parameters: [:]) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                            self.getItemTransactionInfo(completion)
                                            
                                            let parameter: [String: AnyObject] = ["item_transaction_id": self.id as AnyObject]
                                            
                                            AnaliticsManager.sendAction("item_transaction_states",
                                                                        actionName: "item_transaction_shipped",
                                                                        label: "",
                                                                        value: 1,
                                                                        dic: parameter)
                                            
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    
    open func buyerBookArrived(_ review: Review, completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["comment"] = review.comment
        params["mood"] = review.type?.rawValue
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/item_transactions/\(self.idString(id))/arrived",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            self.getItemTransactionInfo(completion)
                                        
                                            let parameter: [String: AnyObject] = ["item_transaction_id": self.id as AnyObject]
                                            
                                            AnaliticsManager.sendAction("item_transaction_states",
                                                                        actionName: "item_transaction_arrived",
                                                                        label: "",
                                                                        value: 1,
                                                                        dic: parameter)
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    
    open func sellerReviewsBuyer(_ review: Review, completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["comment"] = review.comment
        params["mood"] = review.type?.rawValue 
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/item_transactions/\(self.idString(id))/review_buyer",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            self.getItemTransactionInfo(completion)
                                            
                                            let parameter: [String: AnyObject] = ["item_transaction_id": self.id as AnyObject]
                                            
                                            AnaliticsManager.sendAction("item_transaction_states",
                                                                        actionName: "item_transaction_finish",
                                                                        label: "",
                                                                        value: 1,
                                                                        dic: parameter)
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    
    public func cancel(completion: @escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.POST("v1/item_transactions/\(self.idString(id))/cancel",
                                    parameters: [:]) { [weak self] (responceObject, error) in
                                        DBLog(responceObject)

                                        if error == nil {
                                            self?.getItemTransactionInfo(completion)

                                            let parameter: [String: AnyObject] = ["item_transaction_id": self?.id as AnyObject]
                                            AnaliticsManager.sendAction("item_transaction_states",
                                                                        actionName: "item_transaction_cancel",
                                                                        label: "",
                                                                        value: 1,
                                                                        dic: parameter)
                                        } else {
                                            completion(error)
                                        }

        }
    }
    
    open class func searchTransactionFromId(_ merchandiseId: String?) ->Transaction? {
        if Utility.isEmpty(merchandiseId) {
            return nil
        }
        
        let cacheList: [Transaction]? = self.cachedItemTransaction()
        
        let transaction: Transaction? = cacheList?.filter({ (transaction) -> Bool in
            return transaction.merchandise?.id == merchandiseId
        }).first
        return transaction
    }
    
    open class func searchTransactionFromUserId(_ userId: String?) ->Transaction? {
        if Utility.isEmpty(userId) {
            return nil
        }
        
        let cacheList: [Transaction]? = self.cachedItemTransaction()
        
        let transaction: Transaction? = cacheList?.filter({ (transaction) -> Bool in
            return (transaction.boughtBy?.identifier == userId || transaction.seller?.identifier == userId)
        }).first
        return transaction
    }
    
    open class func cachedItemTransaction() ->[Transaction]? {
        let cacheList: [Any]? = JSONCache.cachedArrayListWithKey(TransactionsListCacheKey)
        if cacheList == nil || cacheList?.isEmpty == true {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [Transaction] = modelDic.map({ (dic) in
            let model = Transaction.generatedTransactionFromStore(dic)
            return model!
        })
        return models
    }
    
    open class func cachedBoughtItemTransaction() ->[Transaction]? {
        let cacheList: [Any]? = JSONCache.cachedArrayListWithKey(BoughtTransactionsListCacheKey)
        if cacheList == nil {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [Transaction] = modelDic.map({ (dic) in
            let model = Transaction.generatedTransactionFromStore(dic)
            return model!
        })
        return models
    }
    
    open class func cachedSoldItemTransaction() ->[Transaction]? {
        let cacheList: [Any]? = JSONCache.cachedArrayListWithKey(SoldTransactionsListCacheKey)
        if cacheList == nil {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [Transaction] = modelDic.map({ (dic) in
            let model = Transaction.generatedTransactionFromStore(dic)
            return model!
        })
        return models
    }
}

extension Transaction {
    var daysSinceFinished: Int {
        get {
            guard let status = self.type else { return 0 }
            guard status == .finishedTransaction else { return 0 }

            guard let resultDate = self.updatedAt else { return 0 }
            let now = Date()

            let components = Calendar.current.dateComponents([.day], from: resultDate as Date, to: now)
            return components.day!
        }
    }
}
