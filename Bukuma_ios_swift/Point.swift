//
//  Point.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/19.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class Point: BaseModelObject {
    var normalPoint: Int?
    var bonusPoint: Int?
    var willExpireSales: Int = 0
    var willExpireBonus: Int = 0
    
    var usablePoint: String {
        if bonusPoint == nil {
            return 0.string()
        }
        return bonusPoint!.string()
    }
    
    var usableSales: String {
        if normalPoint == nil {
            return 0.string()
        }
        return normalPoint!.string()
    }
    
    open class func caluclatePurchasePoint(_ usablePoint: Int, price: Int) ->Int {
        return price - usablePoint
    }
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        willExpireSales = attributes?["normal_point"] as? Int ?? 0
        willExpireBonus = attributes?["bonus_point"] as? Int ?? 0
    }
    
    open class func getExpirePoint(_ day: Int, completion: @escaping (_ willExpirePoint: Int?) ->Void) {
        var params: [String: Any] = [:]
        params["number"] = 50
        params["day"] = day
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/point_transactions/expiring",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        if responceObject?["point_transactions"] == nil {
                                            completion(nil)
                                            return
                                        }
                                        
                                        let jsonArray = responceObject?["point_transactions"] as? [AnyObject]
                                       
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let points: [Int] = jsonDic.map({ (dic) in
                                            let point: Int = dic["remaining_point"] as! Int
                                            return point
                                        })
                                        
                                        let willExpirePoint: Int = points.reduce(0, +)
                                        
                                        completion(willExpirePoint)
                                    } else {
                                        DBLog(error)
                                        completion(nil)
                                    }
        }
    }
    
    open class func getExpirePoints(_ completion: @escaping (_ Point: Point?, _ error: Error?) ->Void) {
        
        var params: [String: Any] = [:]
        params["day"] = 90 
        
        DBLog(params)

        ApiClient.sharedClient.GET("v1/point_transactions/sum_expiring",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        let point: Point = Point.init(dictionary: responceObject as [String: AnyObject]?)
                                        completion(point, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
}
