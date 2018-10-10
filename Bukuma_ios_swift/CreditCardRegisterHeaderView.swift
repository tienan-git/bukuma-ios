//
//  CreditCardRegisterHeaderView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


private let headerViewHeight: CGFloat = 100.0

open class CreditCardRegisterHeaderView: UIView {
    
    fileprivate let headerViewMargin: CGFloat = 17.0
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: headerViewHeight))
        
        self.backgroundColor = kBackGroundColor
        
        let titleLabel: UILabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: headerViewMargin, width: kCommonDeviceWidth, height: 20.0)
        titleLabel.font = UIFont.systemFont(ofSize: 15.0)
        titleLabel.textColor = kBlackColor87
        titleLabel.textAlignment = .center
        titleLabel.text = "使用可能なクレジットカード"
        
        self.addSubview(titleLabel)
        
        for i in 0...1 {
            let cardImageView: UIImageView! = UIImageView()
            cardImageView.viewSize = CGSize(width: self.cardImage(0).size.width, height: self.cardImage(0).size.height)
            cardImageView.contentMode = .scaleAspectFill
            cardImageView.y = titleLabel.bottom + headerViewMargin
            let centerMargin: CGFloat = 30.0
            let originXMargin: CGFloat = (kCommonDeviceWidth - (cardImageView.width * 2) - centerMargin) / 2
            cardImageView.x = originXMargin + (centerMargin + cardImageView.width) * i.cgfloat()
            cardImageView.clipsToBounds = true
            cardImageView.tag = i
            cardImageView.image = self.cardImage(i)
            cardImageView.backgroundColor = UIColor.clear
            self.addSubview(cardImageView)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cardImage(_ tag: Int) ->UIImage {
        if tag == 0 {
            return UIImage(named: "img_credit_register_visa")!
        }
        return UIImage(named: "img_credit_register_master")!
    }
}
