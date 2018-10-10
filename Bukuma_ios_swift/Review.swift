//
//  Review.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

public enum ReviewType: Int {
    case good = 1
    case normal = 0
    case bad = -1
    
    func typeFromTag(_ buttonTag: Int) ->Int {
        if buttonTag == 0 {
            return 1
        }
        if buttonTag == 1 {
            return 0
        }
        
        if buttonTag == 2 {
            return -1
        }
        return 0
    }
}

open class Review: BaseModelObject {
    
    var id: String?
    var score: String?
    var comment: String?
    var updatedAt: NSDate?
    var createdAt: NSDate?
    var user: User?
    var type: ReviewType?
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        id = attributes?["id"].map{String(describing: $0)}
        score = attributes?["score"].map{String(describing: $0)}
        attributes?["created_at"].map{createdAt = NSDate(timeIntervalSince1970: Double(Int(String(describing: $0))!))}
        attributes?["updated_at"].map{updatedAt = NSDate(timeIntervalSince1970: Double(Int(String(describing: $0))!))}
        
        comment = attributes?["comment"].map{String(describing: $0)}
        user = User(dictionary: attributes?["author"] as? [String: AnyObject])
        
        type = ReviewType(rawValue: attributes?["mood"] as? Int ?? 0)
        
    }
    
    open class func getReviewList(_ page: Int, userId: String?, completion: @escaping (_ reviews: [Review]?, _ error: Error?) ->Void) {
        if Utility.isEmpty(userId) == true {
            completion(nil, nil)
            return
        }
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50 
        params["order"] = "reverse"
        
        DBLog(params)
                
        ApiClient.sharedClient.GET("v1/reviews/users/\(userId!)",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        if responceObject!["reviews"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["reviews"]!).arrayObject!
                                        if page == 1 && Me.sharedMe.isMine(userId!) == true {
                                            JSONCache.cacheArray(jsonArray, key: ReviewListCacheKey)
                                        }
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        
                                        var reviews: [Review] = []
                                        for dic in jsonDic {
                                            let review: Review? = Review(dictionary: dic)
                                            reviews.append(review!)
                                        }
                        
                                        completion(reviews, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    open class func cachedReviewList() ->[Review]? {
        return self.cachedModelObjects(ReviewListCacheKey, modelClass: Review.self) as? [Review]
    }
}
