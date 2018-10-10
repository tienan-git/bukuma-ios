//
//  JsonParser.swift
//  Omise-iOS_SDK
//
//  Created by Anak Mirasing on 6/13/2558 BE.
//  Copyright (c) 2558 omise. All rights reserved.
//

import UIKit

open class JsonParser: NSObject {
    func parseOmiseToken(_ json: NSString)->OmiseToken? {
        
        var jsonObject: Any?
        do {
            jsonObject = try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8.rawValue)!, options: JSONSerialization.ReadingOptions.allowFragments)
        } catch _ {
            jsonObject = nil
        }
        
        if let jsonDict = jsonObject as? NSDictionary {
            let obj = jsonDict.object(forKey: "object") as? String
            if obj == "error" {
                return nil
            }
            
            let token = OmiseToken()
            token.tokenId = jsonDict.object(forKey: "id") as? String
            token.livemode = jsonDict.object(forKey: "livemode") as? Bool
            token.location = jsonDict.object(forKey: "location") as? String
            token.used = jsonDict.object(forKey: "used") as? Bool
            token.created = jsonDict.object(forKey: "created") as? String
            
            if let cardObject = jsonDict.object(forKey: "card") as? NSDictionary {

                token.card?.cardId = cardObject.object(forKey: "id") as? String
                token.card?.livemode = cardObject.object(forKey: "livemode") as? Bool
                token.card?.country = cardObject.object(forKey: "country") as? String
                token.card?.city = cardObject.object(forKey: "city") as? String
                token.card?.postalCode = cardObject.object(forKey: "postal_code") as? String
                token.card?.financing = cardObject.object(forKey: "financing") as? String
                token.card?.lastDigits = cardObject.object(forKey: "last_digits") as? String
                token.card?.brand = cardObject.object(forKey: "brand") as? String
                token.card?.expirationMonth = String(format: "%d", (cardObject.object(forKey: "expiration_month") as! NSNumber))
                token.card?.expirationYear = String(format: "%d", (cardObject.object(forKey: "expiration_year") as! NSNumber))
                token.card?.fingerprint = cardObject.object(forKey: "fingerprint") as? String
                token.card?.name = cardObject.object(forKey: "name") as? String
                token.card?.created = cardObject.object(forKey: "created") as? String
                token.card?.securityCodeCheck = cardObject.object(forKey: "security_code_check") as? Bool
                token.card?.bank = cardObject.object(forKey: "bank") as? String
                
                return token
            }
        }
        
        return nil
    }
}
