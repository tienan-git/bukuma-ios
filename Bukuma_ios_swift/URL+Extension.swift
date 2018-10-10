//
//  URL+Extension.swift
//  Bukuma_ios_swift
//
//  Created by tani on 2017/05/31.
//  Copyright © 2017年 Labit Inc. All rights reserved.
//

extension URL {
    var fragments : [String : String] {
        let components = URLComponents(string: absoluteString)
        var results: [String : String] = [:]
        guard let items = components?.queryItems else {
            return results
        }
        
        for item in items {
            results[item.name] = item.value
        }
        
        return results
    }
}
