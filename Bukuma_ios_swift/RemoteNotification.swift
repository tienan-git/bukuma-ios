//
//  RemoteNotification.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/09.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class RemoteNotification: NSObject {
    
    open class func registerForRemoteNotification() {
        self.finishNotificationAlert()
        RemoteNotification.alreadyHaveNotificationAlert = true
        
        UIApplication.shared.registerForRemoteNotifications()
        
        let types: UIUserNotificationType = [.badge, .sound, .alert]
        let setting: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(setting)
    }
    
    open class func transliterationDeviceToken(_ deviceToken: Data) ->String {
        let token = deviceToken.reduce("") { $0 + String(format: "%.2hhx", $1) }
        return String(token)
    }
    
    static var _shouldShowNotificationAlert: Bool = false
    static var alreadyHaveNotificationAlert: Bool = false
    
    open class func isPermittedUserNotification() ->Bool {
        let settings: UIUserNotificationSettings? = UIApplication.shared.currentUserNotificationSettings
        return settings?.types != .none
    }
    
    open class func prepareNotificationAlert() {
        RemoteNotification._shouldShowNotificationAlert = true
    }
    
    open class func finishNotificationAlert() {
        RemoteNotification._shouldShowNotificationAlert = false
    }
    
    open class func shouldShowNotificationAlert() ->Bool {
        return RemoteNotification._shouldShowNotificationAlert && self.isPermittedUserNotification() && !RemoteNotification.alreadyHaveNotificationAlert
    }
}
