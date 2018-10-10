//
//  PurchaseThanksView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/30.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class PurchaseThanksView: BaseThanksView {
    
    override open func disappear(_ completion: (() ->Void)?) {
        if self.superview == nil {
            return
        }
        
        UIView.animate(withDuration:0.35, animations: {
            self.sheetView.top = self.height
            
        }) { (isFinished) in
            UIView.animate(withDuration:0.25, animations: {
                self.alpha = 0.0
                if completion != nil {
                    completion!()
                }
                }, completion: { (isFinished) in
                    self.removeFromSuperview()
            })
        }
    }
}
