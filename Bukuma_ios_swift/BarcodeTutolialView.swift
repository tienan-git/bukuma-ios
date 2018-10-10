//
//  BarcodeTutolialView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/20.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class BarcodeTutolialView: BaseSuggestView {
    
    required public init(delegate: SheetViewDelegate, image: UIImage, title: String, detail: String, buttonText: String) {
        super.init(delegate: delegate, image: image, title: title, detail: detail, buttonText: buttonText)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(delegate: SheetViewDelegate?) {
        fatalError("init(delegate:) has not been implemented")
    }
    
    required public init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    override open func appearOnViewController(_ viewController: UIViewController) {
        if (self.superview != nil) {
            return
        }
        
        viewController.view.addSubview(self)
        
        UIView.animate(withDuration:0.3, animations: {
            self.alpha = 1.0
            self.sheetView.center.y = kCommonDeviceHeight / 2
            self.sheetView.center = self.center
        }) { (finish) in
        }
    }
}
