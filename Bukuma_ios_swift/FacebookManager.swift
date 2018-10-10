//
//  FacebookManager.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON

//Facebook 

public struct Facebook {
    
    struct Picture {
        var is_silhouette: Bool?
        var urlString: String?
        var url: URL?
        
        init(dic: [String: AnyObject]?) {
            is_silhouette = dic?["is_silhouette"] as? Bool
            urlString = dic?["url"].flatMap{String(describing: $0)}
            if let string = urlString {
                url = URL(string: string)
            }
        }
    }
    
    var id: String?
    var nickname: String?
    var firstname: String?
    var picture: Picture?
    var email: String?
    var facebookFriendIds: Array<AnyObject>?
    var facebookFriendCount: Int?
    var facebookFriendId: String?
    
    public init() {
        
    }
    
    public init(dictionary: [String : AnyObject]?) {
        id = dictionary?["id"].map{String(describing: $0)}
        firstname = dictionary?["first_name"].map{String(describing: $0)}
        nickname = firstname
        email = dictionary?["email"].map{String(describing: $0)}
        picture = Picture(dic: dictionary?["picture"]?["data"] as? [String : AnyObject])
    }
    
    public func getUserFromFacebook() ->User {
        let user: User = User()
        user.identifier = self.id
        user.nickName = self.nickname
        user.photo = Photo(imageUrl: URL(string: self.picture!.urlString!))
        return user
    }
}

open class FacebookManager: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    var facebook: Facebook?
    var manager: FBSDKLoginManager?
    
    open class var sharedManager: FacebookManager{
        struct Static {
            static let instance = FacebookManager()
        }
        return Static.instance
    }
    
    override public init() {
        super.init()
        manager = FBSDKLoginManager()
    }
    
    // Facebookログイン
    open func loginFacebook(_ fromViewController: UIViewController?, completion: @escaping (_ error: Error?) ->Void) {
        manager?.logIn(withReadPermissions: ["email"],
                                          from: fromViewController,
                                          handler: { (result, error) in
                                            if error != nil {
                                                let nError: Error = self.errorWithFacebookError(error! as NSError)
                                                DBLog(nError)
                                                completion(nError)
                                                return
                                            }
                                            DBLog("facebook login result sucsess: \(String(describing: result))")
                                            
                                            if (result?.isCancelled ?? false) {
                                                return
                                            }
                                            Me.sharedMe.facebookAcsessToken = result?.token.tokenString
                                            
                                            completion(nil)
        })
    }
    
     // FacebookのUser情報GET
    open func getFacebookUser(_ completion: @escaping (_ facebook: Facebook?, _ error: Error?) ->Void) {
        let reqest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name,email,gender,picture,first_name"])
        reqest.start { (connection, result, error) in
            if error != nil {
                let nError: Error = self.errorWithFacebookError(error! as NSError)
                DBLog(nError)
                completion(nil, nError)
                return
            }
            DBLog(result)
            
            let facebook: Facebook = Facebook(dictionary: result as? [String : AnyObject])
            completion(facebook, nil)
        }
    }
    
    //Facebookのでかいprofile icon GET
    open func getFacebookLargeImage(_ completion:@escaping (_ facebook: Facebook?, _ error: Error?) ->Void) {
        let reqest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "picture.type(large)"])
        reqest.start { (connection, result, error) in
            if error != nil {
                let nError: Error = self.errorWithFacebookError(error! as NSError)
                DBLog(nError)
                completion(nil, nError)
                return
            }
            DBLog(result)
            let facebook: Facebook = Facebook(dictionary: result as? [String : AnyObject])
            completion(facebook, nil)
        }
    }
    
    // serverにこのfacebookアカウントが登録されているかどうか問い合わせている。
    open func checkSnsAlreadyExsistence(_ uid: String, completion: @escaping (_ exsistence: Bool, _ error: Error?) ->Void)  {
        var params: [String: Any] = [:]
        params["provider"] = "facebook"
        params["uid"] = uid
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/users/check_sns_status",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        completion(true, nil)
                                    } else {
                                        DBLog(error)
                                        
                                        completion(false, error)
                                    }
        }
    }
    
    func logout() {
        manager?.logOut()
    }
    
    open func errorWithFacebookError(_ error: NSError) ->Error {
        let error: Error = Error(FcaebookErrorCode: error.code)
        return error
    }
}
