//
//  CardNumberCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class CardNumberCell: BaseTextFieldCell {
    
    fileprivate var cardImageView: UIImageView?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        placeholderText = "カード番号"
        textFieldMaxLength = 16
        
        textField?.x = 30.0
        textField?.textAlignment = .right
        textField?.tag = 1
        textField?.keyboardType = .numberPad
        textField?.returnKeyType = .next
        
        cardImageView = UIImageView()
        let cardImage: UIImage = UIImage(named: "img_credit_register_visa")!
        cardImageView?.frame = CGRect(x: kCommonDeviceWidth - 30.0 - cardImage.size.width,
                                     y: 0,
                                     width: cardImage.size.width,
                                     height: cardImage.size.height)
        self.contentView.addSubview(cardImageView!)
        
        textField?.viewSize = CGSize(width: kCommonDeviceWidth - 30 * 2 - cardImage.size.width, height: 20)

        keyboardToolbarButtonText = "次へ"

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        textField?.bottom = self.height - 10.0
        cardImageView?.bottom = self.height - 10.0
        bottomLineView?.frame = CGRect(x: 30.0, y: self.height - 0.5, width: kCommonDeviceWidth - 30.0 * 2, height: 0.5)
    }
    
    func setCardImage(_ cardPrefix: String) {
        cardImageView?.image = nil
        if cardPrefix == "4" {
            cardImageView?.image = UIImage(named: "img_credit_register_visa")!
        } else if cardPrefix == "5" {
            cardImageView?.image = UIImage(named: "img_credit_register_master")!
        }
    }
}
