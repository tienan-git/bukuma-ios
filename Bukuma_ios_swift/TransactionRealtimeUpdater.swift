//
//  TransactionRealtimeUpdater.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/23.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class TransactionRealtimeUpdater: NSObject {
    
    fileprivate var timer: Timer?
    fileprivate let TransactionRealtimeUpdaterLatestKey: String = "TransactionRealtimeUpdaterLatestKey"
    
    fileprivate var latestId: String? {
        return UserDefaults.standard.string(forKey: TransactionRealtimeUpdaterLatestKey)
    }
    
    open class var sharedUpdater: TransactionRealtimeUpdater{
        struct Static {
            static let instance = TransactionRealtimeUpdater()
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
        params["latest_id"] = 0
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/item_transactions/badge_status",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        DispatchQueue.main.async(execute: {
                                            self.updateTranasctionBadge(responceObject?["count"] as? Int ?? 0)
                                        })
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TransactionRefreshKey), object: self)
                                    } else {
                                        DBLog(error)
                                        DispatchQueue.main.async(execute: {
                                            AppDelegate.shouldUpdateTransaction = false
                                        })
                                    }
        }
    }
    
    fileprivate func updateTranasctionBadge(_ count: Int) {
        if count == 0 {
            AppDelegate.shouldUpdateTransaction = false
            return
        }
        AppDelegate.shouldUpdateTransaction = true
    }
}
