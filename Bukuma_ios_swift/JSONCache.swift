//
//  BKMJSONCache.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/11.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyUserDefaults

/**
このClassではローカルに保存するけど、mobile databaseを使うまでもないデータを保存してます
 例えば、タイムラインのキャッシュなど
 mobile databaseの欠点はmigrationをしないといけないとこで
 複雑になりやすいので、
 このprojectでは複雑はchatはdatabaseで
 それ以外はこっちで
 という実装になっています
 
 
 */

//Cacheのために使っているKey
public let AdressListCacheKey: String = "AdressListCacheKey"
public let CategoryListCacheKey = "CategoryListCacheKey"
public let MeMyCacheInfoKey = "MeMyCacheInfoKey"
public let MeFacebookAcsessTokenCacheKey = "MeFacebookAcsessTokenCacheKey"
public let CardListCacheKey: String = "CardListCacheKey"
public let BankListCacheKey: String = "BankListCacheKey"
public let ActivityListCacheKey: String = "ActivityListCacheKey"
public let TransactionsListCacheKey: String = "TransactionsListCacheKey"
public let BoughtTransactionsListCacheKey: String = "BoughtTransactionsListCacheKey"
public let SoldTransactionsListCacheKey: String = "SoldTransactionsListCacheKey"
public let MerchandiseListCacheKey: String = "MerchandiseListCacheKey"
public let AnnouncementsListCacheKey: String = "AnnouncementsListCacheKey"
public let ItemTransactionCacheKey: String = "ItemTransactionCacheKey"
public let BookRootCategoryListCacheKey: String = "BookRootCategoryListCacheKey"
public let BookSearchCategoryListCacheKey: String = "BookSearchCategoryListCacheKey"
public let BookDayRangeListCacheKey: String = "BookDayRangeListCacheKey"
public let BookPriceLimitListCacheKey: String = "BookPriceLimitListCacheKey"
public let BookBulkListCacheKey: String = "BookBulkListCacheKey"

public let LikedBookListCacheKey: String = "LikedBookListCacheKey"
public let ReviewListCacheKey: String = "ReviewListCacheKey"
public let MensionMerchandiseListCacheKey: String = "MensionMerchandiseListCacheKey"
public let UserMerchandiseSellingListCacheKey: String = "UserMerchandiseSellingListCacheKey"
public let PointTransactionListKey: String = "PointTransactionListKey"

public extension UserDefaults {
     func saveObjects<T: AnyObject>(_ key: String, _ v: [T]? = nil) ->Bool? {
        UserDefaults.standard.set(v, forKey: key)
        return UserDefaults.standard.synchronize()
    }
    
    func savedObjectsForKey<T: AnyObject>(_ key: String) ->[T]? {
        return UserDefaults.standard.object(forKey: key) as? [T]
    }
    
    subscript(key: DefaultsKey<[Category]?>) -> [Category]? {
        get { return unarchive(key) }
        set { archive(key, newValue) }
    }
}

open class JSONCache: NSObject {
    
    open class func cacheArray(_ array: Array<Any>, key: String) {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: array), forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    open class func cacheDic(_ dic: [String: Any], key: String) {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: dic), forKey: key)
        UserDefaults.standard.synchronize()
    }

    open class func cachedArrayListWithKey(_ key: String) ->Array<Any>? {
         return NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.object(forKey: key) as? NSData ?? NSData()) as Data) as? Array
    }
    
    open class func cachedDicListWithKey(_ key: String) ->[String: Any]? {
        return NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.object(forKey: key) as? NSData ?? NSData()) as Data) as? [String: Any]
    }
    
    open class func cache(_ JSONList: Array<Any>, kind: String, identifier: String) {
        let key: String = kind + "-" + identifier
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: JSONList), forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    open class func cachedJSONListWithKind(_ kind: String, identifier: String) ->Array<Any>? {
        let key: String! = kind + "-" + identifier
        if key == nil {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.object(forKey: key) as? NSData ?? NSData()) as Data) as? Array
    }
}
