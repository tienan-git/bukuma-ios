//
//  BKMNavigationHeightCalculator.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

private let NavigationHeightCalculatorDefaultStatuBarHeight: CGFloat = 20
private let NavigationHeightCalculatorDefaultWholeNavigationBarHeight: CGFloat = 64

open class NavigationHeightCalculator: NSObject {
    open class func navigationHeight() -> CGFloat {
        return  kCommonStatusBarHeight + kCommonNavigationBarHeight - self.gapStatusBarHeightWithDefault()
    }
    
    open class func gapStatusBarHeightWithDefault() -> CGFloat{
        return kCommonStatusBarHeight - NavigationHeightCalculatorDefaultStatuBarHeight
    }

    open class func isTethering() -> Bool {
        return UIApplication.shared.statusBarFrame.size.height != NavigationHeightCalculatorDefaultStatuBarHeight
    }
}
