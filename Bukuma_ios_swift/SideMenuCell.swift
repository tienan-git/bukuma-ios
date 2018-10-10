//
//  SideMenuCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

private let kIconImageViewBackGroundColor = UIColor.colorWithHex(0xCFCFCF)
private let SideMenuCellIconImageViewSize: CGSize = CGSize(width: 25, height: 25)

open class SideMenuCell: BaseIconTextTableViewCell {
    
    var unReadCountLabel: UILabel?
    
    override var iconImage: UIImage? {
        willSet(newValue) {
            iconImageView!.image = newValue
            iconImageView!.viewSize = CGSize(width: newValue!.size.width, height: newValue!.size.height)
            iconImageView!.y = (self.height - iconImageView!.height) / 2
            titleLabel!.x = iconImageView!.right
            titleLabel!.height = iconImageView!.height
            titleLabel!.y = iconImageView!.y
        }
    }

    var unReadCount: Int? {
        didSet {
            if unReadCount != nil {
                unReadCountLabel?.text = unReadCount!.string()
                if unReadCount == 0 {
                    unReadCountLabel?.isHidden = true
                } else {
                    unReadCountLabel?.isHidden = false
                }
            }
        }
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
    
        unReadCountLabel = UILabel()
        unReadCountLabel?.viewSize = CGSize(width: 28.0, height: 20.0)
        unReadCountLabel?.textAlignment = .center
        unReadCountLabel?.viewOrigin = CGPoint(x: kDrawerWidth - unReadCountLabel!.width - 15.0, y: (50.0 - unReadCountLabel!.height) / 2)
        unReadCountLabel?.clipsToBounds = true
        unReadCountLabel?.layer.cornerRadius = 10.0
        unReadCountLabel?.isHidden = true
        unReadCountLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        unReadCountLabel?.backgroundColor = kTintGreenColor
        unReadCountLabel?.textColor = UIColor.white
       self.contentView.addSubview(unReadCountLabel!)

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50.0
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        bottomLineView!.isHidden = false
        bottomLineView!.frame = CGRect(x: 15.0, y: self.height - 0.5, width: kCommonDeviceWidth - 15.0, height: 0.5)
    }
}
