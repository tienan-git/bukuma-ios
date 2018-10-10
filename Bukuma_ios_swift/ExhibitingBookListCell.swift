//
//  ExhibitingBookListCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/27.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

private let priceLabelFont: UIFont = UIFont.systemFont(ofSize: 13)
private let statusLabelFont: UIFont = UIFont.systemFont(ofSize: 13)

class ExhibitingBookListCell: TransactionListCell {
    
    fileprivate var pricelabel: UILabel?
    fileprivate var statusLabel: UILabel?
    
    private var merchandise: Merchandise?
    
    required init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        self.delegate = delegate
        
        dateLabel.removeFromSuperview()
        
        pricelabel = UILabel()
        pricelabel?.frame = CGRect(x: textlabel.x,
                                 y: textlabel.bottom + 10.0,
                                 width: 150,
                                 height: dateLabelHeight)
        pricelabel?.textColor = kGrayColor
        pricelabel?.font = priceLabelFont
        self.contentView.addSubview(pricelabel!)
        
        statusLabel = UILabel()
        statusLabel?.frame = CGRect(x: pricelabel!.right,
                                   y: pricelabel!.y,
                                   width: 150,
                                   height: dateLabelHeight)
        statusLabel?.textColor = kGrayColor
        statusLabel?.font = statusLabelFont
        self.contentView.addSubview(statusLabel!)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var cellModelObject: AnyObject? {
        didSet {
            merchandise = cellModelObject as? Merchandise
            
            if merchandise?.isSold == true {
                self.backgroundColor = kBackGroundColor
                self.contentView.backgroundColor = kBackGroundColor
            } else {
                self.backgroundColor = UIColor.white
                self.contentView.backgroundColor = UIColor.white
            }
            
            if merchandise?.user?.photo?.imageURL != nil {
                iconImageViewButton.downloadImageWithURL(merchandise?.user?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)
            } else {
                iconImageViewButton.setImage(kPlaceholderUserImage, for: UIControlState.normal)
            }
            
            if let mer = merchandise {
                textlabel.attributedText = type(of: self).generateAtrributeText(mer)
                textlabel.height = textlabel.attributedText!.getTextHeight(transactionTextWidth)
            }
            
            pricelabel?.text = self.priceLabelText(merchandise)
            pricelabel?.y = textlabel.bottom + 9.0
            pricelabel?.width = self.priceLabelText(merchandise).getTextWidthWithFont(priceLabelFont, viewHeight: dateLabelHeight)
            
            let statusText: String = merchandise?.statusString() ?? ""
            statusLabel?.text = statusText
            statusLabel?.y = textlabel.bottom + 9.0
            statusLabel?.x = pricelabel!.right + 3.0
            statusLabel?.width = statusText.getTextWidthWithFont(statusLabelFont, viewHeight: dateLabelHeight)
            
            statusLabel?.isHidden = false
            if merchandise?.isSold == true {
                statusLabel?.isHidden = true
            }
            
            bookImageView.downloadImageWithURL(merchandise?.book?.coverImage?.url as URL?, placeholderImage: kPlacejolderBookImage)
        }
    }
    
    override class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let merchandise = object as? Merchandise
        var string: NSAttributedString?
        var labelaHeight: CGFloat? = 0
        if let mer = merchandise {
            string = self.generateAtrributeText(mer)
            labelaHeight = string!.getTextHeight(transactionTextWidth)
        }
        let minheight: CGFloat = bookImageViewheight + UserIconCellBaseHorizontalMargin * 2
        let maxHeight: CGFloat = labelaHeight! + dateLabelHeight + UserIconCellBaseHorizontalMargin * 2 + 8.0
        return minheight > maxHeight ? minheight : maxHeight
    }
    
    fileprivate func priceLabelText(_ merchandise: Merchandise?) ->String {
        var priceText: String = "¥\(merchandise?.price?.int().thousandsSeparator() ?? "")"
        if merchandise?.isSold == true {
            priceText = "売り切れました"
        }
        return priceText
    }
    
    fileprivate class func generateAtrributeText(_ merchandise: Merchandise) ->NSAttributedString {
        let mutableAttributedString: NSMutableAttributedString =  NSMutableAttributedString()
    
        let attributedNickName: NSAttributedString = NSAttributedString.init(string: merchandise.book?.titleText() ?? "",
                                                                             attributes: [NSForegroundColorAttributeName:kBlackColor87, NSFontAttributeName:UIFont.boldSystemFont(ofSize: 15)])
        mutableAttributedString.append(attributedNickName)
        
        let otherNameAttributedText =  NSAttributedString.init(string: "を出品中です",
                                                               attributes: [NSForegroundColorAttributeName:kBlackColor87, NSFontAttributeName:UIFont.systemFont(ofSize: 15)])
        mutableAttributedString.append(otherNameAttributedText)
        return mutableAttributedString
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        if isSelected == true {
            if merchandise?.isSold == true {
                self.backgroundColor = kBackGroundColor
                self.contentView.backgroundColor = kBackGroundColor
                return
            }
            self.backgroundColor = kCellisSelectedBackgroundColor
            self.contentView.backgroundColor = kCellisSelectedBackgroundColor
            return
        }
        if merchandise?.isSold == true {
            self.backgroundColor = kBackGroundColor
            self.contentView.backgroundColor = kBackGroundColor
            return
        }
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted == true {
            if merchandise?.isSold == true {
                self.backgroundColor = kBackGroundColor
                self.contentView.backgroundColor = kBackGroundColor
                return
            }
            self.backgroundColor = kCellisSelectedBackgroundColor
            self.contentView.backgroundColor = kCellisSelectedBackgroundColor
            return
        }
        
        if merchandise?.isSold == true {
            self.backgroundColor = kBackGroundColor
            self.contentView.backgroundColor = kBackGroundColor
            return
        }
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
}
