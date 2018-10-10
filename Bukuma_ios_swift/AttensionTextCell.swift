//
//  AttensionTextCell.swift
//  Bukuma_ios_swift
//
//  Created by tani on 2017/06/12.
//  Copyright © 2017年 Labit Inc. All rights reserved.
//

open class AttensionTextCell: BaseTableViewCell {
    
    var titleLabel: UILabel?
    
    var title: String? {
        get { return titleLabel?.text }
        set { titleLabel?.text = newValue }
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        contentView.backgroundColor = kBackGroundColor
        backgroundColor = kBackGroundColor
        
        let titleLabel = UILabel()
        titleLabel.x = 12.0
        titleLabel.y = 12.0
        titleLabel.width = self.contentView.width - titleLabel.x
        titleLabel.height = 12.0
        titleLabel.textColor = kBlackColor70
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(titleLabel)
        self.titleLabel = titleLabel
        
        selectionStyle = .none
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 42
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        contentView.backgroundColor = kBackGroundColor
        backgroundColor = kBackGroundColor
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        contentView.backgroundColor = kBackGroundColor
        backgroundColor = kBackGroundColor
    }
}
