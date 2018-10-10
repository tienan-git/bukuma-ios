//
//  NotificationCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

@objc public protocol NotificationCellDelegate: BaseTableViewCellDelegate {
    func notificationSwitched(_ cell: NotificationCell)
}

open class NotificationCell: BaseTableViewCell {
    
    let titleLabel: UILabel! = UILabel()
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set(newV) {
            titleLabel.text = newV
            titleLabel.width = titleLabel.text!.getTextWidthWithFont(titleLabel.font, viewHeight: titleLabel.height)
        }
    }
    
    open var isOn: Bool {
        get {
            return notificationSwitch.isOn
        }
        
        set(newV) {
            notificationSwitch.isOn = newV
            self.switchBackGrounfColor(notificationSwitch)
        }
    }
    
    let notificationSwitch: UISwitch! = UISwitch()

    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.selectionStyle = .none
        
        isShortBottomLine = true
        titleLabel?.frame = CGRect(x: 10.0,
                                   y: 0,
                                   width:0,
                                   height: 15.0)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel?.textColor = kDarkGray03Color
        titleLabel?.textAlignment = .right
        contentView.addSubview(titleLabel!)
        
        notificationSwitch.viewOrigin = CGPoint(x: kCommonDeviceWidth - notificationSwitch.width - 10.0, y: 0)
        notificationSwitch.clipsToBounds = true
        notificationSwitch.layer.cornerRadius = notificationSwitch.height / 2
        notificationSwitch.backgroundColor = kGray01Color
        notificationSwitch.tintColor = UIColor.clear
        notificationSwitch.onTintColor = UIColor.clear
        notificationSwitch.addTarget(self, action: #selector(self.notificationSwitchChanged(_:)), for: .valueChanged)
        contentView.addSubview(notificationSwitch)
        self.switchBackGrounfColor(notificationSwitch)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.y = (self.height - titleLabel.height) / 2
        notificationSwitch.y = (self.height - notificationSwitch.height) / 2
    }
    
    fileprivate func switchBackGrounfColor(_ noSwitch: UISwitch) {
        if noSwitch.isOn == true {
            noSwitch.backgroundColor = kMainGreenColor
        } else {
            noSwitch.backgroundColor = kGrayColor
        }
    }
    
    func notificationSwitchChanged(_ sender: UISwitch) {
        self.switchBackGrounfColor(sender)
        (self.delegate as? NotificationCellDelegate)?.notificationSwitched(self)
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
    }
}


