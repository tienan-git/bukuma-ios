//
//  ActivityCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

// 下記定数は他クラスでも参照されているので注意！（変更必須！！！）
let bookImageViewWidth: CGFloat = 60.0
let bookImageViewheight: CGFloat = bookImageViewWidth * 1.35


open class ActivityCell: UserIconCell {
    
    let nickNameLabel: UILabel! = UILabel()
    var activityTextLabel: UILabel! = UILabel()
    let dateLabel: UILabel! = UILabel()
    var type: ActivityType?
    let bookImageView: UIImageView! = UIImageView()
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        iconImageViewButton.x = 8.0
        iconImageViewButton.viewSize = transactionIconSize
        iconImageViewButton.layer.borderWidth = 0.5
        iconImageViewButton.layer.borderColor = kBlackColor12.cgColor
        iconImageViewButton.layer.cornerRadius = iconImageViewButton.height / 2
        
        activityTextLabel.frame = CGRect(x: self.iconImageViewButton.right + 8.0, y: self.iconImageViewButton.y, width: transactionTextWidth, height: 0)
        activityTextLabel.textColor = kBlackColor87
        activityTextLabel.textAlignment = .left
        activityTextLabel.numberOfLines = 0
        activityTextLabel.lineBreakMode = .byTruncatingTail
        self.contentView.addSubview(activityTextLabel)
        
        dateLabel.frame = CGRect(x: activityTextLabel.x,
                                 y: activityTextLabel.bottom + 10.0,
                                 width: 150,
                                 height: dateLabelHeight)
        dateLabel.textColor = kGrayColor
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(dateLabel)
        
        bookImageView.frame = CGRect(x: kCommonDeviceWidth - bookImageViewWidth - 8.0,
                                     y: iconImageViewButton.y,
                                     width: bookImageViewWidth,
                                     height: bookImageViewheight)
        bookImageView.contentMode = .scaleAspectFill
        bookImageView.clipsToBounds = true
        bookImageView.layer.borderWidth = 0.5
        bookImageView.layer.borderColor = kBorderColor.cgColor
        self.contentView.addSubview(bookImageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        
        let activity = object as? Activity
        var string: NSAttributedString?
        var labelaHeight: CGFloat? = 0
        if activity != nil {
            string = self.generateAtrributeText(activity!)
            labelaHeight = string!.getTextHeight(transactionTextWidth)
        }
        let minHeight: CGFloat = bookImageViewheight + UserIconCellBaseHorizontalMargin * 2
        return max(minHeight, labelaHeight! + dateLabelHeight + UserIconCellBaseHorizontalMargin * 2 + 8.0)
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let activity: Activity? = cellModelObject as? Activity
            if activity?.user?.photo?.imageURL != nil {
                iconImageViewButton.downloadImageWithURL(activity?.user?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)
            } else {
                iconImageViewButton.setImage(kPlaceholderUserImage, for: UIControlState.normal)
            }
            
            if activity?.type != nil {
                activityTextLabel.attributedText = ActivityCell.generateAtrributeText(activity!)
                activityTextLabel.height = activityTextLabel.attributedText!.getTextHeight(transactionTextWidth)
                dateLabel.text = activity?.date?.timeAgoSimple()
                dateLabel.width = dateLabel.text!.getTextWidthWithFont(dateLabel.font, viewHeight: dateLabel.height)
                dateLabel.y = activityTextLabel.bottom + 9.0
            }
            if activity?.book?.coverImage?.url != nil {
                bookImageView.downloadImageWithURL(activity?.book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)
            } else {
                bookImageView.image = kPlacejolderBookImage
            }
            //bookImageView.downloadImageWithURL(activity?.book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)
        }
    }
    
     class func generateAtrributeText(_ activity: Activity) ->NSAttributedString {
        let mutableAttributedString: NSMutableAttributedString =  NSMutableAttributedString()
        let attributedNickName: NSAttributedString = NSAttributedString.init(string: self.firstBoldString(activity),
                                                                             attributes: [NSForegroundColorAttributeName:kBlackColor87, NSFontAttributeName:UIFont.boldSystemFont(ofSize: 15)])
        mutableAttributedString.append(attributedNickName)
        
        let otherNameAttributedText =  NSAttributedString.init(string: self.firstSystemString(activity),
                                                               attributes: [NSForegroundColorAttributeName:kBlackColor87, NSFontAttributeName:UIFont.systemFont(ofSize: 15)])
        mutableAttributedString.append(otherNameAttributedText)
        
        let mutableBookName: NSAttributedString = NSAttributedString.init(string: self.secondBoldString(activity),
                                                                          attributes: [NSForegroundColorAttributeName:kBlackColor87, NSFontAttributeName:UIFont.boldSystemFont(ofSize: 15)])
        mutableAttributedString.append(mutableBookName)
        let bookNameOtherAttributedText: NSAttributedString = NSAttributedString.init(string: self.secondSystemString(activity),
                                                                                      attributes: [NSForegroundColorAttributeName:kBlackColor87, NSFontAttributeName:UIFont.systemFont(ofSize: 15)])
        mutableAttributedString.append(bookNameOtherAttributedText)
        
        return mutableAttributedString
    }
    
    class func firstBoldString(_ activity: Activity) ->String {
        switch activity.type! {
        case .bounghtBooks:
            return activity.user?.nickName ?? ""
        case .likeBooks, .updateBooksPrice, .updateLikesBooksPrice:
            return activity.book?.titleText() ?? ""
        }
    }
    
     class func firstSystemString(_ activity: Activity) ->String {
        switch activity.type! {
        case .likeBooks:
            return "に"
        case .updateBooksPrice, .updateLikesBooksPrice:
            return "の"
        case .bounghtBooks:
            return "が"
        }
    }
    
    class func secondBoldString(_ activity: Activity) ->String {
        switch activity.type! {
        case .bounghtBooks:
            return activity.book?.titleText() ?? ""
        default:
            return ""
        }
    }

    class func secondSystemString(_ activity: Activity) ->String {
        switch activity.type! {
        case .likeBooks:
            return "いいねがつきました"
        case .updateBooksPrice, .updateLikesBooksPrice:
            return "最安値が更新されました"
        case .bounghtBooks:
            return "を購入しました。"
        }
    }
}
