//
//  AnaliticsManager.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/15.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


import Fabric
import Crashlytics
import FirebaseAnalytics
import Firebase
import AppsFlyerLib
import Repro

protocol AnalyticsManagerProtocol {
    func initialize()
    func send(withScreenName screenName: String)
    func send(withUserId userId: String)
    func send(withCategory category: String, action inAction: String, label inLabel: String, value inValue: Int, andOptions options: [String: Any])
}

class GoogleAnalyticsManager: AnalyticsManagerProtocol {
    private let googleAnaliticsTrackingId: String = "UA-84216817-1"
    
    func initialize() {
        GAI.sharedInstance().trackUncaughtExceptions = true
        GAI.sharedInstance().dispatchInterval = 20.0

        #if DEBUG
            GAI.sharedInstance().logger.logLevel = .error
        #else
            GAI.sharedInstance().logger.logLevel = .none
        #endif

        let tracker = GAI.sharedInstance().tracker(withTrackingId: self.googleAnaliticsTrackingId)
        GAI.sharedInstance().defaultTracker = tracker
    }

    func send(withScreenName screenName: String) {
        GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: screenName)
        DBLog("screenName: \(screenName)")
    }

    func send(withUserId userId: String) {

    }

    func send(withCategory category: String, action inAction: String, label inLabel: String, value inValue: Int, andOptions options: [String: Any]) {
        let parameter: [AnyHashable: Any]? =
            GAIDictionaryBuilder.createEvent(withCategory: category,
                                              action: inAction,
                                              label: inLabel,
                                              value: NSNumber.init(value: inValue)).build() as? [AnyHashable : Any]
        GAI.sharedInstance().defaultTracker.send(parameter)
    }
}

class FabricAnalyticsManager: AnalyticsManagerProtocol {
    func initialize() {
        Fabric.with([Crashlytics.self()])

        #if DEBUG
            Fabric.sharedSDK().debug = true
        #else
            Fabric.sharedSDK().debug = false
        #endif
    }

    func send(withScreenName screenName: String) {
        Answers.logContentView(withName: "Screen View",
                               contentType: screenName,
                               contentId: nil,
                               customAttributes: nil)
    }

    func send(withUserId userId: String) {

    }

    func send(withCategory category: String, action inAction: String, label inLabel: String, value inValue: Int, andOptions options: [String: Any]) {
        Answers.logCustomEvent(withName: inAction, customAttributes: options)
    }
}

class AppsFlyerAnalyticsManager: AnalyticsManagerProtocol {
    func initialize() {
        AppsFlyerTracker.shared().appsFlyerDevKey = "4BgcTpAfE2VGkGXFs6VmtG"
        AppsFlyerTracker.shared().appleAppID = "1141332201"
    }

    func send(withScreenName screenName: String) {
        self.sendAFEventName(name: "screen_view", with: screenName)
    }

    private func sendAFEventName(name: String, with value: String = "") {
        AppsFlyerTracker.shared().trackEvent(name, withValues: [name: value])
    }

    func send(withUserId userId: String) {

    }

    func send(withCategory category: String, action inAction: String, label inLabel: String, value inValue: Int, andOptions options: [String: Any]) {
        AppsFlyerTracker.shared().trackEvent(inAction, withValues: options)
    }
}

class ReproAnalyticsManager: AnalyticsManagerProtocol {
    private let reproToken: String = "b44beb2d-71ad-4d44-9e78-f370aae594eb"

    func initialize() {
        Repro.setup(self.reproToken)
    }

    func send(withScreenName screenName: String) {
        Repro.track("Changed screen", properties: ["screen name": screenName])
    }

    func send(withUserId userId: String) {
        Repro.setUserID(userId)
    }

    func send(withCategory category: String, action inAction: String, label inLabel: String, value inValue: Int, andOptions options: [String: Any]) {
        Repro.track(inAction, properties: options)
    }
}

/**
 Google Analitics, Fabric, AppsFlyerなどを管理しています
 */

open class AnaliticsManager: NSObject {
    private static var allAnalytics: [AnalyticsManagerProtocol] = [
        GoogleAnalyticsManager(),
        FabricAnalyticsManager(),
        AppsFlyerAnalyticsManager(),
        ReproAnalyticsManager()
    ]
    
    class func initializeAnalytics() {
        for analytics in self.allAnalytics {
            analytics.initialize()
        }
    }

    class func sendScreenName(_ screenName: String) {
        for analytics in self.allAnalytics {
            analytics.send(withScreenName: screenName)
        }
    }

    class func sendUserId(_ userId: String) {
        for analytics in self.allAnalytics {
            analytics.send(withUserId: userId)
        }
    }
    
    class func sendAction(_ category: String, actionName: String, label: String, value: NSNumber, dic: [String: AnyObject]) {
        for analytics in self.allAnalytics {
            analytics.send(withCategory: category, action: actionName, label: label, value: value.intValue(), andOptions: dic)
        }

        FIRAnalytics.logEvent(withName: actionName, parameters: dic as? [String: NSObject])
    }
    
    class func sendEventName(name: String) {
        self.sendFabricEventName(name: name)
    }

    private class func sendFabricEventName(name: String) {
        Answers.logCustomEvent(withName: name, customAttributes: ["name": name])
    }

    class func trackAppFlayerLaunch() {
        AppsFlyerTracker.shared().trackAppLaunch()
    }
}
