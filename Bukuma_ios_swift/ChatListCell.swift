//
//  ChatListCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/13.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

private let MaxLastMessageHeight:CGFloat = 42.0
private let LastMessageLabelFont: UIFont = UIFont.systemFont(ofSize: 13)
private let DateLabelWidth: CGFloat = 45
private let NickNameLabelHeight: CGFloat = 15.0

open class ChatListCell: UserIconCell {
    
    fileprivate var userNameLabel: UILabel! = UILabel()
    fileprivate var evaluateImageView: UIImageView! = UIImageView()
    fileprivate var lastMessageLabel: UILabel! = UILabel()
    fileprivate let dateLabel: UILabel! = UILabel()
    var unReadCountLabel: UILabel?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        iconImageViewButton.x = 12.0
        iconImageViewButton.y = 12.0
        iconImageViewButton.layer.borderWidth = 0.5
        iconImageViewButton.layer.borderColor = kBorderColor.cgColor
        iconImageViewButton.downloadImageWithURL(user?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)
        
        userNameLabel.frame = CGRect(x: self.iconImageViewButton.right + 12.0,
                                     y: self.iconImageViewButton.y,
                                     width: kCommonDeviceWidth - self.iconImageViewButton.right + 12.0,
                                     height: NickNameLabelHeight)
        userNameLabel.textColor = kBlackColor87
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        userNameLabel.textAlignment = .left
        self.contentView.addSubview(userNameLabel)
        
        dateLabel.viewSize = CGSize(width: DateLabelWidth, height: 13)
        dateLabel.viewOrigin = CGPoint(x: kCommonDeviceWidth - dateLabel.width - 10.0, y: userNameLabel.y)
        dateLabel.textAlignment = .center
        dateLabel.textColor = kGrayColor
        dateLabel.font = UIFont.systemFont(ofSize: 11)
        self.contentView.addSubview(dateLabel)
        
        lastMessageLabel.frame = CGRect(x: self.userNameLabel.x,
                                        y: self.userNameLabel.bottom + 5.0,
                                        width: type(of: self).lastMessageWidth(),
                                        height: 0.0)
        lastMessageLabel.font = LastMessageLabelFont
        lastMessageLabel.numberOfLines = 2
        lastMessageLabel.lineBreakMode = .byTruncatingTail
        self.contentView.addSubview(lastMessageLabel)
        
        unReadCountLabel = UILabel()
        unReadCountLabel?.viewSize = CGSize(width: 28.0, height: 20.0)
        unReadCountLabel?.textAlignment = .center
        unReadCountLabel?.clipsToBounds = true
        unReadCountLabel?.layer.cornerRadius = 10.0
        unReadCountLabel?.isHidden = true
        unReadCountLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        unReadCountLabel?.backgroundColor = kTintGreenColor
        unReadCountLabel?.textColor = UIColor.white
        self.contentView.addSubview(unReadCountLabel!)
    }
    
    fileprivate class func lastMessageWidth() ->CGFloat {
        return kCommonDeviceWidth - UserIconCellBaseHorizontalMargin * 2 - UserIconCellIconSize.width - DateLabelWidth - 10.0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let realHeight: CGFloat? = realHeightForObject(object)
        let minHeight: CGFloat = UserIconCellIconSize.height + 12.0 * 2
        return minHeight > realHeight! ? minHeight : realHeight ?? 0
    }
    
    class func realHeightForObject(_ object: AnyObject?) ->CGFloat {
        let chatRoom: ChatRoom? = object as? ChatRoom
        var textHeight: CGFloat = self.lastMessageText(chatRoom).replaceLineBreakeToSpace().getTextHeight(LastMessageLabelFont, viewWidth: self.lastMessageWidth())
        textHeight = MaxLastMessageHeight > textHeight ? textHeight : MaxLastMessageHeight
        return textHeight + NickNameLabelHeight + 12 * 2 + 9.0
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let chatRoom: ChatRoom? = cellModelObject as? ChatRoom
            userNameLabel.text = chatRoom?.chatUser?.nickName
            lastMessageLabel.text = type(of: self).lastMessageText(chatRoom)
            
            let textRealHeight: CGFloat? = lastMessageLabel.text?.getTextHeight(LastMessageLabelFont, viewWidth: type(of: self).lastMessageWidth()) ?? 0
            let textHeight: CGFloat = textRealHeight! > MaxLastMessageHeight ? MaxLastMessageHeight : textRealHeight!
            lastMessageLabel.height = textHeight
            if chatRoom?.chatUser?.photo?.imageURL != nil {
                 iconImageViewButton.downloadImageWithURL(chatRoom?.chatUser?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)
            } else {
                iconImageViewButton.setImage(kPlaceholderUserImage, for: UIControlState.normal)
            }
           
            
            dateLabel.text = chatRoom?.lastUpdateDate?.timeAgoSimple()
            dateLabel.width = dateLabel.text!.getTextWidthWithFont(dateLabel.font, viewHeight: dateLabel.height)
            dateLabel.viewOrigin = CGPoint(x: self.contentView.width - dateLabel.width - 10.0, y: userNameLabel.y)
            
            unReadCountLabel?.text = chatRoom?.numberOfUnreadCount?.string()
            unReadCountLabel?.isHidden = true
            if (chatRoom?.numberOfUnreadCount ?? 0) > 0 {
                unReadCountLabel?.isHidden = false
            }
            unReadCountLabel?.viewOrigin = CGPoint(x: dateLabel!.right - unReadCountLabel!.width,
                                               y: lastMessageLabel.y)
        }
    }
    
    class func lastMessageText(_ room: ChatRoom?) ->String {
        if Utility.isEmpty(room) {
            return ""
        }
        
        if room?.isClosed == true {
            return "ユーザーが退出しました"
        }
        
        if room?.message?.messageType == .text || room?.message?.messageType == MessageType.merchandise {
            return room?.message?.text ?? ""
        } else if room?.message?.messageType == .image {
            return "✓画像を送信しました"
        }
        
        if room?.message?.itemTrasaction?.type == TransactionListType.sellerPrepareShipping {
            return "✓商品を購入しました"
        } else if room?.message?.itemTrasaction?.type == TransactionListType.sellerShipped {
            return "✓発送完了しました"
        } else if room?.message?.itemTrasaction?.type == TransactionListType.buyerItemArried {
            return "✓購入者が出品者を評価しました"
        } else if room?.message?.itemTrasaction?.type == TransactionListType.sellerReviewBuyer {
            return "✓出品者が購入者を評価しました"
        } else if room?.message?.itemTrasaction?.type == TransactionListType.finishedTransaction {
            return "✓取引が終了しました"
        } else if room?.message?.itemTrasaction?.type == TransactionListType.cancelled {
            return "✓取引がキャンセルされました"
        }
        return ""
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        dateLabel.viewOrigin = CGPoint(x: self.contentView.width - dateLabel.width - 10.0, y: userNameLabel.y)
        unReadCountLabel?.viewOrigin = CGPoint(x: dateLabel!.right - unReadCountLabel!.width,
                                           y: lastMessageLabel.y)
    }
}
