//
//  Omise.swift
//  Omise-iOS_SDK
//
//  Created by Anak Mirasing on 6/13/2558 BE.
//  Copyright (c) 2558 omise. All rights reserved.
//

import Foundation

public protocol OmiseRequestDelegate {
    func omiseOnSucceededToken(_ token: OmiseToken?)
    func omiseOnFailed(_ error: NSError?)
}

public enum OmiseApi: Int {
    case omiseToken = 1
}


open class Omise: NSObject, NSURLConnectionDelegate {
    
    var delegate: OmiseRequestDelegate?
    var data: NSMutableData?
    var mTokenRequest: TokenRequest?
    var isConnecting: Bool = false
    var requestingApi: Int?
    
    override init() {
        isConnecting = false
    }
    
    func requestToken(_ tokenRequest: TokenRequest?) {

        if isConnecting {
            let omiseError = NSError(domain: OmiseErrorDomain, code:OmiseErrorCode.omiseServerConnectionError.rawValue , userInfo: ["Connection error": "Running other request."])
            delegate?.omiseOnFailed(omiseError)
        }
        
        isConnecting = true
        requestingApi = OmiseApi.omiseToken.rawValue
        
        data = NSMutableData()
        mTokenRequest = tokenRequest
        
        let url = URL(string: "https://vault.omise.co/tokens")
        let OMISE_IOS_VERSION = "1.0.3"
        let req = NSMutableURLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        req.httpMethod = "POST"
        
        if let mTokenRequest = mTokenRequest {
            if let card = mTokenRequest.card {
                
                var city = ""
                var postalCode = ""
                
                if let userCity = card.city {
                    city = userCity
                }
                
                if let userPostalCode = card.postalCode {
                    postalCode = userPostalCode
                }
                
                let body = "card[name]=\(card.name!)&card[city]=\(city)&card[postal_code]=\(postalCode)&card[number]=\(card.number!)&card[expiration_month]=\(card.expirationMonth!)&card[expiration_year]=\(card.expirationYear!)&card[security_code]=\(card.securityCode!)"
                
                DBLog(body)
                
                req.httpBody = body.data(using: String.Encoding.utf8, allowLossyConversion: false)
                
                let loginString = "\(mTokenRequest.publicKey!):"
                let plainData = loginString.data(using: String.Encoding.utf8, allowLossyConversion: false)
                let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                let base64LoginData = "Basic \(base64String!)"
                let userAgentData = "OmiseIOSSwift/\(OMISE_IOS_VERSION)"
                req.setValue(base64LoginData, forHTTPHeaderField: "Authorization")
                req.setValue(userAgentData, forHTTPHeaderField: "User-Agent")
                let connection = NSURLConnection(request: req as URLRequest, delegate: self, startImmediately: false)
                connection?.start()
                
            }
        }
    }
    
    // MARK: - URLConnectionDelegate
    func connection(_ didReceiveResponse: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        data?.length = 0
    }
    
    private func connection(_ connection: NSURLConnection!, didReceiveData conData: Data!) {
        data?.append(conData)
    }
    
    open func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        var omiseError:NSError!
        if error.code == NSURLErrorTimedOut {
            omiseError = NSError(domain: OmiseErrorDomain, code: OmiseErrorCode.omiseTimeoutError.rawValue, userInfo: ["Request timeout": "Request timeout"])
        }else{
            omiseError = NSError(domain: OmiseErrorDomain, code: OmiseErrorCode.omiseServerConnectionError.rawValue, userInfo: ["Can not connect Omise server": "Check your parameter and internet connection."])
        }
        
        isConnecting = false
        delegate?.omiseOnFailed(omiseError)
    }
    
    open func connection(_ connection: NSURLConnection, didReceive challenge: URLAuthenticationChallenge) {
        
        if challenge.previousFailureCount > 0 {
            challenge.sender!.cancel(challenge)
            let error = NSError(domain: "error", code: Int.min, userInfo: nil)
            self.connection(connection, didFailWithError: error as! Error)
            
            let omiseError = NSError(domain: OmiseErrorDomain, code: OmiseErrorCode.omiseServerConnectionError.rawValue, userInfo: ["Connection error": "Authentication failed."])
            delegate?.omiseOnFailed(omiseError)
            return
        }
        
        if requestingApi == OmiseApi.omiseToken.rawValue {
            if let mTokenRequest = mTokenRequest {
                let credential = URLCredential(user: mTokenRequest.publicKey!, password: "", persistence: URLCredential.Persistence.forSession)
                challenge.sender!.use(credential, for: challenge)
            }
        }
    }
    
    open func connection(_ connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: URLProtectionSpace) -> Bool {
        return true
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        if let data = data {
            let responseText = NSString(data: data as Data, encoding:String.Encoding.utf8.rawValue)
            
            let jsonParser = JsonParser()
            var token: OmiseToken?
            
            if let requestingApi = requestingApi {
                switch (requestingApi) {
                case OmiseApi.omiseToken.rawValue:
                    token = jsonParser.parseOmiseToken(responseText!)
                    DBLog(responseText)
                    
                    if (token != nil) {
                        delegate?.omiseOnSucceededToken(token)
                    }else{
                        let omiseError = NSError(domain: OmiseErrorDomain, code: OmiseErrorCode.omiseBadRequestError.rawValue, userInfo: ["Invalid param": "Invalid public key or parameters."])
                        delegate?.omiseOnFailed(omiseError)
                    }
                    break
                    
                default:
                    break
                }
            }
        }
        isConnecting = false
    }
}
