//
//  ExhibitBookInfoDetailCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/13.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class ExhibitBookInfoDetailCell: BaseTableViewCell {
    
    fileprivate var bookImageView: UIImageView? = UIImageView()
    fileprivate var bookTitleLabel: UILabel? = UILabel()
    fileprivate var bookAutherNameLabel: UILabel? = UILabel()
    fileprivate var bookPublisherCompanyNameLabel: UILabel? = UILabel()
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate, book: Book?) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.selectionStyle = .none
        
        let topBorderView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 0.5))
        topBorderView.backgroundColor = kBackGroundColor
        self.addSubview(topBorderView)
        
        bookImageView?.frame = CGRect(x: 15.0, y: topBorderView.bottom + 15.0, width: 61, height: 87.0)
        bookImageView?.contentMode = .scaleAspectFill
        bookImageView?.resize( CGSize(width: book?.imageWidth ?? 61.0, height: book?.imageHeight ?? 87.0),
                               fixedHeight: 87.0,
                               fixedWidth: 87.0,
                               center: 0)
        bookImageView?.x = 15.0
        if book?.coverImage?.url != nil {
            bookImageView?.downloadImageWithURL(book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)
        } else {
            bookImageView?.image = kPlacejolderBookImage
        }
        bookImageView?.clipsToBounds = true
        bookImageView?.layer.cornerRadius = 3.0
        self.addSubview(bookImageView!)
        
        bookTitleLabel?.frame = CGRect(x: bookImageView!.right + 12.0, y: bookImageView!.y, width: 0, height: 0)
        bookTitleLabel?.width = kCommonDeviceWidth - bookTitleLabel!.right - 10.0
        bookTitleLabel?.textAlignment = .left
        bookTitleLabel?.text = book?.titleText()
        bookTitleLabel?.numberOfLines = 0
        bookTitleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        bookTitleLabel?.height = bookTitleLabel!.text!.getTextHeight(bookTitleLabel!.font, viewWidth: bookTitleLabel!.width)
        bookTitleLabel?.textColor = kBlackColor87
        self.addSubview(bookTitleLabel!)
        
        bookAutherNameLabel?.frame = CGRect(x: bookTitleLabel!.x, y: bookTitleLabel!.bottom + 2.5, width: bookTitleLabel!.width, height: 15)
        book?.publisher?.name.map{
            let text = "出版社: \($0)"
            let at: NSMutableAttributedString = NSMutableAttributedString(string: text)
            at.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 12), range: NSMakeRange(0, (text as NSString).length))
            let termsRange = NSMakeRange(0, "出版社".characters.count)
            let textRange = NSMakeRange(0, text.characters.count)
            at.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 12), range: termsRange)
            at.addAttribute(NSForegroundColorAttributeName, value: kDarkGray03Color, range: textRange)
            bookAutherNameLabel?.attributedText = at
        }
        
        bookAutherNameLabel?.textAlignment = .left
        bookAutherNameLabel?.textColor = kDarkGray03Color
        self.addSubview(bookAutherNameLabel!)
        
        bookPublisherCompanyNameLabel?.frame = CGRect(x: bookAutherNameLabel!.x, y: bookAutherNameLabel!.bottom, width: bookAutherNameLabel!.width, height: 15)
        book?.author?.name.map{
            let text = "著者: \($0)"
            let at: NSMutableAttributedString = NSMutableAttributedString(string: text)
            at.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 12), range: NSMakeRange(0, (text as NSString).length))
            let termsRange = NSMakeRange(0, "著者".characters.count)
            let textRange = NSMakeRange(0, text.characters.count)
            at.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 12), range: termsRange)
            at.addAttribute(NSForegroundColorAttributeName, value: kDarkGray03Color, range: textRange)
            bookPublisherCompanyNameLabel?.attributedText = at
        }
        bookPublisherCompanyNameLabel?.textAlignment = .left
        bookPublisherCompanyNameLabel?.textColor = kDarkGray03Color
        self.addSubview(bookPublisherCompanyNameLabel!)
        
        let newPriceLabel: UILabel = UILabel()
        newPriceLabel.frame = CGRect(x: bookPublisherCompanyNameLabel!.x,
                                     y: bookPublisherCompanyNameLabel!.bottom,
                                     width: bookPublisherCompanyNameLabel!.width,
                                     height: bookPublisherCompanyNameLabel!.height)
        if !Utility.isEmpty(book?.listPrice) {
            let text = "新品定価: \(book!.listPrice!)円"
            let at: NSMutableAttributedString = NSMutableAttributedString(string: text)
            at.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 12), range: NSMakeRange(0, (text as NSString).length))
            let termsRange = NSMakeRange(0, "新品定価".characters.count)
            let textRange = NSMakeRange(0, text.characters.count)
            at.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 12), range: termsRange)
            at.addAttribute(NSForegroundColorAttributeName, value: kDarkGray03Color, range: textRange)
            newPriceLabel.attributedText = at
        } else {
            let text = "新品定価: なし"
            let at: NSMutableAttributedString = NSMutableAttributedString(string: text)
            at.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 12), range: NSMakeRange(0, (text as NSString).length))
            let termsRange = NSMakeRange(0, "新品定価".characters.count)
            let textRange = NSMakeRange(0, text.characters.count)
            at.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 12), range: termsRange)
            at.addAttribute(NSForegroundColorAttributeName, value: kDarkGray03Color, range: textRange)
            newPriceLabel.attributedText = at
        }
        
        newPriceLabel.textAlignment = .left
        newPriceLabel.textColor = kDarkGray03Color
        self.addSubview(newPriceLabel)
        
        let shortTitleHeight: CGFloat = bookImageView!.bottom + 15.0
        let longTitleHeight: CGFloat = newPriceLabel.bottom + 15.0
        if shortTitleHeight > longTitleHeight {
            self.height = shortTitleHeight
        } else {
            self.height = longTitleHeight
        }
    }
    
    open override class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let book: Book? = object as? Book
        
        let bookImageView: UIImageView = UIImageView()
        bookImageView.resize( CGSize(width: book?.imageWidth ?? 61.0, height: book?.imageHeight ?? 87.0),
                               fixedHeight: 87.0,
                               fixedWidth: 87.0,
                               center: 0)
        
        let bookTitleLabel: UILabel = UILabel()
        bookTitleLabel.frame = CGRect(x: 15.0 + bookImageView.width + 12.0, y: 15.0, width: 0, height: 0)
        bookTitleLabel.width = kCommonDeviceWidth - bookTitleLabel.right - 10.0
        bookTitleLabel.text = book?.titleText()
        bookTitleLabel.numberOfLines = 0
        bookTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        bookTitleLabel.height = bookTitleLabel.text!.getTextHeight(bookTitleLabel.font, viewWidth: bookTitleLabel.width)
        
        let bookAutherNameLabelHeight: CGFloat = 15.0
        let bookPublisherCompanyNameLabelHeight: CGFloat = 15.0
        let newPriceLabelHeight: CGFloat = 15.0
        
        let minHeight: CGFloat = bookImageView.height + 15 * 2
        let maxHeight: CGFloat = 15.0 + bookTitleLabel.height + bookAutherNameLabelHeight + bookPublisherCompanyNameLabelHeight + newPriceLabelHeight + 15.0
        
        return minHeight > maxHeight ? minHeight : maxHeight
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        fatalError("init(reuseIdentifier:delegate:) has not been implemented")
    }
    
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }

}
