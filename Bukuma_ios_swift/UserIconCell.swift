//
//  UserIconCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/23.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

 let UserIconCellBaseHorizontalMargin: CGFloat = 15
 let UserIconCellBaseVerticalMargin: CGFloat = 15
 let UserIconCellIconSize: CGSize =  CGSize(width: 44, height: 44)

@objc public protocol UserIconCellDelegate:BaseTableViewCellDelegate {
    func didUserIconTapped(_ user:User?)
}

/**
 
 UserIconを保持しているCell
 
 */

open class UserIconCell: BaseTableViewCell {
    
    var iconImageViewButton: UIButton! = UIButton()
    var user: User?
    
    override func releaseSubViews() {
        super.releaseSubViews()
        iconImageViewButton = nil
    }

    override open func prepareForReuse() {
        super.prepareForReuse()

        self.iconImageViewButton.setImage(kPlaceholderUserImage, for: UIControlState.normal)
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        iconImageViewButton.frame = CGRect(x: UserIconCellBaseHorizontalMargin,y: UserIconCellBaseVerticalMargin, width: UserIconCellIconSize.width, height: UserIconCellIconSize.height)
        iconImageViewButton.clipsToBounds = true
        iconImageViewButton.imageView!.contentMode = .scaleAspectFill
        iconImageViewButton.setImage(kPlaceholderUserImage, for: UIControlState.normal)
        iconImageViewButton.layer.cornerRadius = UserIconCellIconSize.height / 2
        iconImageViewButton.addTarget(self, action: #selector(UserIconCell.userIconTapped(_:)), for: .touchUpInside)
        self.contentView.addSubview(iconImageViewButton)
        
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            if cellModelObject is User {
                self.user = cellModelObject as? User
            }
            
            if cellModelObject is Merchandise {
                self.user = (cellModelObject as? Merchandise)?.user
            }
            
            if cellModelObject is Review {
                self.user = (cellModelObject as? Review)?.user
            }
            
            if cellModelObject is Transaction {
                self.user = (cellModelObject as? Transaction)?.oppositeUser()
            }

            if cellModelObject is Activity {
                self.user = (cellModelObject as? Activity)?.user
            }
            
            if cellModelObject is ChatRoom {
                 self.user = (cellModelObject as? ChatRoom)?.chatUser
            }
        }
    }
    
    func userIconTapped(_ sender: UIButton) {
        (self.delegate as? UserIconCellDelegate)?.didUserIconTapped(self.user)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 0
    }

}
