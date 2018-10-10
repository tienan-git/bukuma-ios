//
//  ActivityRealtimeUpdater.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/23.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class ActivityRealtimeUpdater: NSObject {
    fileprivate var timer: Timer?
    fileprivate let ActivityRealtimeUpdaterLatestKey: String = "ActivityRealtimeUpdater"
    
    fileprivate var latestId: String? {
        return UserDefaults.standard.string(forKey: ActivityRealtimeUpdaterLatestKey)
    }
    
    open class var sharedUpdater: ActivityRealtimeUpdater {
        struct Static {
            static let instance = ActivityRealtimeUpdater()
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
    
    func update() {
        var params: [String: Any] = [:]
        params["latest_id"] = (latestId != nil) ? latestId : 0
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/activities/badge_status",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        DispatchQueue.main.async(execute: { 
                                            self.updateBadge(responceObject?["count"] as? Int ?? 0)
                                        })
                                        
                                    } else {
                                        DBLog(error)
                                    }
        }
    }
    
    fileprivate func updateBadge(_ count: Int) {
        if count == 0 {
            AppDelegate.shouldUpdateActivity = false
            return
        }
        AppDelegate.shouldUpdateActivity = true
    }
    
    func updateLatestId(_ latestId: String) {
        UserDefaults.standard.set(latestId, forKey: ActivityRealtimeUpdaterLatestKey)
        UserDefaults.standard.synchronize()
    }
}
