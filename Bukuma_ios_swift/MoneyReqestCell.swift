//
//  MoneyReqestCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class MoneyReqestCell: BaseIconTextTableViewCell {
    
    var textlabel: UILabel?
    let textlabelWidth: CGFloat = 150.0
    
    var textLabelText: String? {
        didSet {
            textlabel?.text = textLabelText
        }
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        textlabel = UILabel()
        textlabel?.frame = CGRect(x: kCommonDeviceWidth - textlabelWidth - 10.0, y: titleLabel!.y, width: textlabelWidth, height: titleLabel!.height)
        textlabel?.font = UIFont.boldSystemFont(ofSize: 14)
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
}


