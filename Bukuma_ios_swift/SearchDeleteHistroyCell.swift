//
//  SearchDeleteHistroyCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/06.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class SearchDeleteHistroyCell: BaseIconTextTableViewCell {
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.backgroundColor = UIColor.white
        self.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        self.titleLabel!.textColor = kMainGreenColor
        self.title = "検索履歴を消す"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel!.x = 0
        self.titleLabel!.width = kCommonDeviceWidth
        self.titleLabel!.textAlignment = .center
    }
}
