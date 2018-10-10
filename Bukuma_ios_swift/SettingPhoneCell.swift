//
//  SettingPhoneCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class SettingPhoneCell: BaseIconTextTableViewCell {
    
    let comfirmLabel: UILabel! = UILabel()
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        rightImage = nil
        
        comfirmLabel.text = "未完了"
        comfirmLabel.font = UIFont.boldSystemFont(ofSize: 13)
        comfirmLabel.textColor = kPink02Color
        comfirmLabel.height = 15.0
        comfirmLabel.width = comfirmLabel.text!.getTextWidthWithFont(comfirmLabel.font, viewHeight: comfirmLabel.height)
        comfirmLabel.viewOrigin = CGPoint(x: kCommonDeviceWidth - comfirmLabel.width - 15.0, y: 0)
        self.contentView.addSubview(comfirmLabel)
        
        self.iconImage = UIImage(named: "ic_set_phone")

        self.updateLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateLayout() {
        if Me.sharedMe.verified == true {
            comfirmLabel.textColor = kDarkGray03Color
            comfirmLabel.text = Me.sharedMe.phone?.currentPhoneNumber ?? ""
            comfirmLabel.width = comfirmLabel.text!.getTextWidthWithFont(comfirmLabel.font, viewHeight: comfirmLabel.height)
            comfirmLabel.x = kCommonDeviceWidth - comfirmLabel.width - 15.0
            accessoryView = nil
            rightImage = nil
            return
        }
        rightImage = UIImage(named: "ic_to")
        comfirmLabel.text = "未完了"
        comfirmLabel.width = comfirmLabel.text!.getTextWidthWithFont(comfirmLabel.font, viewHeight: comfirmLabel.height)
        comfirmLabel.x = kCommonDeviceWidth - comfirmLabel.width - 45.0
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        comfirmLabel.y = (self.height - comfirmLabel.height) / 2
    }

    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
}
