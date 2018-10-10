//
//  SearchCategoryColor.swift
//  Bukuma_ios_swift
//
//  Created by hara on 4/26/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import UIKit

class SearchCategoryColor {
    private static let searchCategoryColors: [UIColor] =
        [UIColor.colorWithHex(0xF45651),
         UIColor.colorWithHex(0xF46262),
         UIColor.colorWithHex(0xF06292),
         UIColor.colorWithHex(0xBA68C8),
         UIColor.colorWithHex(0x9575CD),
         UIColor.colorWithHex(0x7986CB),
         UIColor.colorWithHex(0x64B5F6),
         UIColor.colorWithHex(0x4FC3F7),
         UIColor.colorWithHex(0x4DD0E1),
         UIColor.colorWithHex(0x26C9C2),
         UIColor.colorWithHex(0x4DB6AC),
         UIColor.colorWithHex(0x81C784),
         UIColor.colorWithHex(0xAED581),
         UIColor.colorWithHex(0xDCE775),
         UIColor.colorWithHex(0xFFD54F),
         UIColor.colorWithHex(0xFFB74D),
         UIColor.colorWithHex(0xF37D27),
         UIColor.colorWithHex(0xA1887F),
         UIColor.colorWithHex(0xBDBDBD),
         UIColor.colorWithHex(0x90A4AE)]

    class func searchCategoryColor(by index: Int)-> UIColor {
        let colorMax = self.searchCategoryColors.count - 1
        let colorIndex = index > colorMax ? index - colorMax : index
        return self.searchCategoryColors[colorIndex]
    }
}
