//
//  PurchasePaymentPriceCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/23.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class PurchasePaymentPriceCell: BaseTextFieldCell {
    
    fileprivate var shippingIncludeImageView: UIImageView?
    
    override open var textFieldText: String? {
        didSet {
            textField?.text = self.textFieldText
            textField?.width = (self.textFieldText ?? "").getTextWidthWithFont(UIFont.boldSystemFont(ofSize: 18), viewHeight: textField!.height)
            textField?.right = kCommonDeviceWidth - 12.0
            shippingIncludeImageView?.right = textField!.x - 10.0
        }
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        titleText = "商品の代金"
        textField?.textColor = kBlackColor87
        textField?.font = UIFont.boldSystemFont(ofSize: 18)
        textField?.isUserInteractionEnabled = false
        isShortBottomLine = true
        selectionStyle = .none
        
        let image: UIImage = UIImage(named: "ic_shipping_included")!
        shippingIncludeImageView = UIImageView()
        shippingIncludeImageView?.image = image
        shippingIncludeImageView?.viewSize = CGSize(width: image.size.width, height: image.size.height)
        shippingIncludeImageView?.clipsToBounds = true
        self.contentView.addSubview(shippingIncludeImageView!)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        shippingIncludeImageView?.y = (self.height - shippingIncludeImageView!.height) / 2
    }
}
