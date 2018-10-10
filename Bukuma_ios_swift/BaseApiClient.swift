//
//  BKMBaseApiClient.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/08.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/**
 このClassではAPIの利用を共通化しています
 例えば、どのendpointもheaderの情報が必要なのでaddしたり
 継承先でbaseURL,apiKeyを設定してあげてください
 APIClient Classを参照してください
 */

public protocol BaseApiClientProtocol {
    static func baseURL() ->String
}

open class BaseApiClient: SessionManager {
        
    open class func baseURL() ->String? {
        return nil
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
    
    open class var sharedClient: BaseApiClient {
        struct Static {
            static let instance = BaseApiClient()
        }
        return Static.instance
    }
    
    fileprivate func requestString(_ endpoint: String) ->String {
        let currentClass: BaseApiClient.Type = ApiClient.self
        return currentClass.baseURL()! + endpoint
    }
    
    var getRetryCounter: Int = 0
    open func GET(_ endpoint: String, parameters: [String: Any]?, completion: @escaping (_ responceObject: [String: Any]?, _ error: Error?) ->Void){
        
        
        weak var weakSelf = self
        guard let weak = weakSelf else { return }
        _ = {() -> () in
            if weak.getRetryCounter > 5 {
                weak.getRetryCounter = 0
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(Double(weakSelf!.getRetryCounter) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                weak.request(weak.requestString(endpoint), method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: weak.headers)
            })
        }
        
        Alamofire.SessionManager.default.request(requestString(endpoint),
                                                 method: HTTPMethod.get,
                                                 parameters: parameters,
                                                 encoding: URLEncoding.default,
                                                 headers: headers)
            .responseJSON { (response) in
                if let error = self.handleResponse(response) {
                    completion(nil, error)
                    return
                }
                switch response.result {
                case .success(let value):
                    guard let resp: [String: Any] = SwiftyJSON.JSON(value).dictionaryObject else {
                        completion(nil, nil)
                        return
                    }
                    let er: String? = resp["result"].map{String(describing: $0)}
                    if er == "error" {
                        guard let path = response.response?.url else {
                            completion(nil, nil)
                            return
                        }
                        weakSelf?.getRetryCounter = 0
                        let error: Error = Error(errorDic: resp, path: path)
                        error.postNotification()
                        completion(nil, error)
                        return
                    }
                    completion(resp, nil)
                    break
                case .failure(let error as NSError):
                    weakSelf?.getRetryCounter = 0
                    let costomError: Error = Error(domain: ErrorDomain, code: error.code, userInfo: error.userInfo)
                    costomError.postNotification()
                    completion(nil, costomError)
                    break
                default:
                    break
                }
        }
    }
    
    open func get(_ endpoint: String, parameters: [String: Any]? = nil, completion: @escaping (SwiftyJSON.JSON, Error?) ->Void){
        
        Alamofire.SessionManager.default.request(requestString(endpoint),
                                                 method: HTTPMethod.get,
                                                 parameters: parameters,
                                                 encoding: URLEncoding.default,
                                                 headers: headers)
            .responseJSON { (response) in
                if let error = self.handleResponse(response) {
                    completion(SwiftyJSON.JSON.null, error)
                    return
                }
                switch response.result {
                case .success(let value):
                    let json = SwiftyJSON.JSON(value)
                    
                    if json["result"].string == "error" {
                        let error: Error = Error(json: json, path: response.response?.url)
                        error.postNotification()
                        completion(SwiftyJSON.JSON.null, error)
                        return
                    }
                    completion(json, nil)
                    break
                case .failure(let error as NSError):
                    let customError: Error = Error(domain: ErrorDomain, code: error.code, userInfo: error.userInfo)
                    customError.postNotification()
                    completion(SwiftyJSON.JSON.null, customError)
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
                if let error = self.handleResponse(responce) {
                    completion(nil, error)
                    return
                }
                switch responce.result {
                case .success(let value):
                    guard let resp: [String: Any] = SwiftyJSON.JSON(value).dictionaryObject else {
                        completion(nil, nil)
                        return
                    }
                    let er: String? = resp["result"].map{String(describing: $0)}
                    if er == "error" {
                        guard let path = responce.response?.url else {
                            completion(nil, nil)
                            return
                        }
                        let error: Error = Error(errorDic: resp, path: path)
                        error.postNotification()
                        completion(nil, error)
                        return
                    }
                    completion(resp, nil)
                    break
                case .failure(let error as NSError):
                    let costomError: Error = Error(domain: ErrorDomain, code: error.code, userInfo: error.userInfo)
                    costomError.postNotification()
                    completion(nil, costomError)
                    break
                default:
                    break
                }
        }
    }
    
    open func DELETE(_ endpoint: String, parameters: [String: Any]?, completion: @escaping (_ responceObject: [String: Any]?, _ error: Error?) ->Void) {
        
        Alamofire.SessionManager.default.request(requestString(endpoint),
                                                 method: HTTPMethod.delete,
                                                 parameters: parameters,
                                                 encoding: JSONEncoding.default,
                                                 headers: headers)
            .responseJSON { (response) in
                if let error = self.handleResponse(response) {
                    completion(nil, error)
                    return
                }
                switch response.result {
                case .success(let value):
                    guard let resp: [String : Any] = SwiftyJSON.JSON(value).dictionaryObject else {
                        completion(nil, nil)
                        return
                    }
                    let er: String? = resp["result"].map{String(describing: $0)}
                    if er == "error" {
                        guard let path = response.response?.url else {
                            completion(nil, nil)
                            return
                        }
                        let error: Error = Error(errorDic: resp, path: path)
                        error.postNotification()
                        completion(nil, error)
                        return
                    }
                    completion(resp, nil)
                    break
                case .failure(let error as NSError):
                    let costomError: Error = Error(domain: ErrorDomain, code: error.code, userInfo: error.userInfo)
                    costomError.postNotification()
                    completion(nil, costomError)
                    break
                default:
                    break
                }
        }
    }
    
    open func POST(_ endpoint: String, parameters: [String: Any]?,iconImage:UIImage?, completion: @escaping (_ responceObject: [String: Any]?, _ error: Error?) ->Void) {
        
        Alamofire.SessionManager.default.upload(multipartFormData: { (multipartFormData) in
            if iconImage != nil {
                let iconData = UIImageJPEGRepresentation(iconImage!, 1.0)
                
                multipartFormData.append(iconData!, withName: "profile_icon", fileName: "profile_icon.jpg", mimeType: "image/jpeg")
            }
            if parameters != nil {
                for (key, value) in parameters! {
                    if value is String {
                        multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                    }
                    if value is Int || value is NSNumber {
                        multipartFormData.append(String(describing: value).data(using: String.Encoding.utf8)!, withName: key)
                    }
                }
            }
        }, usingThreshold: 0,
           to: requestString(endpoint),
           method: .post,
           headers: headers) { (encodingResult) in
            switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let error = self.handleResponse(response) {
                            completion(nil, error)
                            return
                        }
                        guard let resp: [String: Any] = SwiftyJSON.JSON(response.result.value as Any).dictionaryObject else {
                            completion(nil, nil)
                            return
                        }
                        let er: String? = resp["result"].map{String(describing: $0)}
                        if er == "error" {
                            guard let path = response.response?.url else {
                                completion(nil, nil)
                                return
                            }
                            let error: Error = Error(errorDic: resp, path: path)
                            error.postNotification()
                            completion(nil, error)
                            return
                        }
                        completion(resp, nil)
                    }
                case .failure(let encodingError):
                    let costomError: Error? = encodingError as? Error
                    costomError?.postNotification()
                    completion(nil, costomError)
                    break
//                default:
//                    break
            }
        }
        
        
    }
    
    open func POST(_ endpoint: String, parameters: [String: Any]?,iconImages:[(name: String, fileName: String, image: UIImage)]?, completion: @escaping (_ responceObject: [String: Any]?, _ error: Error?) ->Void) {
        
        Alamofire.SessionManager.default.upload(multipartFormData: { (multipartFormData) in
            if iconImages != nil {
                for tapple in iconImages! {
                    let iconData = UIImageJPEGRepresentation(tapple.image, 1.0)
                    multipartFormData.append(iconData!, withName: tapple.name, fileName: tapple.fileName, mimeType: "image/jpeg")
                }
            }
            
            for (key, value) in parameters! {
                if value is String {
                    multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                }
                if value is Int || value is NSNumber {
                    multipartFormData.append(String(describing: value).data(using: String.Encoding.utf8)!, withName: key)
                    
                }
            }
            
            }, usingThreshold: 0,
               to: requestString(endpoint),
               method: .post,
               headers: headers) { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let error = self.handleResponse(response) {
                            completion(nil, error)
                            return
                        }
                        guard let resp: [String: Any] = SwiftyJSON.JSON(response.result.value as Any).dictionaryObject else {
                            completion(nil, nil)
                            return
                        }
                        let er: String? = resp["result"].map{String(describing: $0)}
                        if er == "error" {
                            guard let path = response.response?.url else {
                                completion(nil, nil)
                                return
                            }
                            let error: Error = Error(errorDic: resp, path: path)
                            error.postNotification()
                            completion(nil, error)
                            return
                        }
                        completion(resp, nil)
                    }
                case .failure(let encodingError):
                    let costomError: Error? = encodingError as? Error
                    costomError?.postNotification()
                    completion(nil, costomError)
                    break
//                default:
//                    break
                }
        }
    }
    
    func cancel() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (task, uploadTask, downloadTask) in
            task.forEach{$0.cancel()}
        }
    }
    
    private func handleResponse(_ response: DataResponse<Any>) -> Error? {
        var error: Error?
        if response.response?.statusCode == 503 {
            error = Error(type: .serviceUnavailable)
        }
        error?.postNotification()
        
        return error
    }
}
