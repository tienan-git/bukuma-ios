//
//  CreditCard.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/18.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

let CreditCardDeleteKey = "CreditCardDeleteKey"

open class CreditCard: BaseModelObject {
    var id: String?
    var paymentId: String?
    var cardNumber: String?
    var last4: String?
    var bank: String?
    var brand: String?
    var expirationMonth: String?
    var expirationYear: String?
    var name: String?
    var adressId: String?
    var omiseCardId: String?
    var omiseToken: String?
    var isDefault: Bool?
    var securityCode: String?
    var validsecurityCode: String?
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        id = attributes?["id"].map{String(describing: $0)}
        brand = attributes?["info"]?["brand"]?.map{String(describing: $0)}
        last4 = attributes?["last_4"].map{String(describing: $0)}
        name = attributes?["name"].map{String(describing: $0)}
        expirationMonth = attributes?["exp_month"].map{String(describing: $0)}
        expirationYear = attributes?["exp_year"].map{String(describing: $0)}
        adressId = attributes?["user_address_id"].map{String(describing: $0)}
        paymentId = attributes?["user_payment_gateway_id"].map{String(describing: $0)}
        omiseCardId = attributes?["external_id"].map{String(describing: $0)}
        isDefault = attributes?["default"] as? Bool
        //it is string because omise return string. not bool
        validsecurityCode = attributes?["info"]?["security_code_check"]?.map{String(describing: $0)}
    }
    
    open class func registerCard(_ creditCard: CreditCard, completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["external_id"] = creditCard.omiseCardId
        params["card_token"] = creditCard.omiseToken
        params["exp_year"] = creditCard.expirationYear

        params["name"] = creditCard.name
        params["exp_month"] = creditCard.expirationMonth
        params["default"] = creditCard.isDefault
        params["last_4"] = creditCard.last4 
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/credit_cards/create",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                            self.getCardInfo({ (cards, error) in
                                                if error == nil {
                                                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
                                                    completion(nil)
                                                    return
                                                }
                                                completion(error)
                                            })
                                        } else {
                                            SBLog(error!)
                                            
                                            completion(error)
                                        }
        }
    }
    
    open class func getCardInfo(_ completion: @escaping (_ cards: Array<CreditCard>?, _ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/credit_cards",
                                   parameters: [:]) { (responce, error) in
                                    if error == nil {
                                        DBLog(responce)
                                        
                                        if responce!["user_payment_sources"] == nil {
                                            JSONCache.cacheArray([], key: CardListCacheKey)
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responce!["user_payment_sources"]!).arrayObject!
                                        JSONCache.cacheArray(jsonArray, key: CardListCacheKey)
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let cards: [CreditCard] = jsonDic.map({ (dic) in
                                            let card: CreditCard? = CreditCard(dictionary: dic)
                                            return card!
                                        })

                                        completion(cards, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    open class func getCardInfoFromId(_ cardId: String, completion:@escaping (_ card: CreditCard?, _ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/credit_cards/\(cardId)",
                                   parameters: [:]) { (responce, error) in
                                    if error == nil {
                                        let card: CreditCard = CreditCard(dictionary: responce as [String : AnyObject]?)
                                        completion(card, nil)
                                    } else {
                                        completion(nil, error)
                                    }
        }
    }
    
    open func deleteCards(_ forceDelete: Bool, completion: @escaping (_ error: Error?) ->Void) {
        
        var params: [String: Any] = [:]
        params["force"] = forceDelete ? 1 : 0 as AnyObject?
        
        DBLog(params)
        
        DBLog(id)
        
        ApiClient.sharedClient.DELETE("v1/credit_cards/\(self.idString(self.id))",
                                      parameters: params) { (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: CreditCardDeleteKey), object: self)

                                            completion(nil)
                                        } else {
                                            DBLog(error)
                                            
                                            completion(error)
                                        }
        }
    }

    open func changeDefaultCard(_ completion:@escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["default"] = self.isDefault == true ? 1 : 0 as AnyObject?
    
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/credit_cards/\(self.idString(self.id)))",
                                    parameters: params) { (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            completion(nil)
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    
    open class func getPurchasePointTransactionList(_ page: Int, completion:@escaping (_ pointPurchaseTransactions: [PointPurchaseTransaction]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 20
        
        ApiClient.sharedClient.GET("v1/credit_cards/transactions",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        if responceObject!["point_purchase_transactions"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["point_purchase_transactions"]!).arrayObject!
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let purchasePointTransactions: [PointPurchaseTransaction] = jsonDic.map({ (dic) in
                                            let purchasePointTransaction: PointPurchaseTransaction? = PointPurchaseTransaction(dic: dic)
                                            return purchasePointTransaction!
                                        })
                                        
                                        completion(purchasePointTransactions, nil)

                                    } else {
                                        DBLog(error)
                                        completion(nil,error)
                                    }
        }
    }
    
    open func buyPointViaCard(_ pointAmount: Int, merchandiseId: Int, completion:@escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["amount"] = pointAmount
        params["merchandise_id"] = merchandiseId

        DBLog(params)
        
        DBLog(id)
        
        ApiClient.sharedClient.POST("v1/credit_cards/\(self.idString(id))/purchase",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            completion(nil)
                                        } else {
                                            SBLog(error!)
                                            
                                            completion(error)
                                        }
        }
    }
    
    open class func cachedCardList() ->[CreditCard]? {
        return self.cachedModelObjects(CardListCacheKey, modelClass: CreditCard.self) as? [CreditCard]
    }
    
    open class func defaultCard() ->CreditCard? {
        let defaultCard: CreditCard? = CreditCard.cachedCardList()?.filter({ (card) -> Bool in
            return card.isDefault == true
        }).first
        if defaultCard != nil {
            return defaultCard
        }
        
        //CreditCardを登録しているのに、serverの不都合でisDefaultが返ってこなかった時はとりあえず最初のやつを返す
        if defaultCard == nil && (CreditCard.cachedCardList()?.count ?? 0) > 0 {
            return CreditCard.cachedCardList()?[0]
        }
        return nil
    }
}

