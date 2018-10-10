//
//  MensionBookView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/13.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

private let priceLabelHeight: CGFloat = 15.0
private let priceLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 9.0)

private let cancelImageViewMargin: CGFloat = 9.0

public let MensionBookViewDisappearNotification = "MensionBookViewDisappearNotification"

open class MensionBookView: UIView {
    
    var bookImageView: UIImageView?
    var bookTitleLabel: UILabel?
    var priceLabel: UILabel?
    var cancelButton: UIButton?
    
    class func bookImageViewNormalSize() ->CGSize {
        return CGSize(width: 40.0, height: 54.0)
    }
    
    class func bookTitleLabelFont() ->UIFont {
        return UIFont.boldSystemFont(ofSize: 15)
    }
    
    class func bookTitleMaxWidth(_ imageViewWidth: CGFloat) ->CGFloat {
        let image: UIImage = UIImage(named: "ic_ui_chat_close")!
        return kCommonDeviceWidth - imageViewWidth - 12.0 - 12.0 - 10.0 - cancelImageViewMargin - image.size.width
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 0))
        //self.defaultSetUp()
    }
    
    convenience public init () {
        self.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 0))
        self.defaultSetUp()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func defaultSetUp() {
        self.backgroundColor = UIColor.colorWithHex(0xf9f9fa)
        
        let cancelImage: UIImage = UIImage(named: "ic_ui_chat_close")!
        cancelButton = UIButton()
        cancelButton?.viewSize = cancelImage.size
        cancelButton?.setImage(cancelImage, for: UIControlState.normal)
        cancelButton?.x = kCommonDeviceWidth - cancelImage.size.width - cancelImageViewMargin
        cancelButton?.addTarget(self, action: #selector(self.cancelButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(cancelButton ?? UIButton())
        
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
        bookTitleLabel?.textColor = kDarkGray03Color
        self.addSubview(bookTitleLabel ?? UILabel())
        
        priceLabel = UILabel()
        priceLabel?.font = priceLabelFont
        priceLabel?.textColor = UIColor.colorWithHex(0x5c6572)
        priceLabel?.height = priceLabelHeight
        priceLabel?.textAlignment = .center
        self.addSubview(priceLabel!)

    }
    
    func cancelButtonTapped(_ sender: UIButton) {
        self.disappear(nil)
    }
    
    var merchandise: Merchandise? {
        didSet {
            
            _ = merchandise.map { (mer) in
                
                self.height = type(of: self).viewHeight(merchandise)
                
                cancelButton?.y = (self.height - cancelButton!.height) / 2
                
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
                
                _ =  book.map { (b) in
                    if Utility.isEmpty(merchandise?.id) || merchandise?.id == "-1" {
                        bookTitleLabel?.attributedText = NSAttributedString(string: "この本は削除された商品です")
                    } else {
                        bookTitleLabel?.attributedText = type(of: self).generateAtrributeText(b)
                        bookTitleLabel?.height = type(of: self).generateAtrributeText(b).getTextHeight(bookTitleLabel!.width)
                    }
                }
                
                if Utility.isEmpty(merchandise?.id) || merchandise?.id == "-1" {
                    priceLabel?.text = ""
                } else {
                     priceLabel?.text = type(of: self).priceLabelText(mer)
                }
               
                priceLabel?.width = type(of: self).priceLabelText(mer).getTextWidthWithFont(priceLabelFont, viewHeight: priceLabelHeight)
                priceLabel?.x = bookTitleLabel!.x
                priceLabel?.y = bookTitleLabel!.bottom + 2.0
                
                if  mer.isSold == true {
                    priceLabel?.textColor = UIColor.gray.withAlphaComponent(0.70)
                }
                
            }
        }
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
    
    fileprivate class func priceLabelWidth(_ merchandise: Merchandise?) ->CGFloat {
        if merchandise == nil || merchandise?.id == nil || merchandise?.price == nil {
            return 0
        }
        
        return self.priceLabelText(merchandise ?? Merchandise()).getTextWidthWithFont(priceLabelFont, viewHeight: priceLabelHeight)
    }
    
    class func isBookTitleLonger(_ merchandise: Merchandise?) ->Bool {
        
        var titleHeight: CGFloat = 0
        
        let bookImageViewSize: CGSize = self.bookImageViewSize(merchandise?.book)
        
        merchandise?.book.map({ (b) in
            titleHeight = self.generateAtrributeText(b).getTextHeight(self.bookTitleMaxWidth(bookImageViewSize.width))
        })

        let shortTitleHeight: CGFloat = bookImageViewSize.height + 12 * 2
        let longTitleHeight: CGFloat = titleHeight + (12 * 2) + 15.0 + 2.0
        return longTitleHeight > shortTitleHeight
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

    class func viewHeight(_ merchandise: Merchandise?) ->CGFloat {
        
        var titleHeight: CGFloat = 0
        
        let bookImageViewSize: CGSize = self.bookImageViewSize(merchandise?.book)
        
        merchandise?.book.map({ (b) in
            titleHeight = self.generateAtrributeText(b).getTextHeight(self.bookTitleMaxWidth(bookImageViewSize.width))
        })
        
        let shortTitleHeight: CGFloat = bookImageViewSize.height + 12 * 2
        let longTitleHeight: CGFloat = titleHeight + (12 * 2) + 15.0 + 2.0
        if shortTitleHeight > longTitleHeight {
            return shortTitleHeight
        } else {
            return longTitleHeight
        }
    }
    
    class func generateAtrributeText(_ book: Book) ->NSAttributedString {
        let mutableAttributedString: NSMutableAttributedString =  NSMutableAttributedString()
        let attributedTitle: NSAttributedString = NSAttributedString.init(string: book.titleText(),
                                                                             attributes: [NSForegroundColorAttributeName:UIColor.colorWithHex(0x38454e), NSFontAttributeName:UIFont.boldSystemFont(ofSize: 11)])
        mutableAttributedString.append(attributedTitle)
        
        let otherText =  NSAttributedString.init(string: "について",
                                                               attributes: [NSForegroundColorAttributeName:UIColor.colorWithHex(0x38454e), NSFontAttributeName:UIFont.systemFont(ofSize: 11)])
        mutableAttributedString.append(otherText)
        
        return mutableAttributedString
    }

    func disappear(_ completion: (() ->Void)?) {
        if self.superview == nil {
            return
        }
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MensionBookViewDisappearNotification), object: nil)
        UIView.animate(withDuration:0.35, animations: {
            self.top = kCommonDeviceHeight
            
        }) { (isFinished) in
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0.0
                }, completion: { (isFinished) in
                    if completion != nil {
                        completion!()
                    }
                    self.merchandise = nil
            })
        }
    }
}
