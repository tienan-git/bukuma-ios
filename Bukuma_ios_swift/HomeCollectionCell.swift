//
//  BKMDiscoverCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/09.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public let HomeCollectionCellIdentifier = "HomeCollectionCellIdentifier"
private let kBoederBackGroundGrayColor = UIColor.colorWithHex(0xE1E1E1)
private let HomeCollectionCellTextGrayColor = UIColor.colorWithHex(0x959EA7)

let HomeCollectionCellVerticalMargin: CGFloat = 10
let HomeCollectionCellHorizontalMargin:CGFloat = 10

private let bookTitleLabelFont: UIFont = UIFont.systemFont(ofSize: 13)
private let numLabelFont: UIFont = UIFont.systemFont(ofSize: 13)
private let titleLabelVerticalpadding: CGFloat = 12.0
private let priceLabelVerticalPadding: CGFloat = 6.0
private let numLabelHeight: CGFloat = 20.0

public protocol HomeCollectionCellDelegate: BaseCollectionCellDelegate {
    func homeCellLikeButtonTapped(_ cell: HomeCollectionCell, completion:@escaping (_ isLiked:Bool?, _ numLike: Int) ->Void)
}

open class HomeCollectionCell: BaseCollectionCell {
    
    var baseSeriesImageView: UIView = UIView()
    var bookTitleLabel: UILabel? = UILabel()
    var bookPriceLabel: UILabel? = UILabel()
    var discountPercentLabel: DiscountPercentLabel? = DiscountPercentLabel()
    var likeButton: LikeButton?
    var isSeriesImageView: UIImageView? = UIImageView()
    let image = UIImage(named: "heart_before")
    var resize: CGSize = CGSize.zero
    let seriesImage: UIImage = UIImage(named: "img_badge_pkg")!
    let soldImage: UIImage = UIImage(named: "img_badge_soldout")!
    var numLikeLabel: UILabel?
    
    override func releaseSubViews() {
        super.releaseSubViews()
        bookTitleLabel = nil
        bookPriceLabel = nil
        discountPercentLabel = nil
        likeButton = nil
        isSeriesImageView?.image = nil
        isSeriesImageView = nil
    }
    
    public required init(frame: CGRect) {
        super.init(frame: frame)
        
        bookImageView?.clipsToBounds = true
        
        // self.contentView ではなくself
        baseSeriesImageView.frame = CGRect(x: -3.0, y: 10.0, width: 0, height: 0)
        baseSeriesImageView.clipsToBounds = false
        self.addSubview(baseSeriesImageView)
        
        isSeriesImageView! = UIImageView(image: seriesImage)
        isSeriesImageView!.y = 0
        isSeriesImageView!.x = 0
        isSeriesImageView!.clipsToBounds = false
        isSeriesImageView!.isHidden = true
        baseSeriesImageView.addSubview(isSeriesImageView!)
        
        bookTitleLabel!.frame = CGRect(x: HomeCollectionCellHorizontalMargin + 2,
                                       y: 0,
                                       width: self.contentView.width - (HomeCollectionCellHorizontalMargin + 3) * 2,
                                       height: type(of: self).bookTitleLablHeight())
        bookTitleLabel!.textColor = kGray03Color
        bookTitleLabel!.textAlignment = .left
        bookTitleLabel!.font = bookTitleLabelFont
        bookTitleLabel!.numberOfLines = 2
        bookTitleLabel!.lineBreakMode = .byTruncatingTail
        
        self.contentView.addSubview(bookTitleLabel!)
                
        self.bookPriceLabel!.frame = CGRect(x: HomeCollectionCellHorizontalMargin + 2,
                                            y: 0,
                                            width: self.contentView.width / 2,
                                            height: 20.0)
        bookPriceLabel!.textColor = kBlackColor87
        bookPriceLabel!.font = UIFont.boldSystemFont(ofSize: 13)
        bookPriceLabel!.textAlignment = .right
        self.contentView.addSubview(bookPriceLabel!)

        discountPercentLabel!.setup()
        self.contentView.addSubview(discountPercentLabel!)

        likeButton = LikeButton()
        self.likeButton?.frame = CGRect(x: self.contentView.width - self.image!.size.width + 6.0 - 1.0,
                                        y: 0,
                                        width: self.image!.size.width,
                                        height: self.image!.size.height)
        likeButton!.addTarget(self, action: #selector(self.likeButtonTapped(_:)), for: .touchUpInside)
        self.contentView.addSubview(likeButton!)
        
        numLikeLabel = UILabel()
        numLikeLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: numLabelHeight)
        numLikeLabel?.font = numLabelFont
        numLikeLabel?.textColor = kGray03Color
        numLikeLabel?.textAlignment = .left
        numLikeLabel?.lineBreakMode = .byTruncatingTail
        self.contentView.addSubview(numLikeLabel!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGSize {
        var imageHeight: CGFloat = BaseCollectionCell.homeBookImageViewHeight()
        let gridWidth: CGFloat = (kCommonDeviceWidth - 10 * 3) / 2
        let book: Book? = object as? Book
        
        if book?.imageHeight != nil && book?.imageWidth != nil {
            imageHeight = book!.imageHeight!.cgfloat() * gridWidth / book!.imageWidth!.cgfloat()
        }
        
        let priceHeight: CGFloat = 30.0
        let text: String = book?.titleText() ?? ""
        
        var bookTitleHeight: CGFloat = text.getTextHeight(bookTitleLabelFont, viewWidth: gridWidth - (HomeCollectionCellHorizontalMargin + 3) * 2)
        if bookTitleHeight > HomeCollectionCell.bookTitleLablHeight() {
            bookTitleHeight = HomeCollectionCell.bookTitleLablHeight()
        }
        let cellHeight: CGFloat = imageHeight + bookTitleHeight + priceHeight + priceLabelVerticalPadding + titleLabelVerticalpadding
        return CGSize(width: gridWidth, height: cellHeight)
    }
    
    override open var cellModelObject:AnyObject? {
        
        didSet(oldValue) {
            let book: Book? = cellModelObject as? Book
            
            if book == nil && book?.identifier == nil {
                return
            }
            
            var imageHeight: CGFloat = type(of: self).homeBookImageViewHeight()
            let gridWidth: CGFloat = (kCommonDeviceWidth - 10 * 3) / 2
            book.map {
                if $0.imageHeight != nil && $0.imageWidth != nil {
                    imageHeight = ($0.imageHeight?.cgfloat() ?? 0) * gridWidth / ($0.imageWidth?.cgfloat() ?? 0)
                }
            }
            
            bookImageView?.viewSize = CGSize(width: gridWidth, height: imageHeight)
            
            isSeriesImageView?.isHidden = true
            
            if !Utility.isEmpty(book?.lastLowestMerchandiseId) &&
                (book?.lowestMerchandise?.id == nil || (Utility.isEmpty(book?.lowestMerchandise) || Utility.isEmpty(book?.lowestMerchandise?.id))) {
                isSeriesImageView?.isHidden = false
                isSeriesImageView?.image = nil
                isSeriesImageView?.image = soldImage
                isSeriesImageView?.viewSize = soldImage.size
                isSeriesImageView?.x = 0
                isSeriesImageView?.y = 0
                baseSeriesImageView.frame = isSeriesImageView!.frame
            }
            
            bookTitleLabel?.text = book?.titleText()             
            var bookTitleHeight: CGFloat = (bookTitleLabel?.text ?? "").getTextHeight(bookTitleLabelFont, viewWidth: bookTitleLabel!.width)
            if bookTitleHeight > type(of: self).bookTitleLablHeight() {
                bookTitleHeight = type(of: self).bookTitleLablHeight()
            }
            bookTitleLabel?.height = bookTitleHeight
            bookTitleLabel?.y = bookImageView!.bottom + titleLabelVerticalpadding
            
            bookPriceLabel?.text = book?.lowestPriceString(.yenKanji)
            bookPriceLabel?.width = book!.lowestPriceString(.yenKanji).getTextWidthWithFont(bookPriceLabel!.font, viewHeight: bookPriceLabel!.height)
            bookPriceLabel?.y = bookTitleLabel!.bottom + priceLabelVerticalPadding

            self.discountPercentLabel!.isHidden = book!.isVisibleDiscountPercent() ? false : true
            self.discountPercentLabel!.setTextIfNeeded(with: book!.discountPercentString())

            likeButton?.y = bookPriceLabel!.y - self.image!.size.height / 6 - priceLabelVerticalPadding
            
            if book?.isSeries == true {
                self.isSeriesImageView?.isHidden = false
                
                self.isSeriesImageView?.image = nil
                self.isSeriesImageView?.image = seriesImage
                isSeriesImageView?.viewSize = seriesImage.size
                
                baseSeriesImageView.viewSize = isSeriesImageView!.viewSize
                baseSeriesImageView.viewOrigin = CGPoint(x: -3.0, y: 10.0)
                
                if book?.lowestMerchandise?.id == nil || Utility.isEmpty(book?.lowestMerchandise) {
                    self.isSeriesImageView?.image = nil
                    self.isSeriesImageView?.image = soldImage
                    isSeriesImageView?.viewSize = soldImage.size
                    isSeriesImageView?.x = 0
                    isSeriesImageView?.y = 0
                    baseSeriesImageView.frame = isSeriesImageView!.frame
                }
            }
            
            if book?.liked != nil {
                self.likeButton?.setLiked(book!.liked!)
            } else {
                self.likeButton?.setLiked(false)
            }
            
            let maxNumWidth: CGFloat = 28.0
            numLikeLabel?.text = book?.numOfLike?.string()
            
            let numWidth: CGFloat = (numLikeLabel?.text ?? "").getTextWidthWithFont(numLabelFont, viewHeight: numLabelHeight)
            if maxNumWidth < numWidth {
                numLikeLabel?.width = maxNumWidth
            } else {
                numLikeLabel?.width = numWidth
            }
            
            numLikeLabel?.y = bookPriceLabel?.y ?? 0
            numLikeLabel?.right = bookTitleLabel?.right ?? 0
            
            likeButton?.x = self.contentView.width - self.image!.size.width + 6.0 - 1.0 - numLikeLabel!.width - 5.0
            
            bookImageView?.image = kPlacejolderBookImage
            if book?.coverImage?.url != nil {
                bookImageView?.downloadImageWithURL(book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)
            }
        }
    }
    
    func likeButtonTapped(_ sender: LikeButton) {
        
        DispatchQueue.main.async {
            self.likeButton?.setisSelected(!sender.isSelected, isAnimated: true)
            self.isUserInteractionEnabled = false
            (self.delegate as? HomeCollectionCellDelegate)?.homeCellLikeButtonTapped(self, completion: {[weak self] (isLiked, num) in
                DispatchQueue.main.async {
                    if (self?.cellModelObject as? Book)?.liked != isLiked {
                        (self?.cellModelObject as? Book)?.liked = isLiked
                        self?.likeButton?.setisSelected(isLiked!, isAnimated: true)
                        self?.numLikeLabel?.text = num.string()
                        self?.likeButtonLayout()
                    } else {
                        if isLiked != nil {
                            self?.likeButton?.setisSelected(isLiked!, isAnimated: true)
                            self?.numLikeLabel?.text = num.string()
                            self?.likeButtonLayout()
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                        self?.isUserInteractionEnabled = true
                    })
                }
            })
        }
    }
    
    private func likeButtonLayout() {
        let maxNumWidth: CGFloat = 28.0
        let numWidth: CGFloat = (numLikeLabel?.text ?? "").getTextWidthWithFont(numLabelFont, viewHeight: numLabelHeight)
        if maxNumWidth < numWidth {
            numLikeLabel?.width = maxNumWidth
        } else {
            numLikeLabel?.width = numWidth
        }
        
        numLikeLabel?.right = bookTitleLabel?.right ?? 0
        
        likeButton?.x = self.contentView.width - self.image!.size.width + 6.0 - 1.0 - numLikeLabel!.width - 5.0
    }
    
    fileprivate func generateAtrributeText(_ number: String, endingString: String) ->NSAttributedString {
        let mutableAttributedString: NSMutableAttributedString =  NSMutableAttributedString()
        let insertNumberString: String = "\(number)"
        
        let name: NSAttributedString = NSAttributedString.init(string: insertNumberString,
                                                               attributes: [NSForegroundColorAttributeName:HomeCollectionCellTextGrayColor, NSFontAttributeName:UIFont.boldSystemFont(ofSize: 12)])
        mutableAttributedString.append(name)
        
        let otherText: NSMutableAttributedString = NSMutableAttributedString.init(string: endingString,
                                                                                  attributes: [NSForegroundColorAttributeName:HomeCollectionCellTextGrayColor, NSFontAttributeName:UIFont.systemFont(ofSize: 12)])
        
        mutableAttributedString.append(otherText)
        return mutableAttributedString
    }
    
    class func bookTitleLablHeight() ->CGFloat {
        if UIScreen.is4inchDisplay() {
            return 35.0
        }
        if UIScreen.is3_5inchDisplay() {
            return 40.0
        }
        
        return 33.0
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        self.discountPercentLabel!.layoutIfNeeded(with: self.bookPriceLabel!)
    }
}

open class LikeButton: UIButton {
    
    required public init() {
        super.init(frame: CGRect.zero)
        self.isExclusiveTouch = false
        self.isUserInteractionEnabled = true
        self.imageView?.contentMode = .center
        self.clipsToBounds = false
        self.imageView?.clipsToBounds = false
        self.imageView?.animationImages = self.buttonImages()
        self.imageView?.animationDuration = 0.6
        self.imageView?.animationRepeatCount = 1
        self.titleLabel?.minimumScaleFactor = 0.75
        self.backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func buttonImages() ->Array<UIImage> {
        var array: Array<UIImage> = Array()
        for i in 1...29 {
            let imagePath: String = "heart_\(i)"
            let image: UIImage = UIImage(named: imagePath)!
            array.append(image)
        }
        return array
    }
    
    open func setisSelected(_ isSelected: Bool, isAnimated: Bool?) {
        if isAnimated == true && isSelected == true {
            self.setImage(UIImage(named: "heart_after"), for: .normal)
            self.imageView?.startAnimating()
        } else {
            self.imageView?.stopAnimating()
            self.setImage(UIImage(named: "heart_before"), for: .normal)
        }
        
        super.isSelected = isSelected
    }
    
    open func setLiked(_ liked: Bool) {
        if liked {
            self.setImage(UIImage(named: "heart_after"), for: .normal)
            super.isSelected = true
            return
        }
        super.isSelected = false
        self.setImage(UIImage(named: "heart_before"), for: .normal)
    }
}
