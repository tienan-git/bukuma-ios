//
//  NSString+Extension.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


public extension String {
    
    public func getTextHeight(_ font:UIFont, viewWidth:CGFloat) ->CGFloat {
        let attributeDic: Dictionary<String, UIFont> = [NSFontAttributeName: font]
        let size: CGSize = self.boundingRect(with: CGSize(width: viewWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin,.usesFontLeading],
            attributes: attributeDic,
            context: nil).size
        return ceil(size.height)
    }
    
    public func getTextWidthWithFont(_ font:UIFont, viewHeight:CGFloat) ->CGFloat {
        let attributeDic: Dictionary<String, UIFont> = [NSFontAttributeName: font]
        let size: CGSize = self.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: viewHeight),
            options: [.usesLineFragmentOrigin,.usesFontLeading],
            attributes: attributeDic,
            context: nil).size
        return ceil((size.width > kCommonDeviceWidth) ? kCommonDeviceWidth : size.width)
    }
    
    func to_ns() -> NSString {
        return (self as NSString)
    }
    
    public func substringFromIndex(_ index: Int) -> String {
        return to_ns().substring(from: index)
    }
    
    public func substringToIndex(_ index: Int) -> String {
        return to_ns().substring(to: index)
    }
    
    public func substringWithRange(_ range: NSRange) -> String {
        return to_ns().substring(with: range)
    }
    
    public var lastPathComponent: String {
        return to_ns().lastPathComponent
    }
    
    public var pathExtension: String {
        return to_ns().pathExtension
    }
    
    public var stringByDeletingLastPathComponent: String {
        return to_ns().deletingLastPathComponent
    }
    
    public var stringByDeletingPathExtension: String {
        return to_ns().deletingPathExtension
    }
    
    public var pathComponents: [String] {
        return to_ns().pathComponents
    }
    
    public var length: Int {
        return self.characters.count
    }
    
    public func stringByAppendingPathComponent(_ path: String) -> String {
        return to_ns().appendingPathComponent(path)
    }
    
    public func stringByAppendingPathExtension(_ ext: String) -> String? {
        return to_ns().appendingPathExtension(ext)
    }

    public func isKatakana() ->Bool {
        var isIncludeKatakana: Bool = false
        var katakana: String = ""
        
        for c in self.unicodeScalars {
            if c.value >= 0x3041 && c.value <= 0x309E {
                katakana.append(String(describing: UnicodeScalar(c.value + 96)))
                isIncludeKatakana = self == katakana
            } else if c.value >= 0x30A1 && c.value <= 0x30FE {
                isIncludeKatakana = true
            } else {
                isIncludeKatakana = false
            }
        }
        return isIncludeKatakana
    }
    
    fileprivate func convertFullWidthToHalfWidth(_ reverse: Bool) -> String {
        var string: String = ""
        let chars = self.characters.map{ String(describing: $0) }
        chars.forEach {
            let halfwidthChar = NSMutableString(string: $0) as CFMutableString
            CFStringTransform(halfwidthChar, nil, kCFStringTransformFullwidthHalfwidth, reverse)
            let char = halfwidthChar as String
            string += char
        }
        return string
    }
    
    public func isHankaku() ->Bool {
        let hankaku: String = self.convertFullWidthToHalfWidth(false)
        return self == hankaku
    }
    
    func md5(string: String) -> String {
        var md5String = ""
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let md5Buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLength)
        
        if let data = string.data(using: .utf8) {
            data.withUnsafeBytes({ (bytes: UnsafePointer<CChar>) -> Void in
                CC_MD5(bytes, CC_LONG(data.count), md5Buffer)
                md5String = (0..<digestLength).reduce("") { $0 + String(format:"%02x", md5Buffer[$1]) }
            })
        }
        
        return md5String
    }
    
    func hexString() -> String {
        return self.data(using: .utf8)!.hexString()
    }
    
    func isIntOnly() -> Bool {
        if Int(self) != nil {
            return true
        }
        return false
    }
    
    mutating func floorString() ->String {
        let startIndex = self.characters.index(of: ".")
        if self.characters.count <= 2 {
            return self
        }
        let endIndex = self.index(startIndex!, offsetBy: 2)
        let range = startIndex!..<endIndex
        
        self.removeSubrange(range)
        return self
    }
    
    func removed(character: Character) -> String {
        return self.characters.filter { $0 != character }.map { String($0) }.joined(separator: "")
    }
    
    func int() ->Int {
        return Int(self) ?? 0
    }
    
    func removed(string: String) -> String {
        if let range = self.range(string: string) {
            var mutatingSelf = self
            mutatingSelf.replaceSubrange(range, with: "")
            return mutatingSelf.removed(string: string)
        }
        return self
    }
    
    func range(string: String) -> Range<String.Index>? {
        //self.index(before: string.startIndex)
//        guard let startIndex = self.index(before: string.startIndex) else {
//            return nil
//        }
        
        guard let endIndex = self.index(startIndex, offsetBy: string.characters.count, limitedBy: self.endIndex) else {
            return nil
        }
        
        let range = startIndex..<endIndex
        if self[range] != string {
            return nil
        }
        
        return range
    }
    
    func separatedComponents(separator: Character) -> [String] {
        return self.characters.split(separator: separator).map(String.init)
    }
    
    func replaceLineBreakeToSpace() ->String {
        let finalString: NSMutableString = NSMutableString()
        if self.characters.count < 2 {
            return self
        }
        for i in 0 ... self.characters.count - 1 {
            let tmp_str: String = self.substringWithRange(NSMakeRange(i, 1))
            if tmp_str == "\n" {
                finalString.append(" ")
            } else {
                finalString.append(tmp_str)
            }
        }
        return finalString as String
    }
    
    func replaceYenSign() ->String {
        guard self.length > 0 else {
            return ""
        }

        let finalString: NSMutableString = NSMutableString()
        for i in 0 ... self.characters.count - 1 {
            let tmp_str: String = self.substringWithRange(NSMakeRange(i, 1))
            if tmp_str != "¥" {
                finalString.append(tmp_str)
            }
        }
        return finalString as String
    }
}
