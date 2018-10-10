//
//  Withdraw.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public enum WithdrawStatus: Int {
    case pending
    case completed
}

/**
 Withdraw Object
 売上きん申請などのObject
 */
open class Withdraw: BaseModelObject {
    
    var id: String?
    var status: String?
    var statusType: WithdrawStatus?
    var point: Point?
    var fee: Int?
    var createdAt: Date?
    var updatedAt: Date?
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        id = attributes?["id"].map{String(describing: $0)}
        status = attributes?["status"].map{String(describing: $0)}
        point = Point()
        point?.normalPoint = attributes?["point"] as? Int
        fee = attributes?["fee"] as? Int
    }
    
}
