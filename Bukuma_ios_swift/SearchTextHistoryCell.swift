//
//  SearchTextHistoryCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/06.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class SearchTextHistoryCell: BaseIconTextTableViewCell {
    
    var priceLabel: UILabel?
    
    deinit {
       priceLabel = nil
       titleLabel = nil
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.backgroundColor = UIColor.white
        
        titleLabel?.font = UIFont.systemFont(ofSize: 15)
        titleLabel?.textColor = kBlackColor87
        titleLabel?.width = kCommonDeviceWidth - iconImageView!.right - 15.0
        self.contentView.addSubview(titleLabel!)
        priceLabel = UILabel()
        priceLabel?.text = nil
        priceLabel?.textColor = kTintGreenColor
        priceLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.contentView.addSubview(priceLabel!)
        
        priceLabel?.height = 15.0
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        priceLabel!.y = (50 - priceLabel!.height) / 2
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let book: Book? = cellModelObject as? Book
            
            titleLabel?.text = book?.titleText()
            if book != nil {
                if book?.lowestPriceString(.yenMark) != "出品がありません" {
                    priceLabel?.text = "\(book!.lowestPriceString(.yenMark))~"
                } else {
                     priceLabel?.text = ""
                     priceLabel?.isHidden = true
                }
            }
            
            titleLabel?.width = kCommonDeviceWidth - iconImageView!.right - 15.0
            
            priceLabel?.isHidden = true
            if book?.lowestPrice != nil {
                priceLabel?.isHidden = false
                priceLabel?.width = priceLabel!.text!.getTextWidthWithFont(priceLabel!.font, viewHeight: priceLabel!.height)
                priceLabel?.x = kCommonDeviceWidth - priceLabel!.width - 15.0
                titleLabel?.width = kCommonDeviceWidth - priceLabel!.width - 15.0 - 12.0 - 15.0
            }
        }
    }
}
