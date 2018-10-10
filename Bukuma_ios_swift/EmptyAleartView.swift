//
//  EmptyAleartView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/30.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class EmptyAleartView: UIView {
    
    var label: UILabel? = UILabel()
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    deinit {
        label = nil
    }
    
    required public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 50))
        
        self.backgroundColor  = kPink02Color
        
        label!.frame = self.bounds
        label!.textColor = UIColor.white
        label!.font = UIFont.systemFont(ofSize: 14)
        label!.textAlignment = .center
        self.addSubview(label!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func showWithText(_ text: String, dismissAfter: Double, onViewController: UIViewController) {
        label!.text = text
        let viewControllerRect: CGRect = onViewController.view.bounds
        self.y = viewControllerRect.height
        self.alpha = 0.0
        onViewController.view.addSubview(self)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1.0
            self.y = viewControllerRect.height - self.height
            
        }) { (finished) in
             DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(dismissAfter * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                UIView.animate(withDuration:0.25, animations: {
                    self.y = viewControllerRect.height
                    }, completion: { (finished) in
                        self.alpha = 0.0
                        self.removeFromSuperview()
                })
            })
        }
    }
}
