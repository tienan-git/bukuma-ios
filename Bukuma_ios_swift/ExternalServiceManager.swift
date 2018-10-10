//
//  ExternalServiceManager.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/08.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

/**
 appのsetting情報を取ってきています
 大切なことは
 is_on_batiが1でかつlatest_versionがアプリのversionと一致しているとき
 招待コードの画面を出していないことです
 Apple対策です
 招待コードは基本規約違反行為なのでバレたら消されます
 なぜis_on_batiという名前なのかというと、Appleから推測しにくい名前でかつぼくの名前だからです
 */

let ServiceManagerIsOnBatiNotification = "ServiceManagerIsOnBatiNotification"
let ServiceManagerInitialpointNotification = "ServiceManagerInitialpointNotification"

class ExternalServiceManager {
    static var isOnBati: Bool = true
    static var latestVersion: String?
    static var initialPoint: Int = 0
    static var invitationPoint: Int = 0
    static var isMaintenance: Bool = false
    static var maintenanceTime: String?
    static var maintenanceURL: String?
    static var csMessage: String?
    static var transferFee: Int = 0
    static var needTrasferFee: Int = 0
    static var minApplicableAmount: Int = 0
    static var maxApplicableAmount: Int = 0
    static var salesCommissionPercent: Int = 0
    static var salesCommissionDate: String?
    static var minPrice: Int = 0
    static var maxPrice: Int = 0

    static var updateDate: Date? // nil じゃなければ、最後の syncExternalValues は成功

    class func syncExternalValues(_ completion: ((_ error: Error?)-> Void)?) {
        var path = ""
        var versionKey = ""
        #if DEBUG
            path = "bukuma_stg"
            versionKey = "latest_app_version"
        #elseif STAGING
            path = "bukuma_stg"
            versionKey = "latest_app_version"
        #else
            path = "bukuma_from_v1_5"
            versionKey = "latest_version"
        #endif

        BannerManager.sharedManager.GET("apps/\(path)", parameters: [:]) { (responceObject, error) in
            if error == nil {
                DBLog(responceObject)

                guard let wholeData = responceObject?["app"] as? [String: AnyObject] else {
                    self.updateDate = nil
                    let err = Error(domain: "", code: -999, userInfo: nil)
                    completion?(err)
                    return
                }
                guard let externalData = wholeData["settings"] as? [String: AnyObject] else {
                    self.updateDate = nil
                    let err = Error(domain: "", code: -998, userInfo: nil)
                    completion?(err)
                    return
                }

                let isOnBati = externalData["is_on_bati"] as? String
                self.latestVersion = externalData[versionKey] as? String
                self.isOnBati = isOnBati == "1" && self.latestVersion == Utility.appVersionString()

                let initialPoint = externalData["initial_point"] as? String
                self.initialPoint = initialPoint?.int() ?? 0

                let invitationPoint = externalData["invitation_point"] as? String
                self.invitationPoint = invitationPoint?.int() ?? 0

                let isMaintenance = externalData["is_maintenanced"] as? String
                self.isMaintenance = isMaintenance == "1"
                self.maintenanceTime = externalData["maintenancing_time"] as? String
                self.maintenanceURL = externalData["maintenance_url"] as? String

                self.csMessage = externalData["contact_form_message"] as? String

                let transferFee = externalData["transfer_fee"] as? String
                self.transferFee = transferFee?.int() ?? 0

                let needTrasferFee = externalData["need_trasfer_fee"] as? String
                self.needTrasferFee = needTrasferFee?.int() ?? 0

                let minApplicableAmount = externalData["min_applicable_amount"] as? String
                self.minApplicableAmount = minApplicableAmount?.int() ?? 0

                let maxApplicableAmount = externalData["max_applicable_amount"] as? String
                self.maxApplicableAmount = maxApplicableAmount?.int() ?? 0

                let salesCommissionPercent = externalData["sales_commission_percent"] as? String
                self.salesCommissionPercent = salesCommissionPercent?.int() ?? 0

                let salesCommissionDate = externalData["sales_commission_date"] as? String
                self.salesCommissionDate = salesCommissionDate

                let minPrice = externalData["min_price"] as? String
                self.minPrice = minPrice?.int() ?? 0

                let maxPrice = externalData["max_price"] as? String
                self.maxPrice = maxPrice?.int() ?? 0

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ServiceManagerIsOnBatiNotification), object: nil)

                self.updateDate = Date()
                completion?(nil)
            } else {
                self.updateDate = nil
                completion?(error)
            }
        }
    }
}
