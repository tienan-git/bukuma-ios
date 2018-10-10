//
//  SearchBookTableViewCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/04/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class SearchBookTableViewCell: BaseTitleCell {
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        
        titleLabel = UILabel()
        titleLabel!.x = 12.0
        titleLabel!.width = self.contentView.width - titleLabel!.x
        titleLabel!.textColor = kBlackColor87
        titleLabel!.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(titleLabel!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let book: Book? = cellModelObject as? Book
            self.title = book?.titleText()
        }
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        if isSelected == true {
            self.backgroundColor = kCellisSelectedBackgroundColor
            self.contentView.backgroundColor = kCellisSelectedBackgroundColor
            return
        }
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted == true {
            self.backgroundColor = kCellisSelectedBackgroundColor
            self.contentView.backgroundColor = kCellisSelectedBackgroundColor
            return
        }
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
}
