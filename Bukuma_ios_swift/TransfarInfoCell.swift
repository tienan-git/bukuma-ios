//
//  TransfarInfoCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/02.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class TransfarInfoCell: BaseTitleCell {
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .left
        
        title = "＊\(ExternalServiceManager.needTrasferFee.thousandsSeparator())円以下で\(ExternalServiceManager.transferFee)円の手数料がかかります"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.height = self.height - 12.0
        titleLabel?.y = 8.0
        titleLabel?.width = kCommonDeviceWidth - 12.0 - 15.0
        bottomLineView?.isHidden = true
    }
}
