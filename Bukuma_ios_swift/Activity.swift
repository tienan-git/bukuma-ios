//
//  Activity.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

public enum ActivityType : Int{
    case likeBooks
    case updateBooksPrice
    case bounghtBooks
    case updateLikesBooksPrice
    
    mutating func typeFromString(_ string: String?) {
        if string == nil {
            return
        }
        switch string! {
        case "book.liked":
            self = .likeBooks
            break
        case "book.updated":
            self = .updateBooksPrice
            break
        case "book.selling_price":
            self = .updateBooksPrice
            break
        case "merchandise.bought":
            self = .bounghtBooks
            break
        case "book.liked_selling_price":
            self = .updateLikesBooksPrice
            break
        default:
            break
        }
    }
}

open class Activity: BaseModelObject {
    var id: String?
    var text: String?
    var date: NSDate?
    var book: Book?
    var type: ActivityType?
    var user: User?
    var merchandise: Merchandise?
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        id = attributes?["id"].map{String(describing: $0)}
        text = attributes?["text"].map{String(describing: $0)}
        attributes?["created_at"].map{String(describing: $0)}.flatMap{Int($0)}.flatMap{Double($0)}.map{date = NSDate(timeIntervalSince1970: $0)}
        type = ActivityType(rawValue: 0)
        type?.typeFromString(attributes?["key"].map{String(describing: $0)})
        if type == .bounghtBooks {
            book = Book.generatedBookFromStore(attributes?["target"]?["book"] as? [String: AnyObject])
            user = User(dictionary: attributes?["target"]?["bought_by"] as? [String: AnyObject])
            merchandise = Merchandise(dictionary: attributes?["target"] as? [String: AnyObject])

        } else {
            book = Book.generatedBookFromStore(attributes?["target"] as? [String: AnyObject])
            user = User(dictionary: attributes?["user"] as? [String: AnyObject])
        }

    }
    
    open class func getActivityList(_ page: Int, completion: @escaping (_ activities: [Activity]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 15 
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/activities",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        if responceObject!["activities"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["activities"]!).arrayObject!
                                        if page == 1 {
                                            JSONCache.cacheArray(jsonArray, key: ActivityListCacheKey)
                                        }
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let activities: [Activity] = jsonDic.map({ (dic) in
                                            let activity: Activity? = Activity(dictionary: dic)
                                            return activity!
                                        })
                                        
                                        if page == 1 {
                                            ActivityRealtimeUpdater.sharedUpdater.updateLatestId(activities.first?.id ?? "0")
                                        }
                                        
                                        completion(activities, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    open class func cacheActivity() ->[Activity]? {
        return self.cachedModelObjects(ActivityListCacheKey, modelClass: Activity.self) as? [Activity]
    }
}
