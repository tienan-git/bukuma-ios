//
//  UserPageTimelineCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit

private let DateLabelWidth: CGFloat = 45
private let NickNameLabelHeight: CGFloat = 15.0
private let CommentLabelFont: UIFont = UIFont.systemFont(ofSize: 13)

open class UserPageTimelineCell: UserIconCell {
    
    var userNameLabel: UILabel! = UILabel()
    var commentLabel: UILabel! = UILabel()
    let dateLabel: UILabel! = UILabel()
    var reviewView: UserPageReviewView?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        iconImageViewButton.x = 16.0
        iconImageViewButton.y = 16.0
        iconImageViewButton.layer.borderWidth = 0.5
        iconImageViewButton.layer.borderColor = kBorderColor.cgColor
        
        userNameLabel.frame = CGRect(x: self.iconImageViewButton.right + 12,
                                     y: self.iconImageViewButton.y,
                                     width: kCommonDeviceWidth - self.iconImageViewButton.right + 15,
                                     height: NickNameLabelHeight)
        userNameLabel.textColor = kBlackColor87
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        userNameLabel.textAlignment = .left
        self.contentView.addSubview(userNameLabel)
        
        dateLabel.viewSize = CGSize(width: DateLabelWidth, height: 13)
        dateLabel.textAlignment = .center
        dateLabel.textColor = kGray03Color
        dateLabel.font = UIFont.boldSystemFont(ofSize: 11)
        self.contentView.addSubview(dateLabel)
        
        reviewView = UserPageReviewView()
        reviewView?.x = userNameLabel.x
        self.contentView.addSubview(reviewView!)
        
        commentLabel.frame = CGRect(x: iconImageViewButton.x,
                                    y: iconImageViewButton!.bottom + 17.0,
                                    width: type(of: self).commentWidth(),
                                    height: 0.0)
        commentLabel.font = CommentLabelFont
        commentLabel.numberOfLines = 0
        self.contentView.addSubview(commentLabel)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate class func commentWidth() ->CGFloat {
        return kCommonDeviceWidth - 16.0 * 2
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let review: Review? = object as? Review
        var commentHeight: CGFloat = 0
        if !Utility.isEmpty(review?.comment) {
            commentHeight = review!.comment!.getTextHeight(CommentLabelFont, viewWidth: self.commentWidth())
        }
        let minHeight: CGFloat = UserIconCellIconSize.height + 16.0 * 2
        let maxHeight: CGFloat = 16.0 + UserIconCellIconSize.height + 17.0 + commentHeight + 25.0
        return maxHeight > minHeight ? maxHeight : minHeight
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let review: Review? = cellModelObject as? Review
            if review?.user?.photo?.imageURL != nil {
                iconImageViewButton.downloadImageWithURL(review?.user?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)
            } else {
                iconImageViewButton.setImage(kPlaceholderUserImage, for: .normal)
            }
            
            userNameLabel.text = review?.user?.nickName
            if Utility.isEmpty(review?.user?.identifier) || Utility.isEmpty(review?.user) {
                userNameLabel.text = "退会したユーザー"
            }

            dateLabel.text = review?.createdAt?.timeAgoSimple()
            dateLabel.width = dateLabel.text!.getTextWidthWithFont(dateLabel.font, viewHeight: dateLabel.height)
            dateLabel.viewOrigin = CGPoint(x: kCommonDeviceWidth - dateLabel.width - 16.0, y: userNameLabel.y)
            
            reviewView?.type = review?.type
            
            reviewView?.viewOrigin = CGPoint(x: userNameLabel.x, y: userNameLabel.bottom + 9.0)
            
            commentLabel?.text = review?.comment
            if !Utility.isEmpty(review?.comment) {
                commentLabel.height = commentLabel.text!.getTextHeight(commentLabel.font, viewWidth: commentLabel.width)
            }
        }
    }
}
