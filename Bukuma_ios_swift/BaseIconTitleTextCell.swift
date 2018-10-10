//
//  BaseIconTitleTextCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

/**
 
 iconとtitleLabel, textLabelを保持
 左にiconがあって、iconの横にtextあって、右にもtextがある
 
 */


open class BaseIconTitleTextCell: BaseIconTextTableViewCell {
    
    var textlabel: UILabel?
    let textlabelWidth: CGFloat = 150.0
    
    var textLabelText: String? {
        didSet {
            textlabel?.text = textLabelText
        }
    }
    
    override func releaseSubViews() {
        super.releaseSubViews()
        textlabel = nil
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        textlabel = UILabel()
        textlabel?.frame = CGRect(x: kCommonDeviceWidth - textlabelWidth - 10.0, y: titleLabel!.y, width: textlabelWidth, height: titleLabel!.height)
        textlabel?.font = UIFont.systemFont(ofSize: 12)
        textlabel?.textColor = kBlackColor87
        textlabel?.textAlignment = .right
        self.contentView.addSubview(textlabel!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        textlabel?.y = titleLabel!.y
    }
    
}
