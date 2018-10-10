//
//  EmailSettingCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class EmailSettingCell: BaseTextFieldCell{
    
       required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        textField!.textAlignment = .right
        self.selectionStyle = .none
        
        textFieldMaxLength = 50
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        textField!.y = (self.height - textField!.height) / 2
        textField!.x = 10.0
        textField!.width = kCommonDeviceWidth - 10 * 2
    }
}
