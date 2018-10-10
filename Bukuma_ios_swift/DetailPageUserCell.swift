//
//  DetailPageUserCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/23.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

private let DetailPageUserCellBuyButtonSize: CGSize = CGSize(width: 86, height: 37.0)
let DetailPageUserCellStatusLabelHeight: CGFloat = 20.0
let DetailPageUserCellImageViewSize: CGSize = CGSize(width: 64, height: 64)
let DetailPageUserCellBuyButtonHeight: CGFloat = UIImage(named: "img_stretch_btn_red")!.size.height

@objc public protocol DetailPageUserCellDelegate: BaseTableViewDelegate {
    func detailPageUserCellBuyButtonTapped(_ cell: DetailPageUserCell)
    func detailPageUserCellImageViewTapped(_ cell: DetailPageUserCell, tag: Int)
}

open class DetailPageUserCell: UserIconCell {
    
    let officalIconImage = UIImageView()
    let userNameLabel = UILabel()
    let commentBalonImageView = UIImageView()
    let badgeNewImage = UIImageView()
    let commentLabel = UILabel()
    let shippingInfoLabel = UILabel()
    let priceLabel = UILabel()
    let discountPercentLabel = DiscountPercentLabel()
    let statusLabel = UILabel()
    let buyButton = UIButton()
    var images: [UIButton] = []
    var reviewView: UserReviewIconsView?

    deinit {
        cellModelObject = nil
    }
    
    override var rightImage: UIImage? {
        didSet {
            rightImageView!.image = rightImage
            rightImageView!.viewSize = rightImage!.size
            rightImageView!.x = kCommonDeviceWidth - rightImage!.size.width - 4.0
            rightImageView!.y = iconImageViewButton.y + (iconImageViewButton.height - rightImageView!.height) / 2
        }
    }
    
    open class func commentLabelWidth() ->CGFloat {
        return kCommonDeviceWidth - (15 * 2) - (15 * 2)
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.selectionStyle = .none
        
        self.delegate = delegate
        
        self.rightImage = UIImage(named: "ic_to")
        iconImageViewButton.x = 15.0
        iconImageViewButton.y = 15.0
        
        let iconOfficial = UIImage(named: "ic_official")!
        officalIconImage.image = iconOfficial
        officalIconImage.frame = CGRect(x: iconImageViewButton.x - 4.0, y: iconImageViewButton.y - 4.0, width: iconOfficial.size.width, height: iconOfficial.size.height)
        self.addSubview(officalIconImage)
        
        userNameLabel.frame = CGRect(x: self.iconImageViewButton.right + 15, y: self.iconImageViewButton.y + 8.0, width: kCommonDeviceWidth - self.iconImageViewButton.right + 15, height: 19)
        userNameLabel.textColor = kBlackColor87
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        userNameLabel.textAlignment = .left
        self.contentView.addSubview(userNameLabel)
        
        
        reviewView = UserReviewIconsView(sizeType: .detailPage)
        self.contentView.addSubview(reviewView!)
        
        let margin: CGFloat = (iconImageViewButton.height - userNameLabel.height - reviewView!.height) / 3
        
        userNameLabel.y = self.iconImageViewButton.y + margin
        reviewView?.y = userNameLabel.bottom + margin
        
        commentBalonImageView.frame = CGRect(x: self.iconImageViewButton.x, y: self.iconImageViewButton.bottom + 10.0, width: kCommonDeviceWidth - 15.0 * 2, height: 0)
        commentBalonImageView.image = UIImage(named: "img_stretch_comment")!.stretchableImage(withLeftCapWidth: 30, topCapHeight: 10)
        commentBalonImageView.isUserInteractionEnabled = true
        self.contentView.addSubview(commentBalonImageView)
        
        let badgeNew = UIImage(named: "img_badge_new")!
        badgeNewImage.image = badgeNew
        badgeNewImage.frame = CGRect(x: commentBalonImageView.x - 3.0, y: commentBalonImageView.y + 12.0, width: badgeNew.size.width, height: badgeNew.size.height)
        self.addSubview(badgeNewImage)
        
        commentLabel.frame = CGRect(x: 15.0,
                                    y: 0,
                                    width: type(of: self).commentLabelWidth(),
                                    height: 0)
        commentLabel.numberOfLines = 0
        commentLabel.font = UIFont.systemFont(ofSize: 15)
        commentBalonImageView.addSubview(commentLabel)
        
        shippingInfoLabel.frame = CGRect(x: 15.0, y: commentLabel.bottom + 13.0, width: type(of: self).commentLabelWidth(), height: 0)
        shippingInfoLabel.numberOfLines = 0
        shippingInfoLabel.adjustsFontSizeToFitWidth = true
        commentBalonImageView.addSubview(shippingInfoLabel)
        
        priceLabel.frame =  CGRect(x: iconImageViewButton.x, y: commentBalonImageView.bottom + 16.0, width: 100, height: 30)
        priceLabel.textAlignment = .left
        priceLabel.font = UIFont.boldSystemFont(ofSize: 21)
        priceLabel.textColor = kBlackColor87
        self.contentView.addSubview(priceLabel)

        discountPercentLabel.setup()
        self.contentView.addSubview(discountPercentLabel)

        statusLabel.frame = CGRect(x: priceLabel.x, y: priceLabel.bottom - 3.0, width: 300, height: DetailPageUserCellStatusLabelHeight)
        statusLabel.textAlignment = .left
        statusLabel.font = UIFont.boldSystemFont(ofSize: 11)
        statusLabel.textColor = kDarkGray02Color
        self.contentView.addSubview(statusLabel)
        
        buyButton.frame = CGRect(x: kCommonDeviceWidth - DetailPageUserCellBuyButtonSize.width - 15.0,
                                 y: priceLabel.y + 4.0,
                                 width: DetailPageUserCellBuyButtonSize.width,
                                 height: DetailPageUserCellBuyButtonHeight)
        buyButton.setTitleColor(UIColor.white, for: .normal)
        buyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        buyButton.clipsToBounds = true
        buyButton.layer.cornerRadius = 3.0
        buyButton.isUserInteractionEnabled = false
        buyButton.addTarget(self, action: #selector(self.buyButtonTapped(_:)), for: .touchUpInside)
        self.contentView.addSubview(buyButton)

        for i in 0...2 {
            let imageView: UIButton! = UIButton()
            imageView.viewSize = CGSize(width: DetailPageUserCellImageViewSize.width, height: DetailPageUserCellImageViewSize.height)
            imageView.contentMode = .scaleAspectFit
            imageView.x = self.iconImageViewButton.x + 10 * (CGFloat(i)) + imageView.width * (CGFloat(i))
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 2.0
            imageView.tag = i
            imageView.backgroundColor = UIColor.clear
            imageView.isHidden = true
            imageView.addTarget(self, action: #selector(self.imageViewTapped(_:)), for: .touchUpInside)
            images.append(imageView)
            commentBalonImageView.addSubview(imageView)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageViewTapped(_ sender: UIButton) {
        (self.delegate as? DetailPageUserCellDelegate)?.detailPageUserCellImageViewTapped(self, tag: sender.tag)
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let merchandise: Merchandise? = object as? Merchandise
        
        if object is Merchandise {
            let isSeries: Bool = Utility.isEmpty(merchandise?.seriesDespription) == false
            
            var commentTextHeight: CGFloat = 0
            var shippingInfoHeight: CGFloat = 0
            var ballonImageViewHeight: CGFloat = 0
            
            var isOnlyShippingInfo: Bool = true
            
            if Utility.isEmpty(merchandise?.comment) == false {
                commentTextHeight = merchandise!.comment!.getTextHeight(UIFont.systemFont(ofSize: 15), viewWidth: kCommonDeviceWidth - 30.0 * 2) + 19.0
                isOnlyShippingInfo = false
            }

            shippingInfoHeight = merchandise!.shippingInfoAttribute()!.getTextHeight(kCommonDeviceWidth - 30.0 * 2)
            
            ballonImageViewHeight = commentTextHeight + shippingInfoHeight + 11.0
            ballonImageViewHeight += isOnlyShippingInfo ? 19.0 : 15.0
            ballonImageViewHeight += (merchandise?.isBrandNew ?? false) ? 15.0 : 0.0
            
            if isSeries {
                if  (merchandise?.photos?.count ?? 0) > 0 {
                    let photoHeight: CGFloat = DetailPageUserCellImageViewSize.height + 15.0
                    ballonImageViewHeight += photoHeight
                }
            }
            
            let buyButtonHeight: CGFloat = DetailPageUserCellBuyButtonHeight + 20.0 + 15.0
            return UserIconCellBaseVerticalMargin + 10.0 + UserIconCellIconSize.height + ballonImageViewHeight + buyButtonHeight
            
        }
        
        return 0
    }
    
    override open var cellModelObject: AnyObject? {
        didSet (oldValue){
            let merchandise: Merchandise? = cellModelObject as? Merchandise
            
            if cellModelObject is Merchandise {
                self.releaseContents()
                
                officalIconImage.isHidden = !(merchandise?.user?.isOfficial ?? false)
                
                if user?.identifier == nil  {
                    userNameLabel.text = "退会したユーザー"
                } else {
                    userNameLabel.text = merchandise?.user?.nickName
                }
                
                if merchandise?.user?.photo?.imageURL != nil {
                    iconImageViewButton.downloadImageWithURL(merchandise?.user?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)
                } else {
                    iconImageViewButton.setImage(kPlaceholderUserImage, for: UIControlState.normal)
                }
                
                if merchandise != nil {
                    statusLabel.text = "商品の状態: \(merchandise!.statusString())"
                }
                
                reviewView?.user = merchandise?.user
                reviewView?.x = userNameLabel.x
                commentBalonImageView.height = 0
                
                var isOnlyShippingInfo: Bool = true
                let merchandiseIsNew = merchandise?.isBrandNew ?? false
                
                badgeNewImage.isHidden = !merchandiseIsNew
                
                var commentLabelHeight: CGFloat = 0
                if Utility.isEmpty(merchandise?.comment) == false {
                    commentLabel.y = merchandiseIsNew ? 34.0 : 19.0
                    commentLabel.text = merchandise!.comment
                    commentLabel.height = commentLabel.text!.getTextHeight(commentLabel.font, viewWidth: commentLabel.width)
                    commentLabelHeight = commentLabel.height + 19.0
                    isOnlyShippingInfo = false
                }
                
                if isOnlyShippingInfo {
                    shippingInfoLabel.y = merchandiseIsNew ? 33.0 : 18.0
                } else {
                    shippingInfoLabel.y = commentLabel.bottom + 11.0
                }
                
                
                shippingInfoLabel.attributedText = merchandise!.shippingInfoAttribute()
                shippingInfoLabel.height = shippingInfoLabel.attributedText!.getTextHeight(commentLabel.width)
                
                var i: Int = 0
                var photoHeight: CGFloat = 0
                if !Utility.isEmpty(merchandise?.seriesDespription) {
                    if (merchandise?.photos?.count ?? 0) > 0 {
                        photoHeight += DetailPageUserCellImageViewSize.height + 15.0
                        for imageView in images {
                            if i <= merchandise!.photos!.count - 1 {
                                imageView.y = shippingInfoLabel.bottom + 15.0
                                imageView.isHidden = false
                                imageView.downloadImageWithURL(merchandise?.photos![i].imageURL, placeholderImage: kPlacejolderBookImage)
                                i += 1
                            }
                        }
                    } else {
                        for imageView in images {
                            imageView.isHidden = true
                        }
                    }
                }
                
                commentBalonImageView.height = commentLabelHeight + shippingInfoLabel.height + 11.0 +  photoHeight
                commentBalonImageView.height += isOnlyShippingInfo ? 19.0 : 15.0
                commentBalonImageView.height += merchandiseIsNew ? 15.0 : 0.0
                
                priceLabel.y =  commentBalonImageView.bottom + 13.0
                statusLabel.y = priceLabel.bottom - 4.5
                buyButton.y = priceLabel.y + 4.0
                buyButton.isUserInteractionEnabled = true
                
                if merchandise?.isSold == true {
                    buyButton.setTitle("売り切れ", for: .normal)
                    buyButton.setBackgroundImage(UIImage(named: "img_stretch_btn_disabled")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
                } else {
                    if Me.sharedMe.isMine(merchandise?.user?.identifier ?? "0") == true {
                        buyButton.setTitle("編集する", for: .normal)
                        buyButton.setBackgroundImage(UIImage(named: "img_stretch_btn_gray_dk")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
                    } else {
                        buyButton.setTitle("購入手続きへ", for: .normal)
                        buyButton.setBackgroundImage(UIImage(named: "img_stretch_btn_red")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
                    }
                }
                buyButton.sizeToFit()

                DBLog(merchandise?.price)
                
                merchandise?.price.map {
                    priceLabel.text = "¥ \($0.int().thousandsSeparator())"
                    priceLabel.width = priceLabel.text!.getTextWidthWithFont(priceLabel.font, viewHeight: priceLabel.height)
                }

                self.discountPercentLabel.isHidden = merchandise?.isSold == false && (merchandise?.book?.isVisibleDiscountPercent(with: Int((merchandise?.price)!)))! ? false : true
                self.discountPercentLabel.setTextIfNeeded(with: (merchandise?.book?.discountPercentString(with: Int((merchandise?.price)!)))!)
            }
        }
    }
    
    fileprivate func releaseContents() {
        commentLabel.text = nil
    }
    
    func buyButtonTapped(_ sender: UIButton) {
        (self.delegate as? DetailPageUserCellDelegate)?.detailPageUserCellBuyButtonTapped(self)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        let rightMargin: CGFloat = 15
        let horizontalInternalMargin: CGFloat = 20
        var frame = self.buyButton.frame
        frame.size.width += horizontalInternalMargin
        frame.origin.x = self.contentView.frame.maxX - rightMargin - frame.width
        self.buyButton.frame = frame

        self.discountPercentLabel.layoutIfNeeded(with: self.priceLabel)
    }
}
