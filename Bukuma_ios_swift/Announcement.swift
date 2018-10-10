//
//  Announcement.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/30.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

public let AnnouncementReadKey = "AnnouncementReadKey"

open class Announcement: BaseModelObject {
    
    var id: String?
    var topic: String?
    var updatedAt: NSDate?
    var content: String?
    var contentUrl: URL?
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        id = attributes?["id"].map{String(describing: $0)}
        topic = attributes?["topic"].map{String(describing: $0)}
        content = attributes?["content"].map{String(describing: $0)}
        attributes?["url"].map{contentUrl =  URL(string: String(describing: $0))}
        attributes?["updated_at"].map{updatedAt = NSDate(timeIntervalSince1970: Double(Int(String(describing: $0))!))}
    }
    
    open class func getAnnouncementsList(_ page: Int, completion: @escaping (_ announcements: [Announcement]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 20 
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/announcements",
                                   parameters: params) { (responceObject, error) in
                                    DBLog(responceObject)
                                    if error == nil {
                                        if responceObject!["announcements"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["announcements"]!).arrayObject!
                                        JSONCache.cacheArray(jsonArray, key: AnnouncementsListCacheKey)
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let annoucements: [Announcement] = jsonDic.map({ (dic) in
                                            let annoucement: Announcement? = Announcement(dictionary: dic)
                                            return annoucement!
                                        })

                                        completion(annoucements, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    open func readAnnouncement(_ completion: ((_ error: Error?) ->Void)?) {
        ApiClient.sharedClient.POST("v1/announcements/\(self.idString(id))/read",
                                    parameters: [:]) { (responceObject, error) in
                                        if error == nil {
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: AnnouncementReadKey), object: nil)
                                            DBLog(responceObject)
                                            if completion != nil {
                                                completion!(nil)
                                            }
                                        } else {
                                            DBLog(error)
                                            if completion != nil {
                                                completion!(error)
                                            }
                                        }
        }
    }
    
    open func getAnnouncementFromId(_ completion: @escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/announcements/\(self.idString(id))",
                                   parameters: [:]) { (responceObject, error) in
                                    if error == nil {
                                        
                                        DBLog(responceObject)
                                        completion(nil)
                                    } else {
                                        
                                        DBLog(error)
                                        completion(error)
                                    }
        }
    }
    
    open class func unReadCount(_ completion: @escaping (_ unreadCount: Int?, _ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/announcements/unread",
                                   parameters: [:]) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        completion(responceObject!["unread_count"] as? Int, nil)
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    open class func cachedAnnouncements() ->[Announcement]? {
       return  self.cachedModelObjects(AnnouncementsListCacheKey, modelClass: Announcement.self) as? [Announcement]
    }
}
