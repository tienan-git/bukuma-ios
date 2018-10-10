//
//  BookIconCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


/**
 
 本のアイコンを保持Cell
 
 */

open class BookIconCell: BaseTableViewCell {
    
    var bookImageView: UIImageView?
    var bookTitleLabel: UILabel?
    var bookAutherNameLabel: UILabel?
    var bookPublisherCompanyNameLabel: UILabel?
    
    class func bookImageViewNormalSize() ->CGSize {
        return CGSize(width: 75.0, height: 96.0)
    }
    
    class func bookTitleLabelFont() ->UIFont {
        return UIFont.boldSystemFont(ofSize: 15)
    }
    
    class func bookTitleMaxWidth(_ imageViewWidth: CGFloat) ->CGFloat {
        return kCommonDeviceWidth - imageViewWidth - 12.0 - 12.0 - 10.0
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        
        bookImageView = UIImageView()
        bookImageView?.viewSize = type(of: self).bookImageViewNormalSize()
        bookImageView?.viewOrigin = CGPoint(x: 12, y: 12)
        bookImageView?.contentMode = UIViewContentMode.scaleAspectFill
        bookImageView?.clipsToBounds = true
        bookImageView?.layer.cornerRadius = 3.0
        self.addSubview(bookImageView ?? UIImageView())
        
        bookTitleLabel = UILabel()
        bookTitleLabel?.frame = CGRect(x: bookImageView!.right + 10.0, y: 12.0, width: 0, height: 0)
        bookTitleLabel?.width = kCommonDeviceWidth - bookTitleLabel!.right
        bookTitleLabel?.textAlignment = .left
        bookTitleLabel?.numberOfLines = 0
        bookTitleLabel?.font = type(of: self).bookTitleLabelFont()
        bookTitleLabel?.textColor = kDarkGray03Color
        self.addSubview(bookTitleLabel ?? UILabel())
        
        bookAutherNameLabel = UILabel()
        bookAutherNameLabel?.frame = CGRect(x: bookTitleLabel!.x, y: bookTitleLabel!.bottom, width: bookTitleLabel!.width, height: 15)
        bookAutherNameLabel?.textAlignment = .left
        bookAutherNameLabel?.font = UIFont.systemFont(ofSize: 12)
        bookAutherNameLabel?.textColor = kBlackColor54
        self.addSubview(bookAutherNameLabel ?? UILabel())
        
        bookPublisherCompanyNameLabel = UILabel()
        bookPublisherCompanyNameLabel?.frame = CGRect(x: bookAutherNameLabel!.x, y: bookAutherNameLabel!.bottom, width: bookAutherNameLabel!.width, height: 15)
        bookPublisherCompanyNameLabel?.textAlignment = .left
        bookPublisherCompanyNameLabel?.font = UIFont.systemFont(ofSize: 12)
        bookPublisherCompanyNameLabel?.textColor = kBlackColor54
        self.addSubview(bookPublisherCompanyNameLabel ?? UILabel())
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func bookImageViewSize(_ book: Book?) ->CGSize {
        if book == nil || book?.imageWidth == nil || book?.imageHeight == nil {
            return self.bookImageViewNormalSize()
        }
        
        var size: CGSize = CGSize.zero
        let bookImageView: UIImageView = UIImageView()
        bookImageView.resize(CGSize(width: CGFloat(book!.imageWidth!),
            height: CGFloat(book!.imageHeight!)),
                             fixedHeight: self.bookImageViewNormalSize().height,
                             fixedWidth: self.bookImageViewNormalSize().width,
                             center: 0)
        size = bookImageView.viewSize
        return size
    }

    class func cellHeight(_ book: Book?) ->CGFloat {
        var titleHeight: CGFloat = 0
        
        let bookImageViewSize: CGSize = self.bookImageViewSize(book)
        
       // book?.title.map({ (title) in
            titleHeight =  book?.titleText().getTextHeight(self.bookTitleLabelFont(), viewWidth: self.bookTitleMaxWidth(bookImageViewSize.width)) ?? 0
        //})
        
        let shortTitleHeight: CGFloat = bookImageViewSize.height + 12 * 2
        let longTitleHeight: CGFloat = titleHeight + (15 * 2) + (12 * 2)
        if shortTitleHeight > longTitleHeight {
            return shortTitleHeight
        } else {
            return longTitleHeight
        }
    }
    
    class func isBookTitleLonger(_ book: Book?) ->Bool {
        var titleHeight: CGFloat = 0
        let bookImageViewSize: CGSize = self.bookImageViewSize(book)
        titleHeight =  book?.titleText().getTextHeight(self.bookTitleLabelFont(), viewWidth:self.bookTitleMaxWidth(bookImageViewSize.width)) ?? 0
        let shortTitleHeight: CGFloat = bookImageViewSize.height + 12 * 2
        let longTitleHeight: CGFloat = titleHeight + (15 * 2) + (12 * 2)
        return longTitleHeight > shortTitleHeight
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let book: Book? = object as? Book
        return self.cellHeight(book)
    }

    override open var cellModelObject: AnyObject? {
        didSet {
            let book: Book? = cellModelObject as? Book
            if book?.coverImage?.url != nil {
                bookImageView?.downloadImageWithURL(book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)

            } else {
                bookImageView?.image = kPlacejolderBookImage
            }
            bookImageView?.viewSize = type(of: self).bookImageViewSize(book)
            if type(of: self).isBookTitleLonger(book) {
                bookImageView?.y = (type(of: self).cellHeight(book) - bookImageView!.height) / 2
            }
            
            bookTitleLabel?.x = bookImageView!.right + 10.0
            
            bookTitleLabel?.width = type(of: self).bookTitleMaxWidth(bookImageView?.width ?? 0)
            
            bookAutherNameLabel?.x = bookTitleLabel!.x
            bookAutherNameLabel?.width = bookTitleLabel!.width
            bookPublisherCompanyNameLabel?.x = bookTitleLabel!.x
            bookPublisherCompanyNameLabel?.width = bookTitleLabel!.width
            
            bookTitleLabel?.text = book?.titleText()
            bookTitleLabel?.height = (book?.titleText() ?? "").getTextHeight(bookTitleLabel!.font, viewWidth: bookTitleLabel!.width)
            bookAutherNameLabel?.y = bookTitleLabel!.bottom
            bookPublisherCompanyNameLabel?.y = bookAutherNameLabel!.bottom
            
            bookAutherNameLabel?.text = book?.author?.name
            bookPublisherCompanyNameLabel?.text = book?.publisher?.name
        }
    }


}
