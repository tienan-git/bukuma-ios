//
//  SuggestRegisterAlert.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/21.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

@objc public protocol SuggestRegisterAlertDelegate: SheetViewDelegate {
    func suggestRegisterViewFacebookButtonTapped(_ view: SuggestRegisterAlert)
    func suggestRegisterViewEmailButtonTapped(_ view: SuggestRegisterAlert)
}

public enum SuggestRegisterAlertType: Int {
    case register
    case login
}

import GLDTween

open class SuggestRegisterAlert: SheetView {
    
    let imageView: UIImageView! = UIImageView()
    let cancelButton: UIButton! = UIButton()
    let facebookButton: UIButton! = UIButton()
    let emailButton: UIButton! = UIButton()
    let loginButton: UIButton! = UIButton()
    
    let SuggestRegisterAlertMargin: CGFloat = 10.0
    
    open var type: SuggestRegisterAlertType = .register
    
    required public init(delegate: SheetViewDelegate?) {
        super.init(delegate: delegate)
        
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.gesture(_:)))
        gesture.cancelsTouchesInView = false
        self.addGestureRecognizer(gesture)
        
        imageView.image = UIImage(named: "img_cover_register")!
        imageView.frame = CGRect(x: 0, y: 0, width: UIImage(named: "img_cover_register")!.size.width, height: UIImage(named: "img_cover_register")!.size.height)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 2.0
        imageView.isUserInteractionEnabled = true
        sheetView.addSubview(imageView)
        
        sheetView.width = imageView.width
        sheetView.x = (kCommonDeviceWidth - self.sheetView.width) / 2
        sheetView.height = 306
        
        let cancelButtonImage: UIImage = UIImage(named: "ic_register_close")!
        cancelButton.frame = CGRect(x: 0, y: 0, width: cancelButtonImage.size.width, height: cancelButtonImage.size.height)
        cancelButton.setImage(cancelButtonImage, for: .normal)
        cancelButton.addTarget(self, action: #selector(self.cancelButtonTapped(_:)), for: .touchUpInside)
        imageView.addSubview(cancelButton)
        
        facebookButton.frame = CGRect(x: SuggestRegisterAlertMargin, y: imageView.bottom, width: sheetView.width - SuggestRegisterAlertMargin * 2, height: 40.0)
        facebookButton.backgroundColor = UIColor.blue
        facebookButton.clipsToBounds = true
        facebookButton.layer.cornerRadius = 3.0
        facebookButton.setTitle("Facebookで登録/ログイン", for: .normal)
        facebookButton.setTitleColor(UIColor.white, for: .normal)
        facebookButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        facebookButton.addTarget(self, action: #selector(self.facebookButtonTapped(_:)), for: .touchUpInside)
         facebookButton.setBackgroundImage(UIImage(named: "img_stretch_btn_fb")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        sheetView.addSubview(facebookButton)
        
        emailButton.frame = CGRect(x: facebookButton.x, y: facebookButton.bottom + SuggestRegisterAlertMargin, width: facebookButton.width, height: facebookButton.height)
        emailButton.backgroundColor = kGray02Color
        emailButton.clipsToBounds = true
        emailButton.layer.cornerRadius = 3.0
        emailButton.setTitle("メールアドレスで登録", for: .normal)
        emailButton.setTitleColor(UIColor.white, for: .normal)
        emailButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        emailButton.addTarget(self, action: #selector(self.emailButtonTapped(_:)), for: .touchUpInside)
        emailButton.setBackgroundImage(UIImage(named: "img_stretch_btn_email")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        sheetView.addSubview(emailButton)
        
        loginButton.frame = CGRect(x: emailButton.x, y: emailButton.bottom + 5.0, width: emailButton.width, height: emailButton.height)
        
        loginButton.backgroundColor = UIColor.clear
        loginButton.setTitle("すでにアカウントをお持ちの方はこちら", for: .normal)
        loginButton.setTitleColor(kGray02Color, for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        loginButton.setTitleColor(kBlackColor54, for: .normal)
        loginButton.addTarget(self, action: #selector(self.loginButtonTapped(_:)), for: .touchUpInside)
        sheetView.addSubview(loginButton)
        
        sheetView.height = loginButton.bottom
//        sheetView.y = (kCommonDeviceHeight - sheetView.height) / 2
        self.backgroundColor = UIColor.clear
    }
    
    func cancelButtonTapped(_ sender: UIButton) {
        kDrawerViewController?.screenEdgePanGestreEnabled = true
        self.disappear(nil)
    }
    
    func facebookButtonTapped(_ sender: UIButton) {
        if (self.delegate as! SuggestRegisterAlertDelegate).responds(to: #selector(SuggestRegisterAlertDelegate.suggestRegisterViewFacebookButtonTapped(_:))){
            (self.delegate as! SuggestRegisterAlertDelegate).suggestRegisterViewFacebookButtonTapped(self)
           DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute:  {
                self.disappear(nil)
            })
        }
    }
    
    func emailButtonTapped(_ sender: UIButton) {
        if (self.delegate as! SuggestRegisterAlertDelegate).responds(to: #selector(SuggestRegisterAlertDelegate.suggestRegisterViewEmailButtonTapped(_:))){
            (self.delegate as! SuggestRegisterAlertDelegate).suggestRegisterViewEmailButtonTapped(self)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                self.disappear(nil)
            })
        }
    }
    
    func loginButtonTapped(_ sender: UIButton) {
        if type == .register {
            type = .login
        } else {
            type = .register
        }
        self.animationTrans()
        self.changeString(type)
    }
    
    func animationTrans() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.75)
        UIView.setAnimationTransition(.flipFromLeft, for: sheetView, cache: false)
        UIView.commitAnimations()
    }
    
    func changeString(_ type: SuggestRegisterAlertType) {
        if type == .login {
            emailButton.setTitle("メールアドレスでログイン", for: .normal)
            loginButton.setTitle("ログインせず新たに登録する", for: .normal)
            return
        }
        emailButton.setTitle("メールアドレスで登録", for: .normal)
        loginButton.setTitle("すでにアカウントをお持ちの方はこちら", for: .normal)
    }
    
    override open func appearOnViewController(_ viewController: UIViewController) {
        if (self.superview != nil) {
            return
        }
        
        viewController.view.addSubview(self)
        
        UIView.animate(withDuration:0.3, animations: {
            self.alpha = 1.0
            self.backgroundColor = kSheetBackGroundColor
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
    
    func gesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(ofTouch: 0, in: self)
        if location.x  < sheetView.x || location.x > sheetView.right || location.y < sheetView.y || location.y > sheetView.bottom {
            self.disappear(nil)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
}
