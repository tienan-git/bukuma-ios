//
//  SheetView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/21.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import GLDTween

@objc public protocol SheetViewDelegate: NSObjectProtocol{}

open class SheetView: UIView {
    
    weak var delegate: SheetViewDelegate? 
    let sheetView: UIView! = UIView()
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required public init(delegate: SheetViewDelegate?) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonDeviceHeight))
        
        self.delegate = delegate
        
        self.defaultSetUp()

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func defaultSetUp() {
        
        self.backgroundColor = kSheetBackGroundColor
        
        sheetView.frame = CGRect(x: 30.0, y: self.height, width: kCommonDeviceWidth - 30 * 2, height: 300)
        sheetView.backgroundColor = UIColor.white
        sheetView.clipsToBounds = true
        sheetView.layer.cornerRadius = 2.0
        self.addSubview(sheetView)

    }
    
    
    open func appearOnViewController(_ viewController: UIViewController) {
        if (self.superview != nil) {
            return
        }
        
        viewController.view.addSubview(self)
        
        UIView.animate(withDuration:0.3, animations: {
            self.alpha = 1.0
        }) { (finish) in
            self.sheetView.center.y = kCommonDeviceHeight / 2
            self.sheetView.center = self.center
            let targetCenter: CGPoint = self.sheetView.center
            self.sheetView.alpha = 0.0
            self.sheetView.center.y += 80.0
            
            GLDTween.add(self.sheetView,
                              withParams: ["duration": 0.3,
                                "delay": 0.0,
                                "alpha": 1.0,
                                "easing": GLDEasingOutBack,
                                "center" : NSValue(cgPoint: targetCenter)])
        }
    }
    
    open func appearOnWindow() {
        if (self.superview != nil) {
            return
        }
        
        let window: UIWindow? = UIApplication.shared.keyWindow ?? UIApplication.shared.delegate?.window ?? nil
        window?.addSubview(self)
        
        UIView.animate(withDuration:0.3, animations: {
            self.alpha = 1.0
        }) { (finish) in
            self.sheetView.center.y = kCommonDeviceHeight / 2
            self.sheetView.center = self.center
            let targetCenter: CGPoint = self.sheetView.center
            self.sheetView.alpha = 0.0
            self.sheetView.center.y += 80.0
            
            GLDTween.add(self.sheetView,
                              withParams: ["duration": 0.3,
                                "delay": 0.0,
                                "alpha": 1.0,
                                "easing": GLDEasingOutBack,
                                "center" : NSValue(cgPoint: targetCenter)])
        }
    }
    
    open func disappear(_ completion: (() ->Void)?) {
        if self.superview == nil {
            return
        }
        
        UIView.animate(withDuration:0.35, animations: {
            self.sheetView.top = self.height
            
        }) { (isFinished) in
            UIView.animate(withDuration:0.25, animations: {
                self.alpha = 0.0
                }, completion: { (isFinished) in
                    if completion != nil {
                        completion!()
                    }
                    self.removeFromSuperview()
            })
        }
    }
}
