//
//  Token.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/08.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

/**
 AcsessTokenを保存しています
 登録したら、serverから帰ってきます
 その保存したtokenをBaseAPICientでheaderにsetしています
 */
open class Token: NSObject {
    
    let TokenAccessTokenKey: String = "TokenAccessTokenKey"
    
    open class var sharedToken: Token {
        struct Static {
            static let instance = Token()
        }
        return Static.instance
    }
    
    var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: TokenAccessTokenKey)
        }
        set(newV) {
            UserDefaults.standard.set(newV, forKey: TokenAccessTokenKey)
            UserDefaults.standard.synchronize()
        }
    }
}
