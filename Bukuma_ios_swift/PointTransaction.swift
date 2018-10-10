//
//  PointTransaction.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/25.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

public struct PointPurchaseTransaction {
    var id: String?
    var point: Int?
    var status: String?
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    init() {}
    init(dic: [String: AnyObject]?) {
        id = dic?["id"].map{String(describing: $0)}
        point = dic?["point"] as? Int
        status = dic?["status"].map{String(describing: $0)}
        dic?["created_at"].map{createdAt = NSDate(timeIntervalSince1970: Double(Int(String(describing: $0))!))}
        dic?["updated_at"].map{updatedAt = NSDate(timeIntervalSince1970: Double(Int(String(describing: $0))!))}
    }
}

public enum PointTransactionStateType : Int{
    case singin
    case firstSingin
    case buyMerchandise
    case soldMerchandise
    case buyPoint
    case withdraw
    case adminNormal
    case adminBonus
    case refundNormal
    case refundBonus
    case campain
    case unknown
    case buyMerchandiseViaCreditCard
    case expiredSales
    case expiredPoint
    case buyCreditCard

    mutating func typeFromParameter(_ string: String?, pointChanged: Int, bonusPointChanged: Int) {
        if string == nil {
            self = .unknown
            return
        }
        if string?.contains("Bought merchandise") == true {
            self = .buyMerchandise
        } else if string?.contains("purchased from card") == true {
            self = .buyPoint
        } else if string?.contains("Withdraw") == true {
            self = .withdraw
        } else if string?.contains("Refunded") == true {
            if pointChanged != 0 && bonusPointChanged == 0 {
                self = .refundNormal
            } else if pointChanged == 0 && bonusPointChanged != 0 {
                 self = .refundBonus
            }
        } else if string?.contains("Admin") == true {
            if pointChanged != 0 && bonusPointChanged == 0 {
                self = .adminNormal
            } else if pointChanged == 0 && bonusPointChanged != 0 {
                self = .adminBonus
            }
        } else if string?.contains("sold merchandise") == true {
            self = .soldMerchandise
        } else if string?.contains("signed up from") == true {
            self = .singin
        } else if string?.contains("signed up bonus") == true {
            self = .firstSingin
        } else if string?.contains("Bonus from campaign") == true || string?.contains("Campaign") == true {
            self = .campain
        } else if string?.contains("expired") == true {
            if pointChanged != 0 && bonusPointChanged == 0 {
                self = .expiredSales
            } else if pointChanged == 0 && bonusPointChanged != 0 {
                self = .expiredPoint
            }
        } else if string?.contains("credit point") == true {
            self = .buyCreditCard
        }
    }
}

public enum PointTransactionMoneySignType: Int {
    case puls
    case minus
    case unknown
    
     mutating func typeFromParameter(_ status: PointTransactionStateType?, pointChanged: Int, bonusPointChanged: Int) {
        if status == nil {
            self = .unknown
            return
        }
        switch status! {
        case .singin, .firstSingin, .soldMerchandise, .campain, .refundNormal, .refundBonus, .buyPoint:
            self = .puls
            break
        case .adminNormal, .adminBonus:
            if pointChanged > 0 || bonusPointChanged > 0 {
                self = .puls
            }
            if pointChanged < 0 || bonusPointChanged < 0 {
                self = .minus
            }
            break
        case .buyMerchandise, .withdraw, .expiredPoint, .expiredSales, .buyCreditCard:
            self = .minus
            break
        default:
            self = .unknown
            break
        }
    }
}

public enum PointTransactionPointType: Int {
    case normal
    case bonus
    
    mutating func typeFromParameter(pointChanged: Int, bonusPointChanged: Int) {
        if pointChanged != 0 && bonusPointChanged == 0 {
            self = .normal
        } else if pointChanged == 0 && bonusPointChanged != 0 {
            self = .bonus
        }
    }
}

public class GetPointTransactionResponse {
    var pointTransactions: [PointTransaction]?
    var userPoint: Int?
    var userBonusPoint: Int?
    var nearExpireBonusPoint: Int?
    var nearExpireBonusPointDatetime: Date?
}

/**
 PointTransaction Object
 Pointの履歴ですね
 売上・Point履歴画面で使われています
 いっぱいタイプがあります
 1. まず、売上かPointか
    これはPointTransactionPointTypeです
 2. 増えた履歴か、減った履歴か
    これはPointTransactionMoneySignTypeです
 3. 何にPoint, 売上を使った?増えた?
    これはPointTransactionStateTypeです
    このタイプを使ってます
 */
open class PointTransaction: BaseModelObject {
    var id: String? ///id
    var status: String? ///status そのPoint使ったとか、Stringが帰ってくる
    var pointChanged: Int = 0 ///売上がどれくらい変わったか
    var bonusPointChanged: Int = 0 ///Pointどれくらい変わったか
    var newPoint: Int = 0 ///新しい売上
    var newBonusPoint: Int = 0///新しいPoint
    var oldPoint: Int = 0 ///昔のPoint
    var creditPoint: Int = 0
    var purchaseDescription: String? ///description
    var remainingPoint: Int = 0 /// 失効予定Point(そのPointTransactionの)
    var createdAt: Date? ///作成日時
    var updatedAt: Date? ///更新日時
    var expiredAt: Date? ///失効日時
    var stateType: PointTransactionStateType?
    var moneySignType: PointTransactionMoneySignType?
    var pointType: PointTransactionPointType?
    var book: Book? ///本
    var merchandise: Merchandise? ///Merchandise
    
    var shouldRemove: Bool = false
    var shouldAdd: Bool = false
    var addableIndex: Int = -1
    
    open override func updatePropertyWithJSON(_ json: JSON) {
        id = json["id"].string
        status = json["status"].string
        pointChanged = json["point_changed"].intValue
        bonusPointChanged = json["bonus_point_changed"].intValue
        newPoint = json["new_point"].intValue
        newBonusPoint = json["new_bonus_point"].intValue
        oldPoint = json["old_point"].intValue
        creditPoint = -(json["credit_point"].intValue)
        remainingPoint = json["remaining_point"].intValue
        purchaseDescription = json["description"].string
        createdAt = json["created_at"].date
        updatedAt = json["updated_at"].date
        expiredAt = json["expired_at"].date
        stateType = PointTransactionStateType(rawValue: 0)
        stateType?.typeFromParameter(purchaseDescription, pointChanged: pointChanged, bonusPointChanged: bonusPointChanged)
        
        moneySignType = PointTransactionMoneySignType(rawValue: 0)
        moneySignType?.typeFromParameter(stateType, pointChanged: pointChanged, bonusPointChanged: bonusPointChanged)
        
        pointType = PointTransactionPointType(rawValue: 0)
        pointType?.typeFromParameter(pointChanged: stateType == .buyCreditCard ? creditPoint : pointChanged, bonusPointChanged: bonusPointChanged)
        book = Book(dictionary: json["book"].dictionaryObject as [String: AnyObject]?)
        merchandise = Merchandise(dictionary: json["merchandise"].dictionaryObject as [String: AnyObject]?)
    }
    
    open class func getPointTransactionLogs(_ page: Int, completion: @escaping (_ response: GetPointTransactionResponse?, _ error: Error?) ->Void) {
        let params: [String: Any] = ["page": page]
        DBLog(params)
        
        ApiClient.sharedClient.get("v1/point_transactions", parameters: params) { (responce, error) in
            if let error = error {
                DBLog(error)
                completion(nil, error)
                return
            }
            
            DBLog(responce)
            let values = GetPointTransactionResponse()
            
            if let jsonArray = responce["point_transactions"].arrayObject {
                JSONCache.cacheArray(jsonArray, key: PointTransactionListKey)
            }
            
            values.pointTransactions = responce["point_transactions"].array?.map({
                PointTransaction(json: $0)
            })
            
            values.userPoint = responce["user_point"].int
            values.userBonusPoint = responce["user_bonus_point"].int
            values.nearExpireBonusPoint = responce["near_expire_bonus_point"].int
            values.nearExpireBonusPointDatetime = Date(timeIntervalSince1970: responce["near_expire_bonus_point_datetime"].doubleValue)
            
            completion(values, nil)
        }
    }
    
    open class func cachePointTransactions() ->[PointTransaction]? {
        return self.cachedModelObjects(PointTransactionListKey, modelClass: Activity.self) as? [PointTransaction]
    }

}
