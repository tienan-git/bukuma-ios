//
//  FinishMensionCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/27.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

class FinishBookMensionView: MensionBookView {
    
    override func defaultSetUp() {
        super.defaultSetUp()
        cancelButton?.removeFromSuperview()
        priceLabel?.removeFromSuperview()
        
    }
    
    override var merchandise: Merchandise? {
        didSet {
            
            _ = merchandise.map { (mer) in

                bookImageView?.viewOrigin = CGPoint(x: 20.0, y: 20.0)
                bookTitleLabel?.x = bookImageView!.right + 10.0
                bookTitleLabel?.viewOrigin = CGPoint(x: bookImageView!.right + 10.0, y: 20.0)
                
            }
        }
    }
    
    override class func bookTitleMaxWidth(_ imageViewWidth: CGFloat) ->CGFloat {
        return kCommonDeviceWidth - imageViewWidth - 20 * 2 - 15.0
    }

    override class func bookImageViewNormalSize() ->CGSize {
        return CGSize(width: 30.0, height: 41.0)
    }

    override class func isBookTitleLonger(_ merchandise: Merchandise?) ->Bool {
        
        var titleHeight: CGFloat = 0
        
        let bookImageViewSize: CGSize = self.bookImageViewSize(merchandise?.book)
        
        merchandise?.book.map({ (b) in
            titleHeight = self.generateAtrributeText(b).getTextHeight(self.bookTitleMaxWidth(bookImageViewSize.width))
        })
        
        let shortTitleHeight: CGFloat = bookImageViewSize.height + 20.0 * 2
        let longTitleHeight: CGFloat = titleHeight + (20.0 * 2)
        return longTitleHeight > shortTitleHeight
    }
    
    override class func viewHeight(_ merchandise: Merchandise?) ->CGFloat {
            
        var titleHeight: CGFloat = 0
        
        let bookImageViewSize: CGSize = self.bookImageViewSize(merchandise?.book)
        
        merchandise?.book.map({ (b) in
            titleHeight = self.generateAtrributeText(b).getTextHeight(self.bookTitleMaxWidth(bookImageViewSize.width))
        })
        
        let shortTitleHeight: CGFloat = bookImageViewSize.height + 20.0 * 2
        let longTitleHeight: CGFloat = titleHeight + 20.0 * 2
        if shortTitleHeight > longTitleHeight {
            return shortTitleHeight
        } else {
            return longTitleHeight
        }
    }
    
    override class func generateAtrributeText(_ book: Book) ->NSAttributedString {
        let mutableAttributedString: NSMutableAttributedString =  NSMutableAttributedString()
        let attributedTitle: NSAttributedString = NSAttributedString.init(string: book.titleText(),
                                                                          attributes: [NSForegroundColorAttributeName:UIColor.colorWithHex(0x38454e), NSFontAttributeName:UIFont.boldSystemFont(ofSize: 11)])
        mutableAttributedString.append(attributedTitle)
        
        let otherText =  NSAttributedString.init(string: self.messageSuffix ?? "",
                                                 attributes: [NSForegroundColorAttributeName:UIColor.colorWithHex(0x38454e), NSFontAttributeName:UIFont.systemFont(ofSize: 11)])
        mutableAttributedString.append(otherText)
        
        return mutableAttributedString
    }

    static var messageSuffix: String?
}

open class FinishMensionCell: MessageCell {
    
    fileprivate var mensionView: FinishBookMensionView?
    fileprivate var topBorderView: UIView?
    fileprivate var underBorderView: UIView?

    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        mensionView = FinishBookMensionView()
        mensionView?.backgroundColor = UIColor.clear
        mensionView?.width = kCommonDeviceWidth
        
        dateLabel.removeFromSuperview()
        self.contentView.addSubview(mensionView!)
        
        topBorderView = UIView()
        topBorderView?.backgroundColor = kBorderColor
        self.contentView.addSubview(topBorderView!)
        
        underBorderView = UIView()
        underBorderView?.backgroundColor = kBorderColor
        self.contentView.addSubview(underBorderView!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private class func setMessageSuffix(for message: Message) {
        var messageSuffix = ""
        if let transactionType = message.itemTrasaction?.type {
            if transactionType == .cancelled {
                messageSuffix = "に関する取引はキャンセルされました"
            }
        }
        if messageSuffix.length == 0 {
            messageSuffix = "に関するすべての取引が終了しました"
        }
        FinishBookMensionView.messageSuffix = messageSuffix
    }
    
    fileprivate class func mensionHeight(_ message: Message) ->CGFloat {
        self.setMessageSuffix(for: message)
        return FinishBookMensionView.viewHeight(message.itemTrasaction?.merchandise ?? Merchandise())
    }
    
    class func mensionCellHeight(_ message: Message?, isSameDay: Bool, isSeqence: Bool) ->CGFloat {
        let weekDayHeight: CGFloat = isSameDay ? 0 : (6.0 * 3) + MessagePartsMargin
        let margin: CGFloat = isSeqence ? MessageSequenceMargin : MessageMargin
        let gap: CGFloat = (isSeqence == true && isSameDay == false) ? MessageMargin - MessageSequenceMargin : 0
        return self.mensionHeight(message ?? Message()) + weekDayHeight + margin + gap
    }
    
    override open func setMessage(_ message: Message, isSameWeekDay: Bool, isSequenced: Bool) {
        super.setMessage(message, isSameWeekDay: isSameWeekDay, isSequenced: isSequenced)

        FinishMensionCell.setMessageSuffix(for: message)
        mensionView?.merchandise = message.itemTrasaction?.merchandise
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageViewButton.isHidden = true
        
        let cellMargin: CGFloat = isSequenced == true ? MessageSequenceMargin : MessageMargin
        
        mensionView?.y = isSameWeekDay == true ? cellMargin : weekDayLabal.bottom + 6.0
        
        topBorderView?.frame = CGRect(x: 10.0,
                                      y: mensionView!.top,
                                      width: self.contentView.width - 10.0 * 2,
                                      height: 0.5)
        underBorderView?.frame = CGRect(x: 10.0,
                                      y: self.contentView.bottom - 0.5,
                                      width: self.contentView.width - 10.0 * 2,
                                      height: 0.5)
        
    }
}
