//
//  UserPageEvaluateTitleCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


private let cellHeight: CGFloat = 50.0

open class UserPageEvaluateTitleCell: BaseIconTextTableViewCell {
    
    var reviewView: UserReviewIconsView?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel!.x = 16.0
        titleLabel!.textColor = kDarkGray03Color
        title = "評価一覧"
        
        reviewView = UserReviewIconsView(sizeType: .userPage)
        self.contentView.addSubview(reviewView!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return cellHeight
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        reviewView?.y = (self.height - reviewView!.height) / 2
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let user: User? = cellModelObject as? User
                        
            reviewView?.user = user
            reviewView?.x = kCommonDeviceWidth - reviewView!.width - 15.0
        }
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
}
