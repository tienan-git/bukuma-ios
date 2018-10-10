//
//  Me.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON
import SDWebImage
import Crashlytics
import LUKeychainAccess
import FBSDKCoreKit
import FBSDKLoginKit
import AdSupport
import AppsFlyerLib

public let MeMyInfoUpdateKey = "MeMyInfoUpdateKey"
public let MeFirstRegisterkey = "MeFirstRegisterkey"
public let MeUUIDKey = "MeUUIDKey"

private let MeDefaultShipFromCacheKey = "MeDefaultShipFromCacheKey"
private let MeDefaultShipWayCacheKey = "MeDefaultShipWayCacheKey"
private let MeDefaultShipInCacheKey = "MeDefaultShipInCacheKey"
private let MeTwitterAccountsCacheKey = "MeTwitterAccountsCacheKey"
private let MeTwitterConnectedAccountCacheKey = "MeTwitterConnectedAccountCacheKey"
//private let MeShouldSuggestGenderKey = "MeShouldSuggestGenderKey"

/**
 Me Object
 自分の情報
 自分しか使わないAPI、ロジック保持
 
 */
open class Me: User {
    
    var addresses: Array<Adress>? {
        get {
            return Adress.cachedAdressList()
        }
    }
    
    var defaultAdress: Adress? {
        get {
            return Adress.defaultAdress()
        }
    }
    
    var creditCards: Array<CreditCard>? {
        get {
            return CreditCard.cachedCardList()
        }
    }
    
    var defaultCards: CreditCard? {
       return CreditCard.defaultCard()
    }
    
    var defaultShipFrom: String? {
        get {
            return UserDefaults.standard.string(forKey: MeDefaultShipFromCacheKey)
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: MeDefaultShipFromCacheKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var defaultShipWay: String? {
        get {
            let row: Int? = UserDefaults.standard.object(forKey: MeDefaultShipWayCacheKey) as? Int
            if row == nil {
                return nil
            }
            return Merchandise.shippingWays[row!]
        }
        //set Integer Value
        set (newValue) {
            UserDefaults.standard.set(newValue!.int(), forKey: MeDefaultShipWayCacheKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var defaultShipIn: String? {
        get {
            guard var row = UserDefaults.standard.object(forKey: MeDefaultShipInCacheKey) as? Int else {
                return nil
            }
            if row >= Merchandise.shippingDaysRangesLong.count {
                row = Merchandise.shippingDaysRangesLong.count - 1
            }
            return Merchandise.shippingDaysRangesLong[row]
        }
        //set Integer Value
        set (newValue) {
            UserDefaults.standard.set(newValue!.int(), forKey: MeDefaultShipInCacheKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    private var uuid: String {
        get {
            if let uuid = LUKeychainAccess.standard().string(forKey: MeUUIDKey) {
                return uuid
            }
            
            let uuid = Utility.generateUUID()
            LUKeychainAccess.standard().setString(uuid, forKey: MeUUIDKey)
            
            return uuid
        }
    }
    
    private var appVersion: String? {
        get {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }
    }
    
    private var osVersion: String {
        get {
            return UIDevice.current.systemVersion
        }
    }
    
    open func myShippingInfoAttribute() ->NSAttributedString? {
        
        let attributeString: NSMutableAttributedString = NSMutableAttributedString()
        
        let shipFrom: String = Me.sharedMe.defaultShipFrom!
        let shipInDay: String = Me.sharedMe.defaultShipIn!
        let shipWay: String = Me.sharedMe.defaultShipWay!
        
        let text: String = "\(shipFrom)から\(shipInDay)以内に\(shipWay)で発送します"
        let shippingString = NSMutableAttributedString(string: text)
        shippingString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14)], range: NSRange.init(location: 0, length: text.length))
        
        let shipFromRange = NSRange.init(location: 0, length: shipFrom.length)
        let shipInRange = NSRange.init(location: shipFrom.length  + 2,
                                       length: shipInDay.length)
        let shipWayRange = NSRange.init(location: shipFrom.length  + 2 + shipInDay.length + 3,
                                        length: shipWay.length)
        
        shippingString.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)], range: shipFromRange)
        shippingString.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)], range: shipInRange)
        shippingString.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)], range: shipWayRange)
        attributeString.append(shippingString)
        
        return attributeString
    }

    var facebookAcsessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: MeFacebookAcsessTokenCacheKey)
        }
        set(newV) {
            UserDefaults.standard.set(newV, forKey: MeFacebookAcsessTokenCacheKey)
        }
    }
    
    var isRegisterd: Bool? {
        get {
            return !Utility.isEmpty(self.identifier)
        }
    }
    
    var banned: Bool?
    var notification: Notification? = Notification()
    var verified: Bool?
    var paymentGatewayId: String?
    var point: Point?

    
    open class var sharedMe: Me {
        struct Static {
            static let instance = Me()
        }
        return Static.instance
    }
    
    ///自分の情報はUserDefaultに保存
    override public init() {
        super.init()
        let dic: [String: Any]? = JSONCache.cachedDicListWithKey(MeMyCacheInfoKey)
        DBLog("MeMyCacheInfoKey: \(String(describing: dic))")
        self.updatePropertyWithAttributes(dic as [String : AnyObject]?)
    }
    
    required public init(dictionary: [String : AnyObject]?) {
        fatalError("init(dictionary:) has not been implemented")
    }
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        super.updatePropertyWithAttributes(attributes)
        verified = attributes?["verified"] as? Bool
        attributes?["profile_icon"].map{ photo = Photo(imageUrl: URL(string:String(describing: $0))) }
        invitationCode = attributes?["invite_code"].map{String(describing: $0)}
        paymentGatewayId = attributes?["payment_gateway_id"].map{String(describing: $0)}
        point = Point()
        point?.normalPoint = attributes?["point"] as? Int
        point?.bonusPoint = attributes?["bonus_point"] as? Int
        
        phone = Phone()
        phone?.currentPhoneNumber =  attributes?["phone_number"].map{String(describing: $0)}
        
        banned = attributes?["banned"] as? Bool
        
    }
    
    ///user idをserverに送って自分の情報をgetして、propertyをupdateしている
    open func syncronizeMyProfileWithCompletion(_ completion:((_ error: Error?) ->Void)?) {
        ApiClient.sharedClient.GET("v1/users/\(self.identifier!)",
                                   parameters: [:]) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject!)
                                        
                                        self.updatePropertyWithAttributes(SwiftyJSON.JSON(responceObject!["user"]!).dictionaryObject as [String : AnyObject]?)
                                        JSONCache.cacheDic(SwiftyJSON.JSON(responceObject!["user"]!).dictionaryObject!, key: MeMyCacheInfoKey)
                                        completion?(nil)
                                        
                                    } else {
                                        completion?(error)
                                    }
        }
    }
    
    ///登録時に使うtimestampを取得
    open func registerTimeStamp(_ completion:@escaping (_ timeStamp: String?, _ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/users/timestamp",
                                   parameters: [:]) { (responce, error) in
                                    if error == nil {                                        
                                        let timeStamp = SwiftyJSON.JSON(responce!["time"]!).stringValue
                                        completion(timeStamp, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    ///emailとうろく
    open func registerUser(_ user: User, timeStamp: String?, completion:@escaping (_ error: Error?) ->Void) {
        
        let uuid = self.uuid
                
        var str: String = "\(ApiClient.apiKey()!)\(uuid)\(timeStamp!)bukumaZ1"
        str = str.md5(string: str)
        var params: [String: Any] = [:]
        
        params["nickname"] = user.nickName
        params["gender"] = user.gender
        params["email"] = user.email?.currentEmail
        params["password"] = user.password?.currentPassword
        params["provider"] = "email"
        
        //default bio value
        params["biography"] = "よろしくお願いします"
        
        params["timestamp"] = timeStamp
        params["uuid"] = uuid
        params["api_key"] = ApiClient.apiKey()!
        params["signed_info"] = str
        
        let iconImage: UIImage? = user.photo?.image
        
        DBLog(params)

        ApiClient.sharedClient.POST("v1/users/register",
                                    parameters: params,
                                    iconImage: iconImage) { [weak self] (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                            Token.sharedToken.accessToken = SwiftyJSON.JSON(responceObject!["access_token"]!).stringValue
                                            self?.identifier = SwiftyJSON.JSON(responceObject!["user_id"]!).stringValue
                                            AppsFlyerTracker.shared().customerUserID = self?.identifier ?? "-1"
                                            //self?.suggestedGender = true
                                            AnaliticsManager.sendAction("register_account",
                                                                        actionName: "register_account",
                                                                        label: "",
                                                                        value: 1,
                                                                        dic: ["provider":"email" as AnyObject])
                                            ChatRealtimeUpdater.sharedUpdater.startTracking()
                                            TransactionRealtimeUpdater.sharedUpdater.startTracking()
                                            ActivityRealtimeUpdater.sharedUpdater.startTracking()
                                            self?.syncronizeMyProfileWithCompletion({ (error) in
                                                if error == nil {
                                                    completion(nil)
                                                    Crashlytics.sharedInstance().setUserIdentifier(Me.sharedMe.identifier)
                                                    Crashlytics.sharedInstance().setUserName(Me.sharedMe.nickName)
                                                    Crashlytics.sharedInstance().setUserEmail(Me.sharedMe.email?.currentEmail)
                                                    Crashlytics.sharedInstance().setObjectValue(UIDevice.current.systemVersion, forKey: "os")
                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
                                                    return
                                                }
                                                completion(error)
                                            })
                                        } else {
                                            completion(error)
                                        }
                                        
        }
    }
    ///facebook登録
    open func registerUserWithFacebook(_ user: User, facebook: Facebook, timeStamp: String?, completion:@escaping (_ error: Error?) ->Void) {
        
        let uuid = self.uuid
        
        var str: String = "\(ApiClient.apiKey()!)\(uuid)\(timeStamp!)bukumaZ1"
        str = str.md5(string: str)

        var params: [String: Any] = [:]
        
        params["nickname"] = facebook.nickname
        params["gender"] = user.gender
        
        //default bio value
        params["biography"] = "よろしくお願いします"
        
        params["email"] = facebook.email
        params["password"] = user.password?.currentPassword
        params["provider"] = "facebook"
        
        params["timestamp"] = timeStamp!
        params["uuid"] = uuid
        params["api_key"] = ApiClient.apiKey()!
        params["signed_info"] = str
        
        params["access_token"] = Me.sharedMe.facebookAcsessToken!
        params["uid"] = facebook.id
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/users/register",
                                    parameters: params) { [weak self] (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            Token.sharedToken.accessToken = SwiftyJSON.JSON(responce!["access_token"]!).stringValue
                                            self?.identifier = SwiftyJSON.JSON(responce!["user_id"]!).stringValue
                                            //self?.suggestedGender = true
                                            AppsFlyerTracker.shared().customerUserID = self?.identifier ?? "-1"
                                            AnaliticsManager.sendAction("register_account",
                                                                        actionName: "register_account",
                                                                        label: "",
                                                                        value: 1,
                                                                        dic: ["provider":"facebook" as AnyObject])
                                            ChatRealtimeUpdater.sharedUpdater.startTracking()
                                            TransactionRealtimeUpdater.sharedUpdater.startTracking()
                                            ActivityRealtimeUpdater.sharedUpdater.startTracking()
                                            self?.syncronizeMyProfileWithCompletion({ (error) in
                                                if error == nil {
                                                    completion(nil)
                                                    Crashlytics.sharedInstance().setUserIdentifier(Me.sharedMe.identifier)
                                                    Crashlytics.sharedInstance().setUserName(Me.sharedMe.nickName)
                                                    Crashlytics.sharedInstance().setUserEmail(Me.sharedMe.email?.currentEmail)
                                                    Crashlytics.sharedInstance().setObjectValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"], forKey: "appversion")
                                                    Crashlytics.sharedInstance().setObjectValue(UIDevice.current.modelName, forKey: "modelname")
                                                    Crashlytics.sharedInstance().setObjectValue(UIDevice.current.systemVersion, forKey: "os")
                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
                                                    return
                                                }
                                                completion(error)
                                            })
                                        } else {
                                            
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    
    ///ユーザー情報update
    
    open func updateUserInfo(_ user: User, completion:@escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        
        params["nickname"] = user.nickName
        params["gender"] = user.gender
        params["email"] = Utility.isEmpty(user.email?.newEmail) ? user.email?.currentEmail : user.email?.newEmail
        params["biography"] = user.bio
        
        let iconImage: UIImage? = user.photo?.image
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/users/update",
                                    parameters: params,
                                    iconImage: iconImage) { [weak self] (responceObject, error) in
                                        if error == nil {
                                            ///self?.suggestedGender = true
                                            self?.syncronizeMyProfileWithCompletion({ (error) in
                                                if error == nil {
                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
                                                    completion(nil)
                                                    return
                                                }
                                                completion(error)
                                            })
                                        } else {
                                            completion(error)
                                        }
                                        
        }
    }
    
    /// facebookログイン
    open func singInWithSNSAccount(_ completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        
        params["provider"] = "facebook"
        params["access_token"] = self.facebookAcsessToken
        params["api_key"] = ApiClient.apiKey()
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/users/sign_in_with_sns",
                                    parameters: params) { (responceObject, error) in
                                        
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                            Token.sharedToken.accessToken = SwiftyJSON.JSON(responceObject!["access_token"]!).stringValue
                                            self.identifier = SwiftyJSON.JSON(responceObject!["user_id"]!).stringValue
                                            AppsFlyerTracker.shared().customerUserID = self.identifier ?? "-1"
                                            //self.suggestedGender = true
                                            self.syncronizeMyProfileWithCompletion({ (error) in
                                                if error == nil {
                                                    completion(nil)
                                                    Crashlytics.sharedInstance().setUserIdentifier(Me.sharedMe.identifier)
                                                    Crashlytics.sharedInstance().setUserName(Me.sharedMe.nickName)
                                                    Crashlytics.sharedInstance().setUserEmail(Me.sharedMe.email?.currentEmail)
                                                    Crashlytics.sharedInstance().setObjectValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"], forKey: "appversion")
                                                    Crashlytics.sharedInstance().setObjectValue(UIDevice.current.modelName, forKey: "modelname")
                                                    Crashlytics.sharedInstance().setObjectValue(UIDevice.current.systemVersion, forKey: "os")
                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
                                                    
                                            
                                                    return
                                                }
                                                completion(error)
                                            })
                                        } else {
                                            
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    
    ///emailログイン
    open func singInWithEmailAccount(_ timeStamp: String, user: User, completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        
        let uuid = self.uuid
        
        params["email"] = user.email?.currentEmail
        params["password"] = user.password?.currentPassword
        params["uuid"] = uuid
        params["timestamp"] = timeStamp
        params["api_key"] = ApiClient.apiKey()
        
        var str: String = "\(ApiClient.apiKey()!)\(uuid)\(timeStamp)bukumaZ1"
        str = str.md5(string: str)
        params["signed_info"] = str
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/users/sign_in_with_email",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                            Token.sharedToken.accessToken = SwiftyJSON.JSON(responceObject!["access_token"]!).stringValue
                                            self.identifier = SwiftyJSON.JSON(responceObject!["user_id"]!).stringValue
                                            //self.suggestedGender = false
                                            AppsFlyerTracker.shared().customerUserID = self.identifier ?? "-1"
                                            self.syncronizeMyProfileWithCompletion({ (error) in
                                                if error == nil {
                                                    completion(nil)
                                                    Crashlytics.sharedInstance().setUserIdentifier(Me.sharedMe.identifier)
                                                    Crashlytics.sharedInstance().setUserName(Me.sharedMe.nickName)
                                                    Crashlytics.sharedInstance().setUserEmail(Me.sharedMe.email?.currentEmail)
                                                    Crashlytics.sharedInstance().setObjectValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"], forKey: "appversion")
                                                    Crashlytics.sharedInstance().setObjectValue(UIDevice.current.modelName, forKey: "modelname")
                                                    Crashlytics.sharedInstance().setObjectValue(UIDevice.current.systemVersion, forKey: "os")
                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
                                                    return
                                                    
                                                }
                                                completion(error)
                                            })
                                            
                                        } else {
                                            DBLog(error)

                                            completion(error)
                                        }
        }
    }
    
    ///snsログイン
    open func connectSNS(_ completion:@escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["provider"] = "facebook"
        params["access_token"] = self.facebookAcsessToken
        
        ApiClient.sharedClient.POST("v1/users/sns/connect",
                                    parameters: params) { (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            
                                            completion(nil)
                                        } else {
                                            
                                            DBLog(error)
                                            
                                            completion(error)
                                        }
                                        
        }
    }
    
    ///facebook idを送ってユーザーの情報をゲット
    open func getUserInfoWithFacebookUID(_ facebook: Facebook , completion:@escaping (_ error: Error?) ->Void) {
        
        ApiClient.sharedClient.GET("v1/users/sns/\(facebook.id!)",
                                   parameters: [:]) { (responceObject, error) in
                                    if error != nil {
                                        completion(error)
                                        return
                                    }
                                    DBLog(responceObject.map{$0})
                                    
                                    self.updatePropertyWithAttributes(SwiftyJSON.JSON(responceObject!["user"]!).dictionaryObject as [String : AnyObject]?)
                                    JSONCache.cacheDic(SwiftyJSON.JSON(responceObject!["user"]!).dictionaryObject!, key: MeMyCacheInfoKey)
                                    completion(nil)
        }
    }
    
    ///Phone numberを送る
    open func veriftPhoneNumber(_ phone: Phone, completion:@escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        let phoneAttribute: NSMutableAttributedString = NSMutableAttributedString(string: phone.currentPhoneNumber!)
        phoneAttribute.deleteCharacters(in: NSMakeRange(0, 1))
        
        params["phone_number"] =  "+81\(phoneAttribute.string)"
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/users/phone_number",
                                    parameters: params) { (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            
                                            completion(nil)
                                        } else {
                                            
                                            DBLog(error)
                                            
                                            completion(error)
                                        }
        }
    }
    ///SMS認証
    open func smsVerifyPhoneNumber(_ sms: String, completion:@escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["code"] = sms
        
        ApiClient.sharedClient.POST("v1/users/phone_verify",
                                    parameters: params) { [weak self] (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            self?.syncronizeMyProfileWithCompletion({ (error) in
                                                if error == nil {
                                                    completion(nil)
                                                    return
                                                }
                                                completion(error)
                                            })
                                            
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
                                        
        }
    }
    ///電話認証
    open func requestPhoneCallVerification(_ completion:@escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.POST("v1/users/call_me_to_verify",
                                    parameters: [:]) { [weak self] (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            self?.syncronizeMyProfileWithCompletion({ (error) in
                                                if error == nil {
                                                    completion(nil)
                                                    return
                                                }
                                                completion(error)
                                            })
                                            
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
                                        
        }
    }
    
    ///パスワード変える
    open func changePassword(_ password: Password, completion:@escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        // facebookだったら no current password
        params["current_password"] = password.currentPassword
        params["new_password"] = password.newPassword
        
        ApiClient.sharedClient.POST("v1/users/change_password",
                                    parameters: params) { (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            
                                            completion(nil)
                                        } else {
                                            
                                            DBLog(error)
                                            
                                            completion(error)
                                        }
                                        
        }
    }
    
    ///退会
    open func delete(account reason: Reason,  _ completion:@escaping (_ error: Error?) ->Void) {
        var parameter: [String: Any] = [:]
        parameter["choice"] = reason.choice
        parameter["comment"] = reason.comment
        
        DBLog(parameter)
        
        ApiClient.sharedClient.DELETE("v1/users/destroy",
                                      parameters: parameter) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            self.clearAll()
                                            AnaliticsManager.sendAction("delete_account",
                                                                        actionName: "delete_account",
                                                                        label: "",
                                                                        value: 1,
                                                                        dic: ["reason": reason.deleteReason as AnyObject,
                                                                              "comment": reason.comment as AnyObject])
                                            completion(nil)
                                        } else {
                                            DBLog(error)
                                            
                                            completion(error)
                                        }
        }
    }
    
    ///退会した後に、設定している情報を全てclearする
    func clearAll() {
        self.clearMeInfo()
        ChatRealtimeUpdater.sharedUpdater.endTracking()
        TransactionRealtimeUpdater.sharedUpdater.endTracking()
        ActivityRealtimeUpdater.sharedUpdater.endTracking()
        _ = Message.deleteMessagesCache()
        ChatRoom.deleteRoomCache()
        FacebookManager.sharedManager.logout()
        FBSDKAccessToken.refreshCurrentAccessToken { (connection, any, error) in
            
        }
        for (key, _) in  UserDefaults.standard.dictionaryRepresentation() {
            if key == CategoryListCacheKey {
                continue
            }
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        let imageCache = SDImageCache.shared()
        imageCache.clearMemory()
        imageCache.clearDisk()
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: DataSourceForceRemoveAllMyExistense), object: self)
    }
    
    func clearMeInfo() {
        identifier = nil
        nickName = nil
        gender = nil
        email = nil
        phone = nil
        bio = nil
        verified = nil
        photo = nil
        invitationCode = nil
        paymentGatewayId = nil
        point = nil
        facebookAcsessToken = nil
        goodReviewCount = nil
        normalReviewCount = nil
        badReviewCount = nil
    }
    
    open func sendDeviceInfo(_ completion: ((_ error: Error?) -> Void)? = nil) {
        var params: [String: Any] = [:]
        params["device_type"] = "ios"
        params["uuid"] = uuid
        params["app_version"] = appVersion
        params["os_version"] = osVersion
        
        if let identifierManager = ASIdentifierManager.shared() {
            if identifierManager.isAdvertisingTrackingEnabled {
                params["advertising_id"] = identifierManager.advertisingIdentifier?.uuidString
                DBLog(params["advertising_id"])
            }
        }
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/devices/new",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                        } else {
                                            DBLog(error)
                                        }
                                        completion?(error)
        }
    }
    
    ///devicetokenを送る。push通知送信のために
    open func registerDeviceToken(_ deviceToken: Data?, completion: ((_ error: Error?) -> Void)?) {
        if deviceToken == nil {
            if completion != nil {
                completion!(nil)
            }
            return
        }
        
        DBLog(deviceToken)
        
        var params: [String: Any] = [:]
        params["device_token"] = RemoteNotification.transliterationDeviceToken(deviceToken!)
        params["device_type"] = "ios"
        params["uuid"] = uuid
        params["app_version"] = appVersion
        params["os_version"] = osVersion
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/devices/new",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
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
    
    ///ユーザーが設定しているnotificationsを取得
    open func getNotification(_ completion: ((_ error: Error?) -> Void)?) {
        ApiClient.sharedClient.GET("v1/users/notifications",
                                   parameters: [:]) { [weak self] (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        self?.notification = Notification(dic: responceObject?["notification_setting"] as? [String: AnyObject])
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
    ///ユーザーが設定しているnotificationsをupdate
    open func updateNotification(_ notification: String, isOn: Bool, completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["notification"] = notification
        params["on"] = isOn == true ? 1 : 0
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/users/notifications",
                                    parameters: params) {[weak self] (responceObject, error) in
                                        self?.getNotification(completion)
        }
    }
    
    func isMine(_ id: String) -> Bool? {
        return self.identifier == id
    }
    
    ///退会できるか否か。やることリストが一つでもあった場合できない処理
    func can(deleteAccount completion: @escaping (_ can: Bool) ->Void) {
        Transaction.getItemTransactionList(10, page: 0) { (transactions, error) in
            DispatchQueue.main.async {
                if error != nil {
                    completion(false)
                    return
                }
                if transactions != nil || (transactions?.count ?? 0) > 0 {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
    ///パスワードリセットメールを送る
    func resetPass(_ email: String, completion: @escaping (_ error: Error?) ->Void) {
        
        var params: [String: Any] = [:]
        params["email"] = email 
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/users/request_password",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            completion(nil)
                                            
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
                                        
        }
    }
}
