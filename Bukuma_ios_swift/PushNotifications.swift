//
//  PushNotifications.swift
//  Bukuma_ios_swift
//
//  Created by khara on 9/29/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import UserNotifications

protocol PushNotificationProtocol {
    func registerForPushNotifications()
}

extension PushNotificationProtocol where Self: AppDelegate {
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self

            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                guard granted else { return }
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    guard settings.authorizationStatus == .authorized else { return }
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
