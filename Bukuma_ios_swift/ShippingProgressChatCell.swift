//
//  ShippingProgressChatCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class ShippingProgressChatCell: BaseTitleCell {
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        titleLabel!.x = 10.0
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel!.textColor = kDarkGray03Color

        rightImage = UIImage(named: "ic_to")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let transaction: Transaction? = cellModelObject as? Transaction
            if transaction?.isBuyer() == true {
                self.title = "この出品者とのやりとり"
            } else {
                self.title = "この購入者とのやりとり"
            }
        }
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        if isSelected == true {
            self.backgroundColor = kCellisSelectedBackgroundColor
            self.contentView.backgroundColor = kCellisSelectedBackgroundColor
            return
        }
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted == true {
            self.backgroundColor = kCellisSelectedBackgroundColor
            self.contentView.backgroundColor = kCellisSelectedBackgroundColor
            return
        }
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
}
