//
//  BaseTitleCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

// 

/** 
 
 Titleを表示
 SettingViewControllerなどで頻繁に使われている
 */

open class BaseTitleCell: BaseTableViewCell {
    
    var titleLabel: UILabel?
    
    var title: String? {
        willSet(newValue) {
            titleLabel?.text = newValue
        }
    }
    
    override func releaseSubViews() {
        super.releaseSubViews()
        titleLabel = nil
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)

        self.contentView.backgroundColor = kBackGroundColor
        self.backgroundColor = kBackGroundColor
        
        titleLabel = UILabel()
        titleLabel!.x = 12.0
        titleLabel!.width = self.contentView.width - (titleLabel!.x * 2)
        titleLabel?.height = self.contentView.height
        titleLabel!.textColor = kBlackColor87
        titleLabel!.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(titleLabel!)
        self.selectionStyle = .none
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 42
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        var center = self.titleLabel?.center
        center?.y = self.contentView.center.y
        self.titleLabel?.center = center!
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        self.contentView.backgroundColor = kBackGroundColor
        self.backgroundColor = kBackGroundColor
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.contentView.backgroundColor = kBackGroundColor
        self.backgroundColor = kBackGroundColor
    }
}
