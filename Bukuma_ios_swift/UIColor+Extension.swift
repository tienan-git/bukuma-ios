//
//  UIColor+Extension.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit

public extension UIColor {
    public class func colorWithDecimal(_ red:Float, green:Float, blue:Float) ->UIColor{
       return self.colorWithDecimal(red, green: green, blue: blue, alpha: 1.0)
    }
    
    public class func colorWithDecimal(_ red:Float, green:Float, blue:Float, alpha:Float) ->UIColor{
        return UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: CGFloat(alpha))
    }
    
    public class func colorWithHex(_ color24:NSInteger) ->UIColor{
        let r: Int = (color24 >> 16)
        let g: Int = (color24 >> 8 & 0xFF)
        let b: Int = (color24 & 0xFF)
        return self.colorWithDecimal(Float(r), green: Float(g), blue: Float(b), alpha: 1.0)
    }
    
    public class func colorWithHex(_ color24:NSInteger, alpha:CGFloat) ->UIColor{
        let r: Int = (color24 >> 16)
        let g: Int = (color24 >> 8 & 0xFF)
        let b: Int = (color24 & 0xFF)
        return self.colorWithDecimal(Float(r), green: Float(g), blue: Float(b), alpha: Float(alpha))
    }
    
    public class func colorWithHexString (_ hex:String) -> UIColor? {
        
        let cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if ((cString as String).characters.count != 6) {
            return nil
        }
        
        let rString = (cString as NSString).substring(with: NSRange(location: 0, length: 2))
        let gString = (cString as NSString).substring(with: NSRange(location: 2, length: 2))
        let bString = (cString as NSString).substring(with: NSRange(location: 4, length: 2))
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(
            red: CGFloat(Float(r) / 255.0),
            green: CGFloat(Float(g) / 255.0),
            blue: CGFloat(Float(b) / 255.0),
            alpha: CGFloat(Float(1.0))
        )
    }
}
