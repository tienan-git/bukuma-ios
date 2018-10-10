//
//  BKMNavigationBarView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit

open class NavigationBarView: UIView {
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(){
        super.init(frame: CGRect.zero)
        self.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth * 2, height: NavigationHeightCalculator.navigationHeight())
        self.clipsToBounds = false
    }
}
