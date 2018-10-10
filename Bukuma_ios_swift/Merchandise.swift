//
//  Merchandise.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

protocol ShippingConstantsProtocol {
    static var shippingWays: [String] { get }
    static var shippingDaysRanges: [String] { get }
    static var shippingDaysRangesLong: [String] { get }
    static var shippingDays: [Int] { get }
    static var bookStatuses: [String] { get }

    static func shippingWay(by shippingWayIndex: Int)-> String
    static func shippingDaysRange(by shippingDaysRangeIndex: Int)-> String
    static func shippingDaysRangeLong(by shippingDaysRangeIndex: Int)-> String
    static func shippingDay(by shippingDayIndex: Int)-> Int
    static func bookStatus(by bookStatusIndex: Int)-> String

    func shippingSummary(longFormat longDaysRange: Bool)-> (planeString: String, boldRanges: [NSRange], regularRanges: [NSRange])
}

extension ShippingConstantsProtocol {
    static var shippingWays: [String] { get {
        return ["ゆうパック", "ゆうメール", "定形・定形外郵便", "クリックポスト", "レターパック", "スマートレター", "ゆうパケット", "その他／未定"]
        }}
    static var shippingDaysRanges: [String] { get {
        return ["1〜3日", "4〜6日", "7〜9日"]
        }}
    static var shippingDaysRangesLong: [String] { get {
        return ["1日 ~ 3日", "4日 ~ 6日", "7日 ~ 9日"]
        }}
    static var shippingDays: [Int] { get {
        return [3, 6, 9]
        }}
    static var bookStatuses: [String] { get {
        return ["とても良い", "良い", "可", "難あり"]
        }}

    static func shippingWay(by shippingWayIndex: Int)-> String {
        if 0..<self.shippingWays.count ~= shippingWayIndex {
            return self.shippingWays[shippingWayIndex]
        } else {
            return ""
        }
    }

    static func shippingDaysRange(by shippingDaysRangeIndex: Int)-> String {
        if 0..<self.shippingDaysRanges.count ~= shippingDaysRangeIndex {
            return self.shippingDaysRanges[shippingDaysRangeIndex]
        } else {
            return self.shippingDaysRanges[0]
        }
    }

    static func shippingDaysRangeLong(by shippingDaysRangeIndex: Int)-> String {
        if 0..<self.shippingDaysRangesLong.count ~= shippingDaysRangeIndex {
            return self.shippingDaysRangesLong[shippingDaysRangeIndex]
        } else {
            return self.shippingDaysRangesLong[0]
        }
    }

    static func shippingDay(by shippingDayIndex: Int)-> Int {
        if 0..<self.shippingDays.count ~= shippingDayIndex {
            return self.shippingDays[shippingDayIndex]
        } else {
            return self.shippingDays[0]
        }
    }

    static func bookStatus(by bookStatusIndex: Int)-> String {
        if 0..<self.bookStatuses.count ~= bookStatusIndex {
            return self.bookStatuses[bookStatusIndex]
        } else {
            return "なし"
        }
    }
}

/**
 Merchandise Object
*/

open class Merchandise: BaseModelObject {
    var id: String? ///id
    var price: String? ///値段
    var quality: Int? ///状態
    var comment: String? ///コメント
    var shipFrom: String? ///発送元
    var shipInDay: Int? ///発送予定日
    var shipWay: Int? ///発送方法
    var bookId: String? ///紐づいている本のID
    var active: Bool? ///もしfalseだったら下書きになるように。ただ、現状下書きの機能はない
    var isSeries: Bool? ///まとめ売りか否か
    var seriesDespription: String? ///まとめ売りのタイトル
    var photos: [Photo]? ///まとめ売りの時の写真
    var photo: Photo?
    var photo2: Photo?
    var photo3: Photo?
    var user: User? = User() ///出品者
    var users: [User]?
    var book: Book? = Book()
    var boughtBy: User? ///購入者
    var isSold: Bool? ///売れたかどうか
    var isBrandNew: Bool? /// 新刊かどうか
    var updatedAt: Date? ///更新したかどうか
    var createdAt: Date?
    
    static var shippingFromContents: [String] = Adress.prefectures
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        guard let attributes = attributes else { return }

        id = attributes["id"].map{String(describing: $0)}
        var p: String? = attributes["price"].map{String(describing: $0)}
        price = p?.floorString()
        quality = attributes["quality"] as? Int
        comment = attributes["description"].map{String(describing: $0)}
        shipFrom = attributes["ship_from"].map{String(describing: $0)}
        shipInDay = attributes["ship_in"] as? Int
        shipWay = attributes["shipping_method"] as? Int
        active = attributes["active"] as? Bool
        seriesDespription = attributes["series_description"].map{String(describing: $0)}
        user = User(dictionary: attributes["user"] as? [String: AnyObject])
        boughtBy = User(dictionary: attributes["bought_by"] as? [String: AnyObject])
        attributes["updated_at"].map{String(describing: $0)}.flatMap{Int($0)}.flatMap{Double($0)}.map{updatedAt = Date(timeIntervalSince1970: $0)}
        attributes["created_at"].map{String(describing: $0)}.flatMap{Int($0)}.flatMap{Double($0)}.map{createdAt = Date(timeIntervalSince1970: $0)}
        users = user.map { (u) in
            return [u]
        }
        
        book = Book.generatedBookFromStore(attributes["book"] as? [String: AnyObject])
        
        photos = Array()
        
        (attributes["image"]?["image"] as? [String: Any])?["url"].map({ (t) in
            photo = Photo(imageUrl: URL(string: String(describing: t)))
            if Utility.isEmpty(photo?.imageURL) == false {
                photos?.append(photo!)
            }
        })
        
        (attributes["image_2"]?["image_2"] as? [String: Any])?["url"].map({ (t) in
            photo2 = Photo(imageUrl: URL(string: String(describing: t)))
            if Utility.isEmpty(photo2?.imageURL) == false {
                photos?.append(photo2!)
            }
        })
        
        (attributes["image_3"]?["image_3"] as? [String: Any])?["url"].map({ (t) in
            photo3 = Photo(imageUrl: URL(string: String(describing: t)))
            if Utility.isEmpty(photo3?.imageURL) == false {
                photos?.append(photo3!)
            }
        })
        
        
        isSold = Utility.isEmpty(attributes["sold_at"]) == false && attributes["sold_at"].map{String(describing: $0)} != 0.string()
        isBrandNew = attributes["is_brand_new"] as? Bool
    }

    open class func createLowestMerchandise(_ attributes: [String : AnyObject]?) ->Merchandise? {
        let merchandise = Merchandise()
        merchandise.id = attributes?["id"].map{String(describing: $0)}
        var p: String? = attributes?["price"].map{String(describing: $0)}
        merchandise.price = p?.floorString()
        merchandise.quality = attributes?["quality"] as? Int
        merchandise.comment = attributes?["description"].map{String(describing: $0)}
        merchandise.shipFrom = attributes?["ship_from"].map{String(describing: $0)}
        merchandise.shipInDay = attributes?["ship_in"] as? Int
        merchandise.shipWay = attributes?["shipping_method"] as? Int
        merchandise.active = attributes?["active"] as? Bool
        merchandise.seriesDespription = attributes?["series_description"].map{String(describing: $0)}
        merchandise.user = User(dictionary: attributes?["user"] as? [String: AnyObject])
        merchandise.boughtBy = User(dictionary: attributes?["bought_by"] as? [String: AnyObject])
        
        merchandise.photos = Array()
        
        (attributes?["image"]?["image"] as? [String: Any])?["url"].map({ (t) in
            merchandise.photo = Photo(imageUrl: URL(string: String(describing: t)))
            if Utility.isEmpty(merchandise.photo?.imageURL) == false {
                merchandise.photos?.append(merchandise.photo!)
            }
        })
        
        (attributes?["image_2"]?["image_2"] as? [String: Any])?["url"].map({ (t) in
            merchandise.photo2 = Photo(imageUrl: URL(string: String(describing: t)))
            if Utility.isEmpty(merchandise.photo2?.imageURL) == false {
                merchandise.photos?.append(merchandise.photo2!)
            }
        })
        
        (attributes?["image_3"]?["image_3"] as? [String: Any])?["url"].map({ (t) in
            merchandise.photo3 = Photo(imageUrl: URL(string: String(describing: t)))
            if Utility.isEmpty(merchandise.photo3?.imageURL) == false {
                merchandise.photos?.append(merchandise.photo3!)
            }
        })
        
        merchandise.isSold = Utility.isEmpty(attributes?["sold_at"]) == false && attributes?["sold_at"].map{String(describing: $0)} != 0.string()
        merchandise.isBrandNew = attributes?["is_brand_new"] as? Bool
        
        return merchandise
    }
    
    open func isAleadyBought() ->Bool {
        return !Utility.isEmpty(boughtBy?.identifier)
    }
    
    open func statusString() ->String {
        guard let statusIndex = self.quality else {
            return "なし"
        }
        return Merchandise.bookStatus(by: statusIndex)
    }
    
    open func shippingWayString() ->String {
        guard let shipWay = self.shipWay else {
            return ""
        }
        return Merchandise.shippingWay(by: shipWay)
    }

    open func shippingInfoAttribute() ->NSAttributedString? {
        //resucutive
        guard let ship = shipInDay  else {
            return NSAttributedString()
        }
        if ship >= Merchandise.shippingDaysRangesLong.count {
            shipInDay = Merchandise.shippingDaysRangesLong.count - 1
        }

        let summary = self.shippingSummary(longFormat: true)
        let shippingString = NSMutableAttributedString(string: summary.planeString)

        for range in summary.boldRanges {
            shippingString.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)], range: range)
        }
        for range in summary.regularRanges {
            shippingString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14)], range: range)
        }

        return shippingString
    }
    
    ///Merchandise作る
    open class func createMerchandise(_ merchandise: Merchandise, completion:@escaping (_ merch: Merchandise?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["book_id"] = merchandise.bookId ?? ""
        params["price"] = merchandise.price!.replaceYenSign()
        params["quality"] = merchandise.quality ?? 0
        params["description"] = merchandise.comment ?? ""
        params["ship_from"] = merchandise.shipFrom ?? shippingFromContents[0]
        params["ship_in"] = merchandise.shipInDay ?? self.shippingDaysRangesLong[0]
        params["shipping_method"] = merchandise.shipWay ?? self.shippingWays[0]
        params["is_series"] = merchandise.isSeries == true ? 1 : 0
        
        if merchandise.isSeries == true {
            params["series_description"] = merchandise.seriesDespription ?? ""
        }
        
        var images: [(name: String, fileName: String, image: UIImage)]? = []
        if merchandise.photo != nil {
            images?.append((name:"image",fileName:"image.jpg",image:merchandise.photo!.image!))
        }
        
        if merchandise.photo2 != nil {
            images?.append((name:"image_2",fileName:"image_2.jpg",image:merchandise.photo2!.image!))
        }
        
        if merchandise.photo3 != nil {
            images?.append((name:"image_3",fileName:"image_3.jpg",image:merchandise.photo3!.image!))
        }
        
        DBLog(params)
                
        ApiClient.sharedClient.POST("v1/merchandises/create",
                                    parameters: params,
                                    iconImages: images) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                        
                                            let merchandise = Merchandise(dictionary: responceObject?["merchandise"] as? [String: AnyObject])
                                            
                                            AnaliticsManager.sendAction("create_merchandise",
                                                                        actionName: "create_merchandise",
                                                                        label: "",
                                                                        value: 1,
                                                                        dic: ["merchandise_id": merchandise.id as AnyObject,
                                                                              "book_category": merchandise.book?.categoryName as AnyObject,
                                                                              "merchandise_price": merchandise.price as AnyObject,
                                                                              "merchandise_createdAt":  merchandise.updatedAt?.dateString(in: DateFormatter.Style.short) as AnyObject,
                                                                              "merchandise_ship_from": merchandise.shipFrom as AnyObject,
                                                                              "merchandise_ship_way": merchandise.shippingWayString() as AnyObject])
                                            completion(nil, nil)
                                            
                                            
                                        } else {
                                            DBLog(error)
                                            completion(nil, error)
                                        }
        }
    }
    
    ///Merchandise 編集する
    open class func updateMerchandiseInfo(_ merchandise: Merchandise, completion:@escaping (_ merch: Merchandise?, _ error: Error?) ->Void)  {
        var params: [String: Any] = [:]
        params["book_id"] = merchandise.bookId ?? ""
        params["price"] = merchandise.price!.replaceYenSign()
        params["quality"] = merchandise.quality ?? 0
        params["description"] = merchandise.comment ?? ""
        params["ship_from"] = merchandise.shipFrom ?? shippingFromContents[0]
        params["ship_in"] = merchandise.shipInDay ?? self.shippingDaysRangesLong[0]
        params["shipping_method"] = merchandise.shipWay ?? self.shippingWays[0]
        params["is_series"] = merchandise.isSeries == true ? 1 : 0
        
        if merchandise.isSeries == true {
            params["series_description"] = merchandise.seriesDespription ?? ""
        }
        
        var images: [(name: String, fileName: String, image: UIImage)]? = []
        if merchandise.photo?.image != nil {
            images?.append((name:"image",fileName:"image.jpg",image:merchandise.photo!.image!))
        }
        
        if merchandise.photo2?.image != nil {
            images?.append((name:"image_2",fileName:"image_2.jpg",image:merchandise.photo2!.image!))
        }
        
        if merchandise.photo3?.image != nil {
            images?.append((name:"image_3",fileName:"image_3.jpg",image:merchandise.photo3!.image!))
        }
        
        DBLog(params)
                
        ApiClient.sharedClient.POST("v1/merchandises/\(merchandise.id ?? "")/update",
                                    parameters: params,
                                    iconImages: images) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                            
                                            AnaliticsManager.sendAction("update_merchandise",
                                                                        actionName: "update_merchandise",
                                                                        label: "",
                                                                        value: 1,
                                                                        dic: ["merchandise_id": merchandise.id as AnyObject,
                                                                              "book_category": merchandise.book?.categoryName as AnyObject,
                                                                              "merchandise_price": merchandise.price as AnyObject,
                                                                              "merchandise_createdAt":  merchandise.updatedAt?.dateString(in: DateFormatter.Style.short) as AnyObject,
                                                                              "merchandise_ship_from": merchandise.shipFrom as AnyObject,
                                                                              "merchandise_ship_way": merchandise.shippingWayString() as AnyObject])
                                            completion(nil, nil)
                                            
                                        } else {
                                            DBLog(error)
                                            completion(nil, error)
                                        }
        }
    }
    ///MerchandiseIdを送って情報取得
    open class func getMerchandiseInfo(_ merchandiseId: String, completion:@escaping (_ merch: Merchandise?, _ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/merchandises/\(merchandiseId)",
                                   parameters: [:]) { (responce, error) in
                                    DBLog(responce)
                                    if error == nil {
                                        let merchandise: Merchandise? = Merchandise(dictionary: responce!["merchandise"] as? [String: AnyObject])
                                        completion(merchandise, nil)
                                        
                                    } else {
                                        completion(nil, error)
                                    }
        }
    }
    
    ///BookId を送ってMerchandise取得
    open class func getMerchandiseFromBook(_ bookId: String, page: Int, completion:@escaping (_ merch: [Merchandise]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 20
        
        DBLog(params)
        
        DBLog("v1/books/\(bookId)/merchandises")
            
        ApiClient.sharedClient.GET("v1/books/\(bookId)/merchandises",
                                   parameters: params) { (responce, error) in
                                    DBLog(responce)
                                    if error == nil {
                                        DBLog(responce)
                                        
                                        if responce?["merchandises"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        let jsonArray = SwiftyJSON.JSON(responce!["merchandises"]!).arrayObject!
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let merchandises: [Merchandise] = jsonDic.map({ (dic) in
                                            let merchandise: Merchandise? = Merchandise(dictionary: dic)
                                            return merchandise!
                                        })
                                        
                                        
                                        completion(merchandises, nil)
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    /// user id送ってmerchandiseを取得
    open class func getMerchandiseInfoFromUserId(_ userId: String, page:Int, completion:@escaping (_ merch: [Merchandise]?, _ error: Error?) ->Void) {
        
        var params: [String: Any] = [:]
        params["page"] = page
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/merchandises/user/\(userId)",
                                   parameters: params) { (responce, error) in
                                    DBLog(responce)
                                    if error == nil {
                                        
                                        DBLog(responce)
                                        
                                        if responce?["merchandises"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responce!["merchandises"]!).arrayObject!
                                        
                                        if  page == 1 {
                                            JSONCache.cache(jsonArray, kind: MensionMerchandiseListCacheKey, identifier: userId)
                                        }
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let merchandises: [Merchandise] = jsonDic.map({ (dic) in
                                            let merchandise: Merchandise? = Merchandise(dictionary: dic)
                                            return merchandise!
                                        })
                                        
                                        completion(merchandises, nil)
                                        
                                    } else {
                                        completion(nil, error)
                                    }
        }
    }
    ///出品しているMerchandise取得
    open class func getSellingMerchandiseInfoFromUserId(_ userId: String, page:Int, completion:@escaping (_ merch: [Merchandise]?, _ error: Error?) ->Void) {
        
        var params: [String: Any] = [:]
        params["page"] = page
        params["selling"] = 1
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/merchandises/user/\(userId)",
                                   parameters: params) { (responce, error) in
                                    DBLog(responce)
                                    if error == nil {
                                        
                                        DBLog(responce)
                                        
                                        if responce?["merchandises"] == nil {
                                            JSONCache.cache([], kind: UserMerchandiseSellingListCacheKey, identifier: userId)
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responce!["merchandises"]!).arrayObject!
                                        
                                        if  page == 1 {
                                            JSONCache.cache(jsonArray, kind: UserMerchandiseSellingListCacheKey, identifier: userId)
                                        }
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let merchandises: [Merchandise] = jsonDic.map({ (dic) in
                                            let merchandise: Merchandise? = Merchandise(dictionary: dic)
                                            return merchandise!
                                        })
                                        
                                        completion(merchandises, nil)
                                        
                                    } else {
                                        completion(nil, error)
                                    }
        }
    }

    ///merchandiseが買えるかどうか
    open func canBuyMerchandise(_ completion: @escaping (_ canBuy: Bool?, _ needPoint: String?, _ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/merchandises/\(self.idString(id))/buy_status",
                                   parameters: [:]) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        completion(responceObject?["can_buy"] as? Bool, responceObject?["point_needed"].map{String(describing: $0)}, nil)
                                    } else {
                                        DBLog(error)
                                        completion(false, nil, error)
                                    }
        }
    }
    
    ///Merchandiseを買う
    open func buyMerchandise(_ useBonusPoint: Bool, completion: @escaping (_ transaction: Transaction?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["user_address_id"] = Me.sharedMe.defaultAdress?.id
        params["use_bonus_point"] = useBonusPoint ? 1 : 0
        
        DBLog(params)
        
        DBLog(self.id)
    
        ApiClient.sharedClient.POST("v1/merchandises/\(self.idString(id))/buy",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                            let transaction: Transaction = Transaction()
                                            transaction.id = responceObject?["item_transaction_id"].map{String(describing: $0)}
                                            transaction.type = TransactionListType.sellerPrepareShipping
                                            
                                            completion(transaction, nil)
                                        } else {
                                            SBLog(error!)
                                            completion(nil, error)
                                        }
        }
    }

    func buyMerchandise(withPoint point: Int, withSales sales: Int, withPayment payment: Int, completion: @escaping (_ transaction: Transaction?, _ roomId: Int?, _ error: Error?)-> Void) {
        guard let addressId = Me.sharedMe.defaultAdress?.id else {
            let err = Error(domain: ErrorDomain, code: ErrorCodeType.invalidParameter.rawValue, userInfo: nil)
            completion(nil, nil, err)
            return
        }
        guard let merchandiseId = self.id else {
            let err = Error(domain: ErrorDomain, code: ErrorCodeType.badRequest.rawValue, userInfo: nil)
            completion(nil, nil, err)
            return
        }

        let params: [String: Any] = ["user_address_id": addressId,
                                     "bonus_point": point,
                                     "point": sales,
                                     "credit": payment]
        ApiClient.sharedClient.POST("v2/merchandises/\(merchandiseId)/buy", parameters: params) { (response: [String: Any]?, error: Error?) in
            if error == nil {
                DBLog(response)
                // 必須情報が取得できていなければエラーを返す（エラーコードは考慮の余地あり！）
                guard let transactionId = response?["item_transaction_id"] as? Int,
                    let roomId = response?["room_id"] as? Int else {
                        let err = Error(domain: ErrorDomain, code: ErrorCodeType.notFound.rawValue, userInfo: nil)
                        completion(nil, nil, err)
                        return
                }

                let transaction = Transaction()
                transaction.id = String(transactionId)
                transaction.type = .sellerPrepareShipping
                completion(transaction, roomId, nil)
            } else {
                completion(nil, nil, error)
            }
        }
    }
    
    ///Merchandiseを通報
    open func reportMerchandise(_ reason: String?, completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["reportable_type"] = "Merchandise"
        params["reportable_id"] = self.idString(id)
        params["reason"] = reason as AnyObject?
        
        DBLog(params)

        ApiClient.sharedClient.POST("v1/reports/create",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            completion(nil)
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    
    ///Merchandiseを削除
    open func deleteMerchandise(_ completion: @escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.POST("v1/merchandises/\(self.idString(id))/delete",
                                    parameters: [:]) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                            AnaliticsManager.sendAction("delete_merchandise",
                                                                        actionName: "delete_merchandise",
                                                                        label: "",
                                                                        value: 1,
                                                                        dic: ["merchandise_id": self.id as AnyObject,
                                                                              "book_category": self.book?.categoryName as AnyObject,
                                                                              "merchandise_price": self.price as AnyObject,
                                                                              "merchandise_createdAt":  self.updatedAt?.dateString(in: DateFormatter.Style.short) as AnyObject,
                                                                              "merchandise_ship_from": self.shipFrom as AnyObject,
                                                                              "merchandise_ship_way": self.shippingWayString() as AnyObject])
                                            completion(nil)
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    
    open class func cachedMensionMerchandiseList(_ userID: String) ->[Merchandise]? {
        let cacheList: [Any]? = JSONCache.cachedJSONListWithKind(MensionMerchandiseListCacheKey, identifier: userID)
        if cacheList == nil {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [Merchandise] = modelDic.map({ (dic) in
            let model = Merchandise(dictionary: dic)
            return model
        })
        return models
    }
    
    open class func cachedSellingMerchandiseList(_ userID: String) ->[Merchandise]? {
        let cacheList: [Any]? = JSONCache.cachedJSONListWithKind(UserMerchandiseSellingListCacheKey, identifier: userID)
        if cacheList == nil {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [Merchandise] = modelDic.map({ (dic) in
            let model = Merchandise(dictionary: dic)
            return model
        })
        return models
    }
    
    open class func searchMerchandise(_ userId: String?, merId: String?) ->Merchandise? {
        if Utility.isEmpty(merId) && Utility.isEmpty(userId) {
            return nil
        }
        let cacheList: [Merchandise]? = cachedMensionMerchandiseList(userId!)
        
        let merchandise: Merchandise? = cacheList?.filter({ (mer) -> Bool in
            return mer.id == merId
        }).first
        return merchandise
    }
}

extension Merchandise: ShippingConstantsProtocol {
    func shippingSummary(longFormat longDaysRange: Bool)-> (planeString: String, boldRanges: [NSRange], regularRanges: [NSRange]) {
        let daysString = longDaysRange ? Merchandise.shippingDaysRangeLong(by: self.shipInDay ?? 0) : Merchandise.shippingDaysRange(by: self.shipInDay ?? 0)
        let boldStrings: [String] = ["\(self.shipFrom ?? "")", "\(daysString)以内", "\(Merchandise.shippingWay(by: self.shipWay ?? 0))"]
        let regularStrings: [String] = ["から", "に", "で発送します"]
        let summaryString = boldStrings[0] + regularStrings[0] + boldStrings[1] + regularStrings[1] + boldStrings[2] + regularStrings[2]

        let boldRanges = [NSRange.init(location: 0, length: boldStrings[0].length),
                          NSRange.init(location: boldStrings[0].length + regularStrings[0].length, length: boldStrings[1].length),
                          NSRange.init(location: boldStrings[0].length + regularStrings[0].length + boldStrings[1].length + regularStrings[1].length, length: boldStrings[2].length)]
        let regularRanges = [NSRange.init(location: boldStrings[0].length, length: regularStrings[0].length),
                             NSRange.init(location: boldStrings[0].length + regularStrings[0].length + boldStrings[1].length, length: regularStrings[1].length),
                             NSRange.init(location: boldStrings[0].length + regularStrings[0].length + boldStrings[1].length + regularStrings[1].length + boldStrings[2].length, length: regularStrings[2].length)]
        return (summaryString, boldRanges, regularRanges)
    }
}
