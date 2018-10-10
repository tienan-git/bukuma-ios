//
//  ProfileSettingNickNameCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation


open class ProfileSettingNickNameCell: BaseTextFieldCell {
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        textField!.textAlignment = .right
        
        self.titleText = "ニックネーム"
        self.textFieldText = Me.sharedMe.nickName
        self.placeholderText = "未設定"
        selectionStyle = .none
        self.textField?.tag = 0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50.0
    }
    
}
