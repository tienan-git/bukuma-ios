//
//  Data+Extension.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/10/26.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

extension Data {
    func hexString() -> String {
        //let string = self.map{Int($0).hexString()}.joined()
        return ""
    }
    
    func MD5() -> Data {
        var result = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = result.withUnsafeMutableBytes {resultPtr in
            self.withUnsafeBytes {(bytes: UnsafePointer<UInt8>) in
                CC_MD5(bytes, CC_LONG(count), resultPtr)
            }
        }
        return result
    }
}
