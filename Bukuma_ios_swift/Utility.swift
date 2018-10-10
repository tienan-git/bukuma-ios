//
//  Utility.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit

@inline(never) func DBLog<T>(_ object: T, filename: String = #file, line: Int = #line, funcname: String = #function) {
    #if DEBUG
        debugPrint("\(filename)","\(funcname)","\(line)",object)
    #endif
}

func DebugLog(_ format: String, _ args: CVarArg...) {
    #if DEBUG
        NSLog(String(format: format, arguments: args))
    #endif
}

@inline(never) func SBLog(_ error: Error, filename: String = #file, line: Int = #line, funcname: String = #function) {
    SBLog.error("error(code,func,userId):\(error.code, funcname, Me.sharedMe.identifier)")
    DBLog(error)
}

@inline(never) func OmiseLog(_ error: NSError, filename: String = #file, line: Int = #line, funcname: String = #function) {
    SBLog.error("error(code,func,userId):\(error.code, funcname, Me.sharedMe.identifier)")
    DBLog(error)
}

@available(iOS, deprecated: 1.0, message: "**WARN** (not deprecated)")
public func WARN(_ note: String) {
    DBLog(note)
}

open class Utility {
    
    open class func isEmpty(_ value: Any?) ->Bool {
        if value == nil {
            return true
        }
        if value is String {
            return (value as! String).isEmpty == true || value is NSNull == true || value as! String == "<null>" || (value as! String).length == 0
        }
        if value is NSNull {
            return true
        }
        return false
    }
    
    open class func appVersionString() ->String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    class func generateUUID() ->String {
        let uuid = CFUUIDCreate(nil)
        let uuidString = CFUUIDCreateString(nil, uuid)
       return uuidString as String? ?? ""
    }
    
}
