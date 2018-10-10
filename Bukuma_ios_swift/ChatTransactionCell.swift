//
//  ChatTransactionCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

private let statusLabelHeight: CGFloat = 15.0
private let statusLabelMergin: CGFloat = 6.0
private let priceLabelMergin: CGFloat = 12.0

private let statusLabelFont: UIFont = UIFont.systemFont(ofSize: 10)

private let shippingImageSize: CGSize = CGSize(width: 30.0, height: 12.0)

open class ChatTransactionCell: BookIconCell {
    
    fileprivate var priceLabel: UILabel?
    fileprivate var shippingIncludeImageView: UIImageView?
    fileprivate var statusLabel: UILabel?
    
    override class func bookImageViewNormalSize() ->CGSize {
        return CGSize(width: 40.0, height: 54.0)
    }

    override class func bookTitleLabelFont() ->UIFont {
        return UIFont.boldSystemFont(ofSize: 13)
    }
    
    class func priceLabelFont(_ merchandise: Merchandise) ->UIFont {
        if  merchandise.isSold == true {
           return UIFont.systemFont(ofSize: 12)
        } else {
            return UIFont.boldSystemFont(ofSize: 16)
        }
    }
    
    class func priceLabelHeight(_ merchandise: Merchandise) ->CGFloat {
        if  merchandise.isSold == true {
            return 12.0
        } else {
            return 20.0
        }
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        bookTitleLabel?.textColor = UIColor.colorWithHex(0x212121)

        bookAutherNameLabel?.isHidden = true
        bookPublisherCompanyNameLabel?.isHidden = true
        
        priceLabel = UILabel()
        priceLabel?.textColor = UIColor.colorWithHex(0x38454e)
        priceLabel?.textAlignment = .center
        self.contentView.addSubview(priceLabel!)

        let image: UIImage = UIImage(named: "ic_shipping_included")!
        shippingIncludeImageView = UIImageView()
        shippingIncludeImageView?.image = image
        shippingIncludeImageView?.viewSize = shippingImageSize
        shippingIncludeImageView?.clipsToBounds = true
        self.contentView.addSubview(shippingIncludeImageView!)
        
        statusLabel = UILabel()
        statusLabel?.font = statusLabelFont
        statusLabel?.textColor = UIColor.colorWithHex(0x38454e)
        statusLabel?.height = statusLabelHeight
        statusLabel?.textAlignment = .center
        self.contentView.addSubview(statusLabel!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func bookImageViewSize(_ book: Book?) ->CGSize {
        if book == nil || book?.imageWidth == nil || book?.imageHeight == nil {
            return self.bookImageViewNormalSize()
        }
        
        return CGSize(width: self.bookImageViewNormalSize().width, height: (self.bookImageViewNormalSize().width * book!.imageHeight!.cgfloat()) / book!.imageWidth!.cgfloat())
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let merchandise: Merchandise? = object as? Merchandise
        return self.cellHeight(merchandise?.book)
    }
    
    override class func cellHeight(_ book: Book?) ->CGFloat {
        var titleHeight: CGFloat = 0
        
        let bookImageViewSize: CGSize = self.bookImageViewSize(book)
        
        
        titleHeight = (book?.titleText() ?? "").getTextHeight(self.bookTitleLabelFont(), viewWidth: self.bookTitleMaxWidth(bookImageViewSize.width))
        
        let shortTitleHeight: CGFloat = bookImageViewSize.height + 12 * 2
        let contentsHeight: CGFloat =  titleHeight + shippingImageSize.height + (12 * 2) + priceLabelMergin
        if shortTitleHeight > contentsHeight {
            return shortTitleHeight
        } else {
            return contentsHeight
        }
    }
    
    override class func isBookTitleLonger(_ book: Book?) ->Bool {
        var titleHeight: CGFloat = 0
        let bookImageViewSize: CGSize = self.bookImageViewSize(book)
        titleHeight = (book?.titleText() ?? "").getTextHeight(self.bookTitleLabelFont(), viewWidth: self.bookTitleMaxWidth(bookImageViewSize.width))
        let shortTitleHeight: CGFloat = bookImageViewSize.height + 12 * 2
        let contentsHeight: CGFloat =  titleHeight + shippingImageSize.height + (12 * 2) + priceLabelMergin
        
        return contentsHeight > shortTitleHeight
    }

    fileprivate class func priceLabelWidth(_ merchandise: Merchandise?) ->CGFloat {
        if merchandise == nil || merchandise?.id == nil || merchandise?.price == nil {
            return 0
        }
    
        return self.priceLabelText(merchandise ?? Merchandise()).getTextWidthWithFont(self.priceLabelFont(merchandise ?? Merchandise()), viewHeight: self.priceLabelHeight(merchandise ?? Merchandise()))
    }
    
    fileprivate class func priceLabelText(_ merchandise: Merchandise) ->String {
        var priceLabelText: String = ""
        
        if  merchandise.isSold == true {
            priceLabelText = "売り切れです"
        } else {
            priceLabelText = "¥\(merchandise.price?.int().thousandsSeparator() ?? "0")"
        }
        return priceLabelText
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let merchandise: Merchandise? = cellModelObject as? Merchandise
            
            _ = merchandise.map { (mer) in
                
                let book: Book? = mer.book
                if book?.coverImage?.url != nil {
                    bookImageView?.downloadImageWithURL(book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)
                } else {
                    bookImageView?.image = kPlacejolderBookImage
                }
                bookImageView?.viewSize = type(of: self).bookImageViewSize(book)
                bookImageView?.y = 12.0
                bookTitleLabel?.x = bookImageView!.right + 10.0
                bookTitleLabel?.width = type(of: self).bookTitleMaxWidth(bookImageView!.width)
                
                bookAutherNameLabel?.x = bookTitleLabel!.x
                bookAutherNameLabel?.width = bookTitleLabel!.width
                bookPublisherCompanyNameLabel?.x = bookTitleLabel!.x
                bookPublisherCompanyNameLabel?.width = bookTitleLabel!.width
                
                
                bookTitleLabel?.text = book?.titleText()
                bookTitleLabel?.height =  (book?.titleText() ?? "").getTextHeight(bookTitleLabel!.font, viewWidth: bookTitleLabel!.width)
                bookAutherNameLabel?.y = bookTitleLabel!.bottom + 2.0
                bookPublisherCompanyNameLabel?.y = bookAutherNameLabel!.bottom
                
                bookAutherNameLabel?.text = book?.author?.name
                bookPublisherCompanyNameLabel?.text = book?.publisher?.name
                
                shippingIncludeImageView?.y = bookTitleLabel!.bottom + priceLabelMergin
                shippingIncludeImageView?.x = bookTitleLabel!.x
                
                priceLabel?.font = type(of: self).priceLabelFont(merchandise ?? Merchandise())
                priceLabel?.text = type(of: self).priceLabelText(mer)
                priceLabel?.height = type(of: self).priceLabelHeight(merchandise ?? Merchandise())
                priceLabel?.width = type(of: self).priceLabelText(mer).getTextWidthWithFont(type(of: self).priceLabelFont(merchandise ?? Merchandise()), viewHeight: type(of: self).priceLabelHeight(merchandise ?? Merchandise()))
                priceLabel?.x = shippingIncludeImageView!.right + 5.0
                priceLabel?.y = bookTitleLabel!.bottom + 8.0
                
                statusLabel?.bottom = priceLabel!.bottom - 2.0
                statusLabel?.x = priceLabel!.right + 3.0
                statusLabel?.text = mer.statusString()
                statusLabel?.width = mer.statusString().getTextWidthWithFont(statusLabelFont, viewHeight: statusLabelHeight)
                
                priceLabel?.textColor = UIColor.colorWithHex(0x38454e)
                shippingIncludeImageView?.isHidden = false
                statusLabel?.isHidden = false
                
                if  mer.isSold == true {
                    priceLabel?.x = bookTitleLabel!.x
                    priceLabel?.textColor = UIColor.colorWithHex(0x909090)
                    shippingIncludeImageView?.isHidden = true
                    statusLabel?.isHidden = true
                }
            }
        }
    }
}
