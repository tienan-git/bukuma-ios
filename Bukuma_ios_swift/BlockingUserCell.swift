//
//  BlockingUserCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class BlockingUserCell: UserIconCell {
    
    var nickNameLabel: UILabel?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        iconImageViewButton.x = 8.0
        iconImageViewButton.viewSize = UserIconCellIconSize
        iconImageViewButton.layer.borderWidth = 0.5
        iconImageViewButton.layer.borderColor = kBlackColor12.cgColor
        iconImageViewButton.layer.cornerRadius = iconImageViewButton.height / 2
        
        nickNameLabel = UILabel()
        nickNameLabel?.frame = CGRect(x: self.iconImageViewButton.right + 8.0, y: self.iconImageViewButton.y, width: transactionTextWidth, height: 0)
        nickNameLabel?.textColor = kBlackColor87
        nickNameLabel?.textAlignment = .left
        nickNameLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        nickNameLabel?.numberOfLines = 0
        self.contentView.addSubview(nickNameLabel!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return UserIconCellIconSize.height + UserIconCellBaseHorizontalMargin * 2
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let user: User? = cellModelObject as? User
            if user?.photo?.imageURL != nil {
                iconImageViewButton.downloadImageWithURL(user?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)
            } else {
                iconImageViewButton.setImage(kPlaceholderUserImage, for: UIControlState.normal)
            }

            
            nickNameLabel?.text = user?.nickName
            nickNameLabel?.height = (nickNameLabel?.text ?? "").getTextHeight(nickNameLabel!.font, viewWidth: nickNameLabel!.width)
        }
    }
}
