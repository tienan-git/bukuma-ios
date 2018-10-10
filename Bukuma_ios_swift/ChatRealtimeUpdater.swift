//
//  ChatRealtimeUpdater.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/16.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import SwiftyJSON

let ChatRealtimeUpdaterFirstDate: String = "ChatRealtimeUpdaterFirstDate"
let ChatRealtimeUpdaterLastDate: String = "ChatRealtimeUpdaterLastDate"

let ChatRoomDataSourceRefreshKey: String = "ChatRoomDataSourceRefreshKey"

open class ChatRealtimeUpdater: NSObject {
    
    fileprivate var timer: Timer?
    
    var chatRoomFirstUpdateDate: Date? {
        if chatRoomFirstUpdateDateTimeStamp == nil {
            return nil
        }
        return  Date(timeIntervalSince1970: chatRoomFirstUpdateDateTimeStamp!)
    }
    
    var chatRoomFirstUpdateDateTimeStamp: Double? {
        let timeUpdate: Double? = UserDefaults.standard.double(forKey: ChatRealtimeUpdaterFirstDate)
        if timeUpdate == nil || timeUpdate == 0 {
            return nil
        }
        return timeUpdate!
    }
    
    var chatRoomLastUpdateDate: Date? {
        if chatRoomLastUpdateDateTimeStamp == nil {
            return nil
        }
        return  Date(timeIntervalSince1970: chatRoomLastUpdateDateTimeStamp!)
    }
    
    var chatRoomLastUpdateDateTimeStamp: Double? {
        let timeUpdate: Double? = UserDefaults.standard.double(forKey: ChatRealtimeUpdaterLastDate)
        if timeUpdate == nil || timeUpdate == 0 {
            return nil
        }
        return timeUpdate!
    }
    
    open class var sharedUpdater: ChatRealtimeUpdater{
        struct Static {
            static let instance = ChatRealtimeUpdater()
        }
        return Static.instance
    }
    
    func startTracking() {
        self.endTracking()
        self.update()
        timer = Timer.scheduledTimer(timeInterval: 20,
                                                       target: self,
                                                       selector: #selector(self.update),
                                                       userInfo: nil,
                                                       repeats: true)
    }
    
    func endTracking() {
        timer?.invalidate()
        timer = nil
    }
    
    class func updateChatRoomBadgeWithCount(_ count: Int) {
        if count > 0 {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: ChatRoomDataSourceRefreshKey), object: nil)
        }
        TabManager.sharedManager.setActivityBadgeCount(count, tabIndex: 3)
    }
    
    func update() {
        
        var params: [String: Any] = [:]
        params["from_timestamp"] = nil
        params["number"] = 50
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/chat_rooms",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        if responceObject!["chat_rooms"] == nil {
                                            JSONCache.cacheArray([], key: ChatRoomListCacheKey)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["chat_rooms"]!).arrayObject!
                                        JSONCache.cacheArray(jsonArray, key: ChatRoomListCacheKey)
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        
                                        var count: Int = 0
                                        var firstPostUpdate: Double = 0
                                        var lastPostUpdate: Double = 0
                                        
                                        let rooms: [ChatRoom] = jsonDic.map({ (dic) in
                                            let room: ChatRoom? = ChatRoom(dictionary: dic)
                                            count += room?.numberOfUnreadCount ?? 0
                                            return room!
                                        })
                                        
                                        ChatRoom.save(all: rooms)
                                                                                
                                        firstPostUpdate = rooms.first!.timeStump!
                                        lastPostUpdate = rooms.last!.timeStump!
                                        
                                        ChatRealtimeUpdater.updateFirstChatRoomGettingDate(firstPostUpdate)
                                        ChatRealtimeUpdater.updateLastChatRoomGettingDate(lastPostUpdate)
                                        DispatchQueue.main.async(execute: {
                                            ChatRealtimeUpdater.updateChatRoomBadgeWithCount(count)
                                        })
                                    } else {
                                        
                                        DBLog(error)
                                        
                                    }
        }
    }
    
    class func updateFirstChatRoomGettingDate (_ firstPostUpdate: Double) {
        UserDefaults.standard.set(firstPostUpdate, forKey: ChatRealtimeUpdaterFirstDate)
        UserDefaults.standard.synchronize()
    }
    
    class func updateLastChatRoomGettingDate (_ lastPostUpdate: Double) {
        UserDefaults.standard.set(lastPostUpdate, forKey: ChatRealtimeUpdaterLastDate)
        UserDefaults.standard.synchronize()
    }
}
