//
//  HomeThanksDownloadView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/10/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

public enum HomeThanksDownloadViewAlertType: Int {
    case register
    case login
}

public protocol HomeThanksDownloadViewDelegate: BaseSuggestViewDelegate {
    func homeThanksDownloadViewFacebookButtonTapped(_ view: HomeThanksDownloadView, type: HomeThanksDownloadViewAlertType, completion:(() ->Void)?)
    func homeThanksDownloadViewEmailButtonTapped(_ view: HomeThanksDownloadView, type: HomeThanksDownloadViewAlertType, completion:(() ->Void)?)
    
}

open class HomeThanksDownloadView: BaseThanksView {
    
    var emailButton: UIButton?
    var alreadyButton: UIButton?
    
    var type: HomeThanksDownloadViewAlertType = .register

    required public init(delegate: SheetViewDelegate, image: UIImage, title: String, detail: String, buttonText: String) {
        super.init(delegate: delegate, image: image, title: title, detail: detail, buttonText: buttonText)
        
        titleLabel?.numberOfLines = 0
        titleLabel?.width = sheetView.width - 15.0 * 2
        titleLabel?.x = 15.0
        
        detailLabel?.width = sheetView.width - BaseSuggestViewDetailLabelWidth * 2
        
        cancelButton?.isHidden = false
        borderView?.backgroundColor = UIColor.clear
        
        actionButton?.y = detailLabel!.bottom + 20.0
        actionButton?.width = sheetView.width - 30 * 2
        actionButton?.height = 40.0
        actionButton?.x = 30.0
        actionButton?.setTitle("Facebookで登録/ログイン", for: .normal)
        actionButton?.setTitleColor(UIColor.white, for: .normal)
        actionButton?.setBackgroundColor(UIColor.clear, state: .normal)
        actionButton?.setBackgroundImage(UIImage(named: "img_stretch_btn_fb")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        
        emailButton = UIButton()
        emailButton?.viewSize = actionButton!.viewSize
        emailButton?.viewOrigin = CGPoint(x: actionButton!.x, y: actionButton!.bottom + 10.0)
        emailButton?.clipsToBounds = true
        emailButton?.setTitle("メールアドレスで登録", for: .normal)
        emailButton?.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        emailButton?.setTitleColor(UIColor.white, for: .normal)
        emailButton?.setBackgroundImage(UIImage(named: "img_stretch_btn_email")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        emailButton?.addTarget(self, action: #selector(self.emailButtonTapped(_:)), for: .touchUpInside)
        sheetView.addSubview(emailButton!)
        
        alreadyButton = UIButton()
        alreadyButton?.viewSize = CGSize(width: sheetView!.width, height: 50.0)
        alreadyButton?.viewOrigin = CGPoint(x: 0, y: emailButton!.bottom)
        alreadyButton?.clipsToBounds = true
        alreadyButton?.setTitle("すでにアカウントを持っている", for: .normal)
        alreadyButton?.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        alreadyButton?.setTitleColor(kDarkGray02Color, for: .normal)
        alreadyButton?.addTarget(self, action: #selector(self.loginButtonTapped(_:)), for: .touchUpInside)
        sheetView.addSubview(alreadyButton!)
        
        sheetView.height = alreadyButton!.bottom
        sheetView.y = kCommonDeviceHeight

    }
    
    required public init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(delegate: SheetViewDelegate?) {
        fatalError("init(delegate:) has not been implemented")
    }
    
    override func action() {
        self.disappear {
            DispatchQueue.main.async(execute: {
                (self.delegate as? HomeThanksDownloadViewDelegate)?.homeThanksDownloadViewFacebookButtonTapped(self, type: self.type , completion: nil)
            })
        }
    }
    
    func emailButtonTapped(_ sender: UIButton) {
        self.disappear {
            DispatchQueue.main.async(execute: {
                (self.delegate as? HomeThanksDownloadViewDelegate)?.homeThanksDownloadViewEmailButtonTapped(self, type: self.type , completion: nil)
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
    
    func changeString(_ type: HomeThanksDownloadViewAlertType) {
        if type == .login {
            emailButton?.setTitle("メールアドレスでログイン", for: .normal)
            alreadyButton?.setTitle("ログインせず新たに登録する", for: .normal)
            return
        }
        emailButton?.setTitle("メールアドレスで登録", for: .normal)
        alreadyButton?.setTitle("すでにアカウントを持っている", for: .normal)
    }
    

    func config(_ title: String, detail: String) {
        titleLabel?.text = title
        titleLabel?.height = title.getTextHeight(titleLabel!.font, viewWidth: titleLabel!.width)
        
        detailLabel?.text = detail
        detailLabel?.height = detail.getTextHeight(detailLabel!.font, viewWidth: detailLabel!.width)
        
        detailLabel?.y = titleLabel!.bottom + 15.0
        
        actionButton?.y = detailLabel!.bottom + 20.0
        
        emailButton?.viewOrigin = CGPoint(x: actionButton!.x, y: actionButton!.bottom + 10.0)
        alreadyButton?.viewOrigin = CGPoint(x: 0, y: emailButton!.bottom)

        sheetView.x = (kCommonDeviceWidth - self.sheetView.width) / 2
        
        sheetView.height = alreadyButton!.bottom
        sheetView.y = kCommonDeviceHeight
        
    }    
}
