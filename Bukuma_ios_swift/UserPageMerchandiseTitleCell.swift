//
//  UserPageMerchandiseTitleCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/26.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class UserPageMerchandiseTitleCell: BaseTitleCell {
    
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.isUserInteractionEnabled = true
        
        rightImage = UIImage(named: "ic_to")
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel?.x = 16.0
        titleLabel?.textColor = kDarkGray03Color
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            var count: String = cellModelObject as? String ?? "0"
            if count.int() > 1000 {
                count = "1000+"
            }
            title = "\(count)件の出品"
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        rightImageView?.y = (self.height - rightImageView!.height) / 2

    }
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 42.0
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
