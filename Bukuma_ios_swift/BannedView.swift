//
//   BannedView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/10/21.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

class BannedView: SheetView {
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        self.defaultSetUp()
    }
    
    required init(delegate: SheetViewDelegate?) {
        fatalError("init(delegate:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class var shared: BannedView {
        struct Static {
            static let instance = BannedView(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonDeviceHeight))
        }
        return Static.instance
    }

}