//
//  SideMenuHomeCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/04.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class SideMenuHomeCell: SideMenuCell {
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageView!.y = (SideMenuCell.cellHeightForObject(nil) - iconImageView!.height) / 2 - 0.5
        titleLabel!.y = iconImageView!.y
    }

}
