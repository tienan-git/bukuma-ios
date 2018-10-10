//
//  Int+Extension.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public extension Int {
    
    public func string() ->String {
        return String(self)
    }
    
    public func double() ->Double {
        return Double(self)
    }
    
    public func thousandsSeparator() ->String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        let result = formatter.string(from: NSNumber(integerLiteral: self))
        return result!
    }
    
    public func cgfloat() ->CGFloat {
        return CGFloat(self)
    }
}

public extension Double {
    public func date() ->NSDate {
        return NSDate(timeIntervalSince1970: self)
    }
    
    public func int() ->Int {
        return Int(self)
    }
    
    public func cgfloat() ->CGFloat {
        return CGFloat(self)
    }
}

public extension CGFloat {
    public func int() ->Int{
        return Int(self)
    }
}

