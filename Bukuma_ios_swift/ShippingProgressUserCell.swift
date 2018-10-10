//
//  ShippingProgressUserCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class ShippingProgressUserCell: UserIconCell {
    
    fileprivate var userNameLabel: UILabel! = UILabel()
    fileprivate var reviewView: UserReviewIconsView?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        iconImageViewButton.y = 10.0
        
        userNameLabel.frame = CGRect(x: self.iconImageViewButton.right + 15, y: self.iconImageViewButton.y + 8.0, width: kCommonDeviceWidth - self.iconImageViewButton.right + 15, height: 15)
        userNameLabel.textColor = kBlackColor87
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        userNameLabel.textAlignment = .left
        self.contentView.addSubview(userNameLabel)
        
        
        reviewView = UserReviewIconsView(sizeType: .detailPage)
        self.contentView.addSubview(reviewView!)
        
        let margin: CGFloat = (iconImageViewButton.height - userNameLabel.height - reviewView!.height) / 3
        
        userNameLabel.y = self.iconImageViewButton.y + margin
        reviewView?.y = userNameLabel.bottom + margin
    
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 65
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let user: User? = cellModelObject as? User
            userNameLabel.text = user?.nickName
            if user?.photo?.imageURL != nil {
                iconImageViewButton.downloadImageWithURL(user?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)
            } else {
                iconImageViewButton.setImage(kPlaceholderUserImage, for: .normal)
            }


            reviewView?.user = user
            reviewView?.x = userNameLabel.x
        }
    }
}
