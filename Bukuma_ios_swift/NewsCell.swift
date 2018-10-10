//
//  NewsCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/06.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

let newsTextWidth: CGFloat = kCommonDeviceWidth - UIImage(named: "img_avatar_adminNews")!.size.width - UserIconCellBaseHorizontalMargin * 3

open class NewsCell: UserIconCell {
    
    fileprivate var contentLabel: UILabel?
    fileprivate var dateLabel: UILabel?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        iconImageViewButton.isUserInteractionEnabled = false
        iconImageViewButton.setImage(UIImage(named: "img_avatar_adminNews"), for: .normal)
        iconImageViewButton.viewSize = CGSize(width: UIImage(named: "img_avatar_adminNews")!.size.width, height: UIImage(named: "img_avatar_adminNews")!.size.height)
        iconImageViewButton.clipsToBounds = true
        iconImageViewButton.layer.cornerRadius = UIImage(named: "img_avatar_adminNews")!.size.height / 2
        
        contentLabel = UILabel()
        contentLabel?.frame = CGRect(x: self.iconImageViewButton.right + 15, y: self.iconImageViewButton.y, width: newsTextWidth, height: 0)
        contentLabel?.textColor = kDarkGray03Color
        contentLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        contentLabel?.textAlignment = .left
        contentLabel?.numberOfLines = 0
        contentLabel?.lineBreakMode = .byTruncatingTail
        self.contentView.addSubview(contentLabel!)
        
        dateLabel = UILabel()
        dateLabel?.viewSize = CGSize(width: 0, height: 15.0)
        dateLabel?.viewOrigin = CGPoint(x: contentLabel!.x, y: contentLabel!.y)
        dateLabel?.textAlignment = .right
        dateLabel?.textColor = kGrayColor
        dateLabel?.font = UIFont.systemFont(ofSize: 11)
        self.contentView.addSubview(dateLabel!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func prepareForReuse() {
        super.prepareForReuse()

        self.iconImageViewButton.setImage(UIImage(named: "img_avatar_adminNews"), for: .normal)
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let annoucement: Announcement? = object as? Announcement
        var contentHeight: CGFloat = 0
        if !Utility.isEmpty(annoucement?.content) {
            contentHeight = annoucement!.content!.getTextHeight(UIFont.boldSystemFont(ofSize: 12), viewWidth: newsTextWidth)
        }
        
        return UserIconCellBaseHorizontalMargin * 2 + contentHeight + 15.0 + 8.0
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let annoucement: Announcement? = cellModelObject as? Announcement
            
            if !Utility.isEmpty(annoucement?.content) {
                contentLabel?.text = annoucement?.content
                contentLabel?.height = contentLabel!.text!.getTextHeight(UIFont.boldSystemFont(ofSize: 12), viewWidth: newsTextWidth)
            }
            
            dateLabel!.text = (annoucement?.updatedAt as Date?)?.dateString(in: DateFormatter.Style.short) // annoucement?.updatedAt?.timeAgoSimple() ?? ""
            dateLabel!.width = dateLabel!.text!.getTextWidthWithFont(dateLabel!.font, viewHeight: dateLabel!.height)
            dateLabel!.viewOrigin = CGPoint(x: contentLabel!.x, y: contentLabel!.bottom + 10.0)
        }
    }
}
