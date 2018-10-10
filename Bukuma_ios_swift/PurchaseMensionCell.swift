//
//  PurchaseMensionCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/21.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class PurchaseMensionCell: BaseMensionCell {
    
    var bookmensionView: MessageBookMensionView?
    
    override class func mensionImage() ->UIImage? {
        return UIImage(named: "img_cover_after_shipping")
    }
    
    override class func actionTitle() ->String? {
        return "購入しました"
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        mensionImageView?.removeFromSuperview()
        
        bookmensionView = MessageBookMensionView()
        bookmensionView?.width = MessageCell.maxBallonWidth()
        self.contentView.addSubview(bookmensionView!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate class func mensionHeight(_ message: Message) ->CGFloat {
        return MessageBookMensionView.viewHeight(message.itemTrasaction?.merchandise ?? Merchandise())
    }
    
    override class func mensionCellHeight(_ message: Message?, isSameDay: Bool, isSeqence: Bool) ->CGFloat {
        let weekDayHeight: CGFloat = isSameDay ? 0 : (6.0 * 3) + MessagePartsMargin
        let margin: CGFloat = isSeqence ? MessageSequenceMargin : MessageMargin
        let gap: CGFloat = (isSeqence == true && isSameDay == false) ? MessageMargin - MessageSequenceMargin : 0
        return self.ballonImageheight(message ?? Message()) + weekDayHeight + margin + gap
    }
    
    override class func ballonImageheight(_ message: Message?) ->CGFloat {
        if message == nil {
            return 0
        }
        
        return self.mensionHeight(message ?? Message()) + BaseMensionCellbuttonHeight + 10.0 + 3.0
    
    }
    
    override open func setMessage(_ message: Message, isSameWeekDay: Bool, isSequenced: Bool) {
        super.setMessage(message, isSameWeekDay: isSameWeekDay, isSequenced: isSequenced)
        
        bookmensionView?.merchandise = message.itemTrasaction?.merchandise

    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        weekDayLabal.y = 10.0
        
        let cellMargin: CGFloat = isSequenced == true ? MessageSequenceMargin : MessageMargin
        
        if self.message?.isMine == true {
            iconImageViewButton.isHidden = true
            iconImageViewButton.isUserInteractionEnabled = false
            
            chatBallonImageView.image = myBallonImage
            chatBallonImageView.frame = CGRect(x: kCommonDeviceWidth - MessageCell.maxBallonWidth() - MessageMargin - 10.0 - 12.0,
                                               y: isSameWeekDay == true ? cellMargin : weekDayLabal.bottom + 6.0,
                                               width: MessageCell.maxBallonWidth() + MessageBallonPadding * 2,
                                               height: type(of: self).ballonImageheight(message))
            
            bookmensionView?.viewOrigin = CGPoint(x: chatBallonImageView!.x + 10.0, y: chatBallonImageView!.y + 10.0)
            
            actionButton?.viewSize = CGSize(width: chatBallonImageView.width - 6.0, height: BaseMensionCellbuttonHeight)
            actionButton?.setTitleColor(UIColor.white, for: UIControlState.normal)
            toImageView?.image = UIImage(named: "ic_s_arrow_whtie")
            toImageView?.viewOrigin = CGPoint(x: chatBallonImageView.right - 6.0 - 10.0 - toImageView!.width, y: bookmensionView!.bottom)
            toImageView?.height = UIImage(named: "ic_s_arrow_whtie")?.size.height ?? 0
            actionButton?.y = bookmensionView!.bottom
            actionButton?.x = chatBallonImageView.x
            
            dateLabel.viewOrigin = CGPoint(x: chatBallonImageView.x - dateLabel.width - 4.0,
                                       y: chatBallonImageView.bottom - dateLabel.height)
        } else {
            
            iconImageViewButton.viewOrigin = CGPoint(x: 12.0, y: isSameWeekDay == true ? cellMargin : weekDayLabal.bottom + 6.0)
            
            chatBallonImageView.image = otherBallonImage
            chatBallonImageView.frame = CGRect(x: iconImageViewButton.right + 6.0,
                                               y: iconImageViewButton.y,
                                               width: MessageCell.maxBallonWidth() + MessageBallonPadding * 2,
                                               height: type(of: self).ballonImageheight(message))
            bookmensionView?.viewOrigin = CGPoint(x: chatBallonImageView!.x + 16.0, y: chatBallonImageView!.y + 10.0)
            actionButton?.viewSize = CGSize(width: chatBallonImageView.width - 6.0, height: BaseMensionCellbuttonHeight)
            actionButton?.setTitleColor(kGray03Color, for: UIControlState.normal)
            
            borderView?.viewSize = CGSize(width: bookmensionView!.width, height: 0.5)
            borderView?.x = bookmensionView!.x
            borderView?.y = bookmensionView!.bottom
            
            toImageView?.image = UIImage(named: "ic_to")
            toImageView?.viewOrigin = CGPoint(x: chatBallonImageView.right - 6.0 - toImageView!.width, y: borderView!.bottom - 7.5)
            toImageView?.height = UIImage(named: "ic_to")?.size.height ?? 0
            
            actionButton?.y = borderView!.bottom
            
            actionButton?.x = chatBallonImageView.x + 6.0
            dateLabel.viewOrigin = CGPoint(x: chatBallonImageView.right + 4.0,
                                       y: chatBallonImageView.bottom - dateLabel.height)
        }
        
        self.layoutFollowingSendingStatus()
    }
    
}
