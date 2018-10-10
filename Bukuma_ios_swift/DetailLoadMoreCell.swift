//
//  DetailLoadMoreCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/27.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class DetailLoadMoreCell: DetailTItleCell {
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        title = "もっと見る"
        titleLabel!.x = 0
        titleLabel!.width = kCommonDeviceWidth
        titleLabel!.textAlignment = .center
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel!.textColor = kGray03Color
       
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
