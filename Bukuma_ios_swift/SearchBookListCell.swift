//
//  SearchBookListCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/04/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class SearchBookListCell: HomeCollectionCell {
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        isSeriesImageView?.isHidden = true
    }
    
    override open var cellModelObject:AnyObject? {
        didSet {
            isSeriesImageView?.isHidden = true
        }
    }
}
