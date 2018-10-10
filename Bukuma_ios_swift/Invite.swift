//
//  Invite.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/10.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class Invite: BaseModelObject {
    
    var id: String?
    var inviterId: String?
    var status: String?
    var total: String?
    var user: User?
    var updatedAt: Date?
    var createdAt: Date?
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        id = attributes?["id"].map{String(describing: $0)}
        inviterId = attributes?["inviter_id"].map{String(describing: $0)}
        status = attributes?["status"].map{String(describing: $0)}
        attributes?["created_at"].map{createdAt = Date(timeIntervalSince1970: Double(Int(String(describing: $0))!))}
        attributes?["updatedAt"].map{updatedAt = Date(timeIntervalSince1970: Double(Int(String(describing: $0))!))}
    }
    
    open class func getInviteList(_ completion: @escaping (_ invite: [Invite]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = 0
        params["number"] = 50
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/invites",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        if responceObject?["invite_logs"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = responceObject!["invite_logs"] as! [AnyObject]
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let invites: [Invite] = jsonDic.map({ (dic) in
                                            let invite: Invite? = Invite(dictionary: dic)
                                            invite?.total = responceObject?["total"].map{String(describing: $0)}
                                            return invite ?? Invite()
                                        })
                                        
                                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
                                        completion(invites, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)

                                    }
        }
    }
    
    open class func updateInviter(_ code: String, completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["invite_code"] = code 
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/invites/invite",
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
