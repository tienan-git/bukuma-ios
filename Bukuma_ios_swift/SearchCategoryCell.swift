//
//  SearchCategoryCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class SearchCategoryCell: BaseIconTextTableViewCell {
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.backgroundColor = UIColor.white
        self.rightImage = UIImage(named: "ic_to")
        
        iconImageView?.viewSize = CGSize(width: 12, height: 12)
        iconImageView?.layer.cornerRadius = iconImageView!.width / 2
        
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        self.contentView.addSubview(titleLabel!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        iconImageView?.x = 19.0
        titleLabel?.x = 50.0
        titleLabel?.width = kCommonDeviceWidth - 50 - rightImageView!.width
        titleLabel?.y = (50 - titleLabel!.height) / 2
        bottomLineView!.frame = isShortBottomLine == true ?  CGRect(x: titleLabel!.x, y: self.height - 0.5, width: kCommonDeviceWidth - 12.0, height: 0.5)  :  CGRect(x: 0, y: self.height - 0.5, width: kCommonDeviceWidth, height: 0.5)
    }
    
    open func setColors(_ row: Int) {
        let color = SearchCategoryColor.searchCategoryColor(by: row)
        iconImageView!.image = UIImage.imageWithColor(color, size: iconImageView!.viewSize)
    }
}
