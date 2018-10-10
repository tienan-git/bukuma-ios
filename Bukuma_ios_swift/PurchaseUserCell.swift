//
//  PurchaseUserCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/21.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

private let PurchaseUserCellUserIconSize: CGSize = CGSize(width: 32.0, height: 32.0)
private let PurchaseUserCellTextWidth: CGFloat = kCommonDeviceWidth - PurchaseUserCellUserIconSize.width - 15.0 - 12.0 - 15.0

open class PurchaseUserCell: UserIconCell {
    
    fileprivate var shippingTextLabel: UILabel?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        iconImageViewButton.frame = CGRect(x: UserIconCellBaseHorizontalMargin,
                                           y: UserIconCellBaseVerticalMargin,
                                           width: PurchaseUserCellUserIconSize.width,
                                           height: PurchaseUserCellUserIconSize.height)
        iconImageViewButton.layer.cornerRadius = PurchaseUserCellUserIconSize.height / 2
        
        shippingTextLabel = UILabel()
        shippingTextLabel?.frame = CGRect(x: iconImageViewButton.right + 12.0,
                                          y: iconImageViewButton.y,
                                          width: PurchaseUserCellTextWidth,
                                          height: 0)
        shippingTextLabel?.numberOfLines = 0
        shippingTextLabel?.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(shippingTextLabel!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate class func text(_ merchandise: Merchandise?) ->NSAttributedString {
        let mutableString: NSMutableAttributedString = NSMutableAttributedString()
        if merchandise?.shippingInfoAttribute() == nil {
            return mutableString
        }
        
        let shippingInfo: NSAttributedString = merchandise!.shippingInfoAttribute()!
        var userInfo: NSMutableAttributedString = NSMutableAttributedString()
        
        merchandise?.user.map({ (user) in
            let text: String = "\(user.nickName ?? "")さんが"
            userInfo = NSMutableAttributedString(string: text)
            userInfo.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)], range: NSRange(location: 0, length: user.nickName?.length ?? 0))
            userInfo.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14)], range: NSRange(location: user.nickName?.length ?? 0, length: 3))
            userInfo.addAttributes([NSForegroundColorAttributeName: kAttributeColor], range: NSRange.init(location: 0, length: text.length))
        })
        
        mutableString.append(userInfo)
        mutableString.append(shippingInfo)
        
        return mutableString
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let merchandise: Merchandise? = object as? Merchandise
        let textHeight: CGFloat = self.text(merchandise).getTextHeight(PurchaseUserCellTextWidth)
        
        let minHeight: CGFloat = PurchaseUserCellUserIconSize.height + 15.0 * 2
        let maxHeight: CGFloat = textHeight + 15.0 * 2
        if maxHeight > minHeight {
            return maxHeight
        }
        return minHeight
    }

    override open var cellModelObject: AnyObject? {
        didSet {
            let merchandise: Merchandise? = cellModelObject as? Merchandise
            if merchandise?.user?.photo?.imageURL != nil {
                iconImageViewButton.downloadImageWithURL(merchandise?.user?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)
            } else {
                iconImageViewButton.setImage(kPlaceholderUserImage, for: .normal)
            }
            shippingTextLabel?.attributedText = type(of: self).text(merchandise)
            shippingTextLabel?.height = shippingTextLabel!.attributedText!.getTextHeight(PurchaseUserCellTextWidth)
        }
    }
}
