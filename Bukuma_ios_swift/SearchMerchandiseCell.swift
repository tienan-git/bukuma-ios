//
//  SearchMerchandiseCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/09.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

private let contentViewpadding: CGFloat = 15.0
private let contentViewWidth: CGFloat = kCommonDeviceWidth - contentViewpadding * 2
private let cellVerticalPadding: CGFloat = 15.0
private let cellHorizontalPadding: CGFloat = 15.0
private let bookImageWidth: CGFloat = 100.0
private let bookImageViewNormalHeight: CGFloat = bookImageWidth * 1.35
private let titleLabelPadding: CGFloat = 15.0
private let titleLabelWidth: CGFloat = contentViewWidth - bookImageWidth - cellHorizontalPadding * 2 - titleLabelPadding
private let titleLabelMaxHeight: CGFloat = 40.0
private let detailLabelPadding: CGFloat = 12.0
private let detailLabelWidth: CGFloat = titleLabelWidth
private let statusLabelHeight: CGFloat = 40.0
private let statusLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 13)

private let titleLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 14)
private let detailLabelFont: UIFont = UIFont.systemFont(ofSize: 12)

private let heartImage = UIImage(named: "heart_before")

public protocol SearchMerchandiseCellDelegate: BaseTableViewCellDelegate {
    func searchMerchandiseCellLikeButtonTapped(_ cell: SearchMerchandiseCell, completion:@escaping (_ isLiked:Bool?, _ numLike: Int) ->Void)
}

public class SearchMerchandiseCell: BaseTableViewCell {
    private var baseView: UIView?
    private var bookImageView: UIImageView?
    private var titleLabel: UILabel?
    private var detailLabel: UILabel?
    private var borderView: UIView?
    private var statusLabel: UILabel?
    private var likeButton: LikeButton?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        baseView = UIView()
        baseView?.clipsToBounds =  true
        baseView?.layer.cornerRadius = 3.0
        baseView?.frame = CGRect(x: contentViewpadding, y: contentViewpadding, width: contentViewWidth, height: 0)
        baseView?.backgroundColor = UIColor.white
        self.contentView.addSubview(baseView!)
        
        bookImageView = UIImageView()
        bookImageView?.frame = CGRect(x: cellHorizontalPadding,
                                     y: cellHorizontalPadding,
                                     width: bookImageWidth,
                                     height: 0)
        bookImageView?.contentMode = .scaleAspectFill
        bookImageView?.clipsToBounds = true
        bookImageView?.layer.cornerRadius = 3.0
        bookImageView?.layer.borderColor = kBorderColor.cgColor
        baseView?.addSubview(bookImageView!)
        
        titleLabel = UILabel()
        titleLabel!.frame = CGRect(x: bookImageView!.right + titleLabelPadding,
                                   y: bookImageView!.y,
                                   width: titleLabelWidth,
                                   height: 0)
        titleLabel!.textColor = kBlackColor87
        titleLabel!.textAlignment = .left
        titleLabel!.numberOfLines = 2
        titleLabel!.lineBreakMode = .byTruncatingTail
        titleLabel!.font = titleLabelFont
        baseView?.addSubview(titleLabel!)
        
        detailLabel = UILabel()
        detailLabel!.frame = CGRect(x: titleLabel!.x,
                                   y: 0,
                                   width: detailLabelWidth,
                                   height: 0)
        detailLabel!.textColor = kBlackColor87
        detailLabel!.textAlignment = .left
        detailLabel!.numberOfLines = 0
        detailLabel!.lineBreakMode = .byTruncatingTail
        detailLabel!.font = detailLabelFont
        baseView?.addSubview(detailLabel!)
        
        borderView = UIView()
        borderView?.backgroundColor = kBackGroundColor
        borderView?.frame = CGRect(x: cellHorizontalPadding,
                                   y: 0,
                                   width: contentViewWidth - (cellHorizontalPadding * 2),
                                   height: 0.5)
        baseView?.addSubview(borderView!)
        
        statusLabel = UILabel()
        statusLabel!.frame = CGRect(x: cellHorizontalPadding,
                                   y:0 ,
                                   width: 0,
                                   height: statusLabelHeight)
        statusLabel!.textColor = kTintGreenColor
        statusLabel!.textAlignment = .left
        statusLabel!.numberOfLines = 1
        statusLabel!.lineBreakMode = .byTruncatingTail
        statusLabel!.font = statusLabelFont
        baseView?.addSubview(statusLabel!)
        
        likeButton = LikeButton()
        self.likeButton?.frame = CGRect(x: contentViewWidth - heartImage!.size.width + 6.0 - 1.0,
                                        y: 0,
                                        width: heartImage!.size.width,
                                        height: heartImage!.size.height)
        likeButton!.addTarget(self, action: #selector(self.likeButtonTapped(_:)), for: .touchUpInside)
        self.contentView.addSubview(likeButton!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let book: Book? = object as? Book
        
        var imageHeight: CGFloat = bookImageViewNormalHeight
        
        if book?.imageHeight != nil && book?.imageWidth != nil {
            imageHeight = (book?.imageHeight?.cgfloat() ?? 0) * bookImageWidth / (book?.imageWidth?.cgfloat() ?? 0)
        }
        
        let title: String = book?.titleText() ?? ""
        
        let titleTextHeight: CGFloat = title.getTextHeight(titleLabelFont, viewWidth: titleLabelWidth)
        var titleHeight: CGFloat = 0
        if titleTextHeight > titleLabelMaxHeight {
            titleHeight = titleLabelMaxHeight
        } else {
            titleHeight = titleTextHeight
        }
        
        let detailTextHeight: CGFloat = (book?.summary ?? "").getTextHeight(detailLabelFont, viewWidth: detailLabelWidth)
        let detailMaxHeight: CGFloat = imageHeight - titleHeight - detailLabelPadding
        var detailHeight: CGFloat = 0
        
        if detailTextHeight > detailMaxHeight {
            detailHeight = detailMaxHeight
        } else {
            detailHeight = detailTextHeight
        }
        
        var bottomContents: CGFloat = 0
        
        if imageHeight > titleHeight + detailLabelPadding + detailHeight {
            bottomContents = imageHeight + cellVerticalPadding * 2
            
        } else {
            bottomContents = cellVerticalPadding * 2 + titleHeight + detailHeight + detailLabelPadding
            
        }
        
        let cellHeight: CGFloat = bottomContents + statusLabelHeight + contentViewpadding
        return cellHeight
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let book: Book? = cellModelObject as? Book
            
            var imageHeight: CGFloat = bookImageViewNormalHeight
            
            if book?.imageHeight != nil && book?.imageWidth != nil {
                imageHeight = (book?.imageHeight?.cgfloat() ?? 0) * bookImageWidth / (book?.imageWidth?.cgfloat() ?? 0)
            }
            
            bookImageView?.height = imageHeight
            
            if book?.coverImage?.url != nil {
                bookImageView?.downloadImageWithURL(book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)
            } else {
                bookImageView?.image = kPlacejolderBookImage
            }
            
            titleLabel?.text = book?.titleText()
            let titleHeight: CGFloat = (titleLabel?.text ?? "").getTextHeight(titleLabelFont, viewWidth: titleLabelWidth)
            
            if titleHeight > titleLabelMaxHeight {
                titleLabel?.height = titleLabelMaxHeight
            } else {
                titleLabel?.height = titleHeight
            }
            
            detailLabel?.text = book?.summary
            
            let detailTextHeight: CGFloat = (detailLabel?.text ?? "").getTextHeight(detailLabelFont, viewWidth: detailLabelWidth)
            let detailMaxHeight: CGFloat = imageHeight - titleLabel!.height - detailLabelPadding
            var detailHeight: CGFloat = 0

            if detailTextHeight > detailMaxHeight {
                detailHeight = detailMaxHeight
            } else {
                detailHeight = detailTextHeight
            }
            detailLabel?.height = detailHeight
            detailLabel?.y = titleLabel!.bottom + detailLabelPadding
            
            var bottomContents: CGFloat = 0
            
            if imageHeight > titleLabel!.height + detailLabelPadding + detailHeight  {
                bottomContents = imageHeight + cellVerticalPadding * 2
            } else {
                bottomContents = cellVerticalPadding * 2 + titleLabel!.height + detailHeight + detailLabelPadding
            }

            borderView?.y = bottomContents
            
            let price: String = book?.lowestPriceString(PriceStringType.yenMark) ?? ""
            if price == "売り切れです" {
                statusLabel?.text = price
            } else if price == "出品がありません" {
                 statusLabel?.text = price
            } else {
                statusLabel?.text = "\(price) / 他\(book?.merchandisesCount ?? "0")件の出品があります"
            }
            
            statusLabel?.y = borderView!.bottom
            statusLabel?.width = (statusLabel?.text ?? "").getTextWidthWithFont(statusLabelFont, viewHeight: statusLabelHeight)
            
            likeButton?.setLiked(book?.liked ?? false)
            likeButton?.y = statusLabel!.y + 10.0

            baseView?.height = statusLabel!.bottom
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func likeButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.likeButton?.setisSelected(!sender.isSelected, isAnimated: true)
            self.isUserInteractionEnabled = false
            (self.delegate as? SearchMerchandiseCellDelegate)?.searchMerchandiseCellLikeButtonTapped(self, completion: {[weak self] (isLiked, num) in
                DispatchQueue.main.async {
                    if (self?.cellModelObject as? Merchandise)?.book?.liked != isLiked {
                        (self?.cellModelObject as? Merchandise)?.book?.liked = isLiked
                        self?.likeButton?.setisSelected(isLiked!, isAnimated: true)
                    } else {
                        if isLiked != nil {
                            self?.likeButton?.setisSelected(isLiked!, isAnimated: true)
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                        self?.isUserInteractionEnabled = true
                    })
                }
            })
        }
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        if isSelected == true {
            baseView?.backgroundColor = kCellisSelectedBackgroundColor
            return
        }
        baseView?.backgroundColor = UIColor.white
        self.backgroundColor = kBackGroundColor
        self.contentView.backgroundColor = kBackGroundColor
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted == true {
            baseView?.backgroundColor = kCellisSelectedBackgroundColor
            return
        }
        baseView?.backgroundColor = UIColor.white
        self.backgroundColor = kBackGroundColor
        self.contentView.backgroundColor = kBackGroundColor
    }
}
