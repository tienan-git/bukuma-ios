//
//  UserPageReviewView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/30.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class UserPageReviewView: UIView {
    
    var type: ReviewType? {
        didSet {
            _ = type.map { (type) in
                iconImgaeView?.image = self.image(type)
                iconImgaeView?.viewSize = iconImgaeView!.image!.size
                
                textLabel?.frame = CGRect(x: iconImgaeView!.right + 4.0,
                    y: 0,
                    width: 0,
                    height: iconImgaeView!.height)
                
                self.setAttributes(type)
                
                self.frame = CGRect(x: 0,
                    y: 0,
                    width: textLabel!.right,
                    height: iconImgaeView!.height)
            }
        }
    }
    
    var iconImgaeView: UIImageView?
    var textLabel: UILabel?
    
    required public init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() {
        iconImgaeView = UIImageView()
        iconImgaeView?.viewOrigin = CGPoint.zero
        self.addSubview(iconImgaeView!)
        
        textLabel = UILabel()
        textLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        self.addSubview(textLabel!)
        
    }
    
    func image(_ type: ReviewType) -> UIImage {
        switch type {
        case .good:
            return UIImage(named: "ic_review_16x16_gd")!
        case .normal:
            return UIImage(named: "ic_review_16x16_rg")!
        case .bad:
            return UIImage(named: "ic_review_16x16_bd")!
        }
    }
    
    func setAttributes(_ type: ReviewType) {
        switch type {
        case .good:
            textLabel?.text = "スムーズに取引できました"
            textLabel?.textColor = UIColor.colorWithHex(0xef5185)
        case .normal:
            textLabel?.text = "少し不安な取引でした"
            textLabel?.textColor = UIColor.colorWithHex(0xfba933)
        case .bad:
            textLabel?.text = "取引中にトラブルがありました"
            textLabel?.textColor = UIColor.colorWithHex(0x6ab5d8)
        }
        textLabel?.width = textLabel!.text!.getTextWidthWithFont(textLabel!.font, viewHeight: textLabel!.height)
    }
}
