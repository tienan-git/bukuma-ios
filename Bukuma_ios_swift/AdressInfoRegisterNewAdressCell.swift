//
//  AdressRegisterNewAdressCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class AdressInfoRegisterNewAdressCell: BaseIconTextTableViewCell {
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        iconImageView!.x = 0.0
        self.iconImage = UIImage(named: "ic_set_add")!
        
        title = "住所を新しく追加する"
        titleLabel!.textColor = kMainGreenColor
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
}

