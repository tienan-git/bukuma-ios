//
//  BaseIconTextTableViewCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


/**
 
 iconとLabelを表示
 SettingViewControllerなどで頻繁に使われている
 */

open class BaseIconTextTableViewCell: BaseTableViewCell {
    
    var iconImageView: UIImageView?
    var titleLabel: UILabel?

    override func releaseSubViews() {
        super.releaseSubViews()
        titleLabel = nil
        iconImageView = nil
    }

    var iconImage: UIImage? {
        willSet(newValue) {
            iconImageView!.image = newValue
            iconImageView!.viewSize = CGSize(width: newValue!.size.width, height: newValue!.size.height)
            iconImageView!.y = (self.height - iconImageView!.height) / 2
            titleLabel!.x = iconImageView!.right + 6.0
            titleLabel!.height = iconImageView!.height
            titleLabel!.y = iconImageView!.y
        }
    }
    
    var title: String? {
        willSet(newValue) {
            titleLabel!.text = newValue
        }
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        iconImageView = UIImageView()
        iconImageView!.x = 0
        iconImageView!.y = 0
        //default size
        iconImageView!.viewSize = CGSize(width: 12.0, height: 25.0)
        iconImageView!.clipsToBounds = true
        iconImageView!.layer.cornerRadius = iconImageView!.height / 2
        iconImageView!.y = (self.height - iconImageView!.height) / 2
        self.contentView.addSubview(iconImageView!)
        
        titleLabel = UILabel.init()
        titleLabel!.x = iconImageView!.right
        titleLabel!.width = kCommonDeviceWidth - titleLabel!.x
        titleLabel!.height = iconImageView!.height
        titleLabel!.y = iconImageView!.y
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel!.textColor = kDarkGray03Color
        self.contentView.addSubview(titleLabel!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 30
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        iconImageView!.y = (self.height - iconImageView!.height) / 2
        titleLabel!.y = iconImageView!.y
    }

}


