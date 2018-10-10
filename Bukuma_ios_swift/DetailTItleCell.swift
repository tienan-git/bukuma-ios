//
//  DetailTItleCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/30.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class DetailTItleCell: BaseTitleCell {
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        
        titleLabel!.textColor = kTitleBlackColor
        titleLabel!.textColor = kDarkGray01Color
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        
        self.selectionStyle = .none
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
}
