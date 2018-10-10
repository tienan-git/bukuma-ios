//
//  BannerManager.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/11.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

///need refactoring!!!!!! 
//WARN("refactor after release. now Preferentially speed")

open class BannerManager: NSObject {
    
    open class func baseURL() ->String? {
        return "https://banners.bukuma.io/api/"
    }
    
    open class func apiKey() ->String? {
        return nil
    }
    
    open var headers: [String: String] {
        get {
            return [
                "Authorization": "Bearer \(Token.sharedToken.accessToken != nil ? Token.sharedToken.accessToken! : "")",
                "Accept-Language": "ja",
                "Content-Type": "application/json"
            ]
        }
    }
    
    open class var sharedManager: BannerManager {
        struct Static {
            static let instance = BannerManager()
        }
        return Static.instance
    }
    
    fileprivate func requestString(_ endpoint: String) ->String {
        let currentClass = BannerManager.self
        return currentClass.baseURL()! + endpoint
    }

    open func GET(_ endpoint: String, parameters: [String: Any]?, completion: @escaping (_ responceObject: [String: Any]?, _ error: Error?) ->Void){
        Alamofire.SessionManager.default.request(requestString(endpoint),
                                                 method: HTTPMethod.get,
                                                 parameters: parameters,
                                                 encoding: URLEncoding.default,
                                                 headers: headers)
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    guard let resp: [String: Any] = SwiftyJSON.JSON(value).dictionaryObject else {
                        completion(nil, nil)
                        return
                    }
                    let er: String? = resp["result"].map{String(describing: $0)}
                    if er == "error" {
                        let error: Error = Error(errorDic: resp, path: response.response!.url!)
                        completion(nil, error)
                        return
                    }
                    completion(resp, nil)
                    break
                case .failure(let error as NSError):
                    let costomError: Error = Error(domain: ErrorDomain, code: error.code, userInfo: error.userInfo)
                    completion(nil, costomError)
                    break
                default:
                    break
                }
        }
    }
    
    open func POST(_ endpoint: String, parameters: [String: Any]?, completion: @escaping (_ responceObject: [String: Any]?, _ error: Error?) ->Void){
        
        Alamofire.request(requestString(endpoint),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        .responseJSON { (responce) in
            switch responce.result {
            case .success(let value):
                guard let resp: [String: Any] = SwiftyJSON.JSON(value).dictionaryObject else {
                    completion(nil, nil)
                    return
                }
                let er: String? = resp["result"].map{String(describing: $0)}
                if er == "error" {
                    let error: Error = Error(errorDic: resp, path: responce.response!.url!)
                    completion(nil, error)
                    return
                }
                completion(resp, nil)
                break
            case .failure(let error as NSError):
                let costomError: Error = Error(domain: ErrorDomain, code: error.code, userInfo: error.userInfo)
                completion(nil, costomError)
                break
            default:
                break
            }
        }
    }
}
