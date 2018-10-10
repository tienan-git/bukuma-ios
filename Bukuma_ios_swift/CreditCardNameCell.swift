//
//  CreditCardNameCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class CreditCardNameCell: BaseTextFieldCell {
    
    fileprivate var cardImageView: UIImageView?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        let topBorderView: UIView = UIView()
        topBorderView.backgroundColor = kBorderColor
        topBorderView.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 0.5)
        self.contentView.addSubview(topBorderView)
        
        placeholderText = "名義人名: 例 TARO SUZUKI"
        
        textField?.x = 30.0
        textField?.viewSize = CGSize(width: kCommonDeviceWidth - 30 * 2, height: 20)
        textField?.textAlignment = .right
        textField?.tag = 0
        textField?.returnKeyType = .next
        
        
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
        bottomLineView?.frame = CGRect(x: 30.0, y: self.height - 0.5, width: kCommonDeviceWidth - 30.0 * 2, height: 0.5)
    }
    
}
