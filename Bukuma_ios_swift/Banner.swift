//
//  Banner.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/11.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

open class Banner: BaseModelObject {
    var imageUrl: URL?
    var contentUrl: URL?
    var position: Int?
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        attributes?["banner_url"].map{ imageUrl = URL(string:String(describing: $0)) }
        attributes?["url"].map{ contentUrl = URL(string:String(describing: $0)) }
        attributes?["position"].map{ position = String(describing: $0).int() }
    }
    
    class func getBanners(_ completion: @escaping (_ banners: [Banner]?, _ error: Error?) ->Void) {
        var path: String = ""
        #if DEBUG
            path = "bukuma_stg"
        #elseif STAGING
            path = "bukuma_stg"
        #else
            path = "bukuma_from_v1_5"
        #endif

        BannerManager.sharedManager.GET("apps/\(path)/banners",
                                        parameters: [:]) { (responceObject, error) in
                                            if error == nil {
                                                DBLog(responceObject)
                                                if responceObject?["banners"] == nil {
                                                    completion(nil, nil)
                                                    return
                                                }
                                                
                                                let jsonArray = SwiftyJSON.JSON(responceObject!["banners"]!).arrayObject!
                                                
                                                let jsonDic = jsonArray as! [[String: AnyObject]]
                                                var banners: [Banner] = jsonDic.map({ (dic) in
                                                    let banner: Banner = Banner(dictionary: dic)
                                                    return banner
                                                })
                                                banners = banners.sorted(by: { $0.position! < $1.position! } )
                                                Banner.bannersCount = banners.count

                                                completion(banners, nil)
                                            } else {
                                                DBLog(error)
                                                
                                                completion(nil, error)
                                            }
        }
    }
    
    static var bannersCount: Int = 0
}
