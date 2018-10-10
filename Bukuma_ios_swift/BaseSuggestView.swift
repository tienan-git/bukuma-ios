//
//  TwitterSuggestView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/24.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

let BaseSuggestViewFinishFirstShowKey = "BaseSuggestViewFinishFirstShowKey"

public protocol BaseSuggestViewDelegate: SheetViewDelegate {
    func baseSuggestViewCancelButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?)
    func baseSuggestViewActionButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?)
}

open class BaseSuggestView: SheetView {
    
    let imageView: UIImageView? = UIImageView()
    let cancelButton: UIButton? = UIButton()
    let titleLabel: UILabel? = UILabel()
    let detailLabel: UILabel? = UILabel()
    let actionButton: UIButton? = UIButton()
    let borderView: UIView? = UIView()
    
    let BaseSuggestViewDetailLabelWidth: CGFloat = 22.0
    
    var finishFirstShow: Bool {
        get {
            return UserDefaults.standard.bool(forKey: BaseSuggestViewFinishFirstShowKey)
        }
        set(newV) {
            UserDefaults.standard.set(newV, forKey: BaseSuggestViewFinishFirstShowKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    required public init(delegate: SheetViewDelegate, image: UIImage, title: String, detail: String, buttonText: String) {
        super.init(delegate: delegate)
        
        self.backgroundColor = kBlackColor54
        
        sheetView.clipsToBounds = false
        
        imageView?.image = image
        imageView?.frame = CGRect(x: -6.5, y: -12.0, width: image.size.width, height: image.size.height)
        imageView?.clipsToBounds = true
        imageView?.layer.cornerRadius = 2.0
        imageView?.backgroundColor = UIColor.clear
        imageView?.isUserInteractionEnabled = true
        sheetView.addSubview(imageView!)
        
        self.sheetView.width = imageView!.width - 13.0
        
        self.sheetView.x = (kCommonDeviceWidth - self.sheetView.width) / 2
        
        let cancelButtonImage: UIImage = UIImage(named: "ic_close_hover")!
        cancelButton?.frame = CGRect(x: 6.5, y: 12.0, width: cancelButtonImage.size.width, height: cancelButtonImage.size.height)
        cancelButton?.setImage(cancelButtonImage, for: .normal)
        cancelButton?.addTarget(self, action: #selector(self.cancel(_:)), for: .touchUpInside)
        imageView?.addSubview(cancelButton!)
        
        titleLabel?.frame = CGRect(x: 0,
                                  y: imageView!.bottom + 33.0,
                                  width: sheetView.width,
                                  height: 25.0)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel?.textColor = kBlackColor87
        titleLabel?.text = title
        titleLabel?.textAlignment = .center
        sheetView.addSubview(titleLabel!)
        
        detailLabel?.frame = CGRect(x: BaseSuggestViewDetailLabelWidth,
                                   y: titleLabel!.bottom + 15.0,
                                   width: sheetView.width - BaseSuggestViewDetailLabelWidth * 2,
                                   height: 0)
        detailLabel?.font = UIFont.systemFont(ofSize: 12)
        detailLabel?.textAlignment = .center
        detailLabel?.numberOfLines = 0
        detailLabel?.text = detail
        detailLabel?.textColor = kBlackColor70
        detailLabel?.height = detailLabel!.text!.getTextHeight(detailLabel!.font, viewWidth: detailLabel!.width)
        sheetView.addSubview(detailLabel!)
        
        borderView?.frame = CGRect(x: 0, y: detailLabel!.bottom + 30.0, width: sheetView.width, height: 0.5)
        borderView?.backgroundColor = kBorderColor
        sheetView.addSubview(borderView!)
        
        actionButton?.frame = CGRect(x: 0, y: borderView!.bottom, width: sheetView.width, height: 50.0)
        actionButton?.setTitle(buttonText, for: .normal)
        actionButton?.setTitleColor(kMainGreenColor, for: .normal)
        actionButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        actionButton?.backgroundColor = UIColor.clear
        actionButton?.addTarget(self, action: #selector(self.actionButtonTapped(_:)), for: .touchUpInside)
        sheetView.addSubview(actionButton!)
        
        sheetView.height = actionButton!.bottom
        sheetView.y = kCommonDeviceHeight
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required public init(delegate: SheetViewDelegate?) {
        fatalError("init(delegate:) has not been implemented")
    }
    
    func actionButtonTapped(_ sender: UIButton) {
        self.action()
    }
    
    func action() {
        finishFirstShow = true
        (self.delegate as? BaseSuggestViewDelegate)?.baseSuggestViewActionButtonTapped(self, completion: nil)
        self.disappear(nil)
    }
    
    func cancel(_ sender: UIButton) {
        finishFirstShow = true
        self.disappear(nil)
        (self.delegate as? BaseSuggestViewDelegate)?.baseSuggestViewCancelButtonTapped(self, completion: nil)
    }
    
    func gesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(ofTouch: 0, in: self)
        if location.x  < sheetView.x || location.x > sheetView.right || location.y < sheetView.y || location.y > sheetView.bottom {
            finishFirstShow = true
            self.disappear(nil)
        }
    }
}
