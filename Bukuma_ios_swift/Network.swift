//
//  Network.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

/**
 IPAdressを取得しようとしたClassです
 Swift3.0になって、IPAdress取得方法が変わって
 なんか取得がめんどくなってコメントアウトしてます
 ローカルで取得しなくても
 server側で管理しており
 一応Localでもとっとこう
 というノリで作られたClassです
 server側で管理しているので必要ありません
 */
open class Network: NSObject {
    class func getIPAddresses() -> [String] {
//        _ = [String]()
//        _ : UnsafeMutablePointer<ifaddrs>? = nil
        
        return [""]
//        if getifaddrs(&ifaddr) == 0 {
//            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
//                let flags = Int32(ptr.pointee.ifa_flags)
//                var addr = ptr.pointee.ifa_addr.memory
//                
//                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
//                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
//                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
//                        
//                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
//                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
//                            if let address = String(validatingUTF8: hostname) {
//                                addresses.append(address)
//                            }
//                        }
//                    }
//                }
//            }
//            freeifaddrs(ifaddr)
//        }
//        return addresses
    }
}
