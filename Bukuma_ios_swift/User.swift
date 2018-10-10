//
//  User.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

let BlockingUserCacheKey = "BlockingUserCacheKey"

public struct Password {
    var currentPassword: String?
    var confirmPassword: String?
    var newPassword: String?
    
    func isConfirmedPassword() -> Bool? {
        return currentPassword == confirmPassword
    }
}

public struct Email {
    var currentEmail: String?
    var confirmEmail: String?
    var newEmail: String?
}

public struct Phone {
    var currentPhoneNumber: String?
    var confirmPhoneNumber: String?
    var newPhoneNumber: String?
    var codeFromSMS: String?
}

enum Gender {
    case male
    case femail
    case other
    case old

    func int() -> Int {
        switch self {
        case .male: return 3
        case .femail: return 2
        case .old: return 1
        default: return -1
        }
    }

    func string() -> String {
        switch self {
        case .male: return "男性"
        case .femail: return "女性"
        default: return "無回答/その他"
        }
    }

    static var strings: [String] {
        return [Gender.male.string(), Gender.femail.string(), Gender.other.string()]
    }

    static var placeholderString: String {
        return "未入力(任意)"
    }

    static func gender(fromGenderValue genderValue: Int) -> Gender {
        switch genderValue {
        case self.male.int(): return .male
        case self.femail.int(): return .femail
        default: return .other
        }
    }

    static func gender(fromGenderString genderString: String) -> Gender {
        switch genderString {
        case self.male.string(): return .male
        case self.femail.string(): return .femail
        default: return .other
        }
    }
}

/**
 User Object
*/

open class User: BaseModelObject {
    var identifier: String? ///id
    var nickName: String? ///名前
    var gender: Int? ///性別
    var age: NSNumber? ///年齢。ただ、ageは使ってない。登録もしていない。今後updateで使いたいなどの時用
    var bio: String? ///自己紹介
    var createdAt: Date? ///アカウント作成日時
    var updatedAt: Date?///アカウント更新日時
    var email: Email? = Email() ///emailの情報
    var phone: Phone? = Phone() ///phoneの情報
    var password: Password? = Password() ///passwordの情報
    var photo: Photo? = Photo() ///profile iconの情報
    var facebook: Facebook? = Facebook() /// facebookの情報
    var adress: Adress? ///お届け先住所
    var card: CreditCard? ///クレジット情報
    var invitationCode: String? ///招待Code
    var goodReviewCount: String? ///GoodなReviewの数
    var normalReviewCount: String? ///NormalなReviewの数
    var badReviewCount: String? ///BadなReviewの数
    var merchandisesCount: String? ///userが出品している総数
    var isOfficial: Bool? ///公式ユーザーかどうか
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {        
        identifier = attributes?["id"].map{String(describing: $0)}
        gender = attributes?["gender"] as? Int
        nickName = attributes?["nickname"].map{String(describing: $0)}
        email = Email(currentEmail: attributes?["email"].map{String(describing: $0)}, confirmEmail: nil, newEmail: nil)
        bio = attributes?["biography"].map{String(describing: $0)}
        
        attributes?["profile_icon"].map{photo = Photo.init(imageUrl: URL(string:String(describing: $0)))}
        attributes?["created_at"].map{createdAt = Date(timeIntervalSince1970: Double(Int(String(describing: $0))!))}
        attributes?["updated_at"].map{updatedAt = Date(timeIntervalSince1970: Double(Int(String(describing: $0))!))}
        
        goodReviewCount = attributes?["mood_positive"].map{ String(describing: $0) }
        normalReviewCount = attributes?["mood_soso"].map{ String(describing: $0) }
        badReviewCount = attributes?["mood_negative"].map{ String(describing: $0) }
        
        merchandisesCount = attributes?["merchandises_count"].map{ String(describing: $0) }
        
        isOfficial = attributes?["is_official"] as? Bool
    }
    
    func updateProperty(_ newUser: User) {
        identifier = newUser.identifier
        nickName = newUser.nickName
        email = newUser.email
        bio = newUser.bio
        gender = newUser.gender
        photo = newUser.photo
        
        goodReviewCount = newUser.goodReviewCount
        normalReviewCount = newUser.normalReviewCount
        badReviewCount = newUser.badReviewCount
        
        merchandisesCount = newUser.merchandisesCount
        
        isOfficial = newUser.isOfficial
    }
    
    func genderString() ->String {
        return Gender.gender(fromGenderValue: self.gender ?? Gender.other.int()).string()
    }
    
    func gender(fromRow row: Int) ->Int {
        switch row {
        case 0:
            return Gender.male.int()
        case 1:
            return Gender.femail.int()
        default:
            return Gender.other.int()
        }
    }
    
    func isOldGender() ->Bool {
        if gender == Gender.old.int() {
            return true
        }
        return false
    }
    
    ///idを送ってuserを取得
    open func getUserInfo(_ completion: @escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/users/\(self.identifier ?? "")",
                                   parameters: [:]) {[weak self] (responceObject, error) in
                                    
                                    if error == nil {
                                        DBLog(responceObject)
                                        let user: User = User(dictionary: responceObject?["user"] as? [String: AnyObject])
                                        self?.updateProperty(user)
                                        completion(nil)
                                    } else {
                                        
                                        DBLog(error)
                                        completion(error)
                                    }
        }
    }
    
     ///userの保持しているpointを再計算するapi
    open class func recalculatePoint(_ completion: @escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.POST("v1/users/recalculate_point",
                                    parameters: [:]) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            completion(nil)
                                        } else {
                                            SBLog(error!)
                                            completion(error)
                                            
                                        }
        }
    }
    
     ///userを通報
    open func reportUser(_ reason: String?, completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["reportable_type"] = "User"
        params["reportable_id"] = self.idString(identifier).int()
        params["reason"] = reason
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/reports/create",
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
    ///ブロックする
    open func blockUser(_ completion: @escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.POST("v1/block_users/\(self.idString(identifier))/block",
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
    
    ///ブロック解除
    open func unblockUser(_ completion: @escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.POST("v1/block_users/\(self.idString(identifier))/unblock",
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
    ///ブロックしているユーザー一覧取得
    open class func getBlockUserList(_ page: Int, completion: @escaping (_ users: [User]?, _ error: Error?) ->Void) {
    
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 20
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/block_users",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        if responceObject?["block_users"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonAray: [AnyObject] = responceObject!["block_users"] as! [AnyObject]
                                        
                                        if page == 1 {
                                            JSONCache.cacheArray(jsonAray, key: BlockingUserCacheKey)
                                        }

                                        let jsonDic: [[String: AnyObject]] = jsonAray as! [[String: AnyObject]]
                                        
                                        let users: [User] = jsonDic.map({ (dic) in
                                            let user: User = User(dictionary: dic["target"] as? [String: AnyObject])
                                            return user
                                        })
                                        
                                        completion(users, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
                                    
        }
    }
}
