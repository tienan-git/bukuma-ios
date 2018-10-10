//
//  ReviewMensionCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/21.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

private let detailLabelheight: CGFloat = 40.0
private let detailLabelFont: UIFont = UIFont.systemFont(ofSize: 13)

open class ReviewMensionCell: BaseMensionCell {
    
    var detailLabel: UILabel?
    
    override class func mensionImage() ->UIImage? {
        return UIImage(named: "img_int_review")
    }
    
    fileprivate func detailLabelConfig(_ message: Message?) {
        
        detailLabel?.text = type(of: self).detailLabelText(message)
    
        if message?.isMine == true {
            detailLabel?.textColor = UIColor.white
            return
        }
        detailLabel?.textColor = kBlackColor87

    }
    
    fileprivate class func detailLabelWidth() ->CGFloat {
       return MessageCell.maxBallonWidth() + MessageBallonPadding * 2 - 10.0 - 16.0
    }
    
    fileprivate func buttonConfig(_ message: Message?) {
         actionButton?.setTitle("購入者を評価する", for: UIControlState.normal)
        
        if message?.isMine == true {
            actionButton?.isUserInteractionEnabled = false
            actionButton?.setTitleColor(kGray03Color, for: UIControlState.normal)
            return
        }
        actionButton?.isUserInteractionEnabled = true
        actionButton?.setTitleColor(kGray03Color, for: UIControlState.normal)
    }
    
    fileprivate class func detailLabelText(_ message: Message?) ->String {
        if message == nil {
            return ""
        }
        if message?.isMine == true {
            return "相手を評価しました\n相手からの評価をお待ちください"
        }
        return "相手があなたを評価しました\n購入者を評価してください"
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        detailLabel = UILabel()
        detailLabel?.font = detailLabelFont
        detailLabel?.textAlignment = .center
        detailLabel?.numberOfLines = 0
        self.contentView.addSubview(detailLabel ?? UILabel())
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func setMessage(_ message: Message, isSameWeekDay: Bool, isSequenced: Bool) {
        super.setMessage(message, isSameWeekDay: isSameWeekDay, isSequenced: isSequenced)
        
        self.buttonConfig(message)
        self.detailLabelConfig(message)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        if self.message?.isMine == true {
            
            detailLabel?.frame = CGRect(x: chatBallonImageView.x + 10.0,
                                        y: mensionImageView!.bottom + 10.0,
                                        width: type(of: self).detailLabelWidth(),
                                        height: (detailLabel?.text ?? "").getTextHeight(detailLabelFont, viewWidth: type(of: self).detailLabelWidth()))
            actionButton?.isHidden = true
            toImageView?.isHidden = true
            
            dateLabel.viewOrigin = CGPoint(x: chatBallonImageView.x - dateLabel.width - 4.0,
                                       y: chatBallonImageView.bottom - dateLabel.height)
            
        } else {
            
            detailLabel?.frame = CGRect(x: chatBallonImageView.x + 10.0 + 6.0,
                                        y: mensionImageView!.bottom + 5.0,
                                        width: type(of: self).detailLabelWidth(),
                                        height: (detailLabel?.text ?? "").getTextHeight(detailLabelFont, viewWidth: type(of: self).detailLabelWidth()))
            
            borderView?.viewSize = CGSize(width: chatBallonImageView.width - 10.0 * 2 - 6.0 * 3, height: 0.5)
            borderView?.y = detailLabel!.bottom + 8.0

            toImageView?.isHidden = false
            toImageView?.viewOrigin = CGPoint(x: chatBallonImageView.right - 6.0 - toImageView!.width, y: borderView!.bottom - 7.5 )
            
            actionButton?.isHidden = false
            actionButton?.y = borderView!.bottom
            actionButton?.x = chatBallonImageView.x + 6.0
            
            borderView?.x = actionButton!.x + 10.0 + 6.0
            
            dateLabel.viewOrigin = CGPoint(x: chatBallonImageView.right + 4.0,
                                       y: chatBallonImageView.bottom - dateLabel.height)
        }
        
        self.layoutFollowingSendingStatus()
    }
    
    override class func ballonImageheight(_ message: Message?) ->CGFloat {
        if message == nil {
            return 0
        }
        if message?.isMine == true {
            return (self.mensionImage()?.size.height ?? 0) + self.detailLabelText(message).getTextHeight(detailLabelFont, viewWidth: self.detailLabelWidth()) + 10.0 * 3
        }
        return (self.mensionImage()?.size.height ?? 0) + self.detailLabelText(message).getTextHeight(detailLabelFont, viewWidth: self.detailLabelWidth()) + 10.0 * 3 + BaseMensionCellbuttonHeight
    }
    
    override class func mensionCellHeight(_ message: Message?, isSameDay: Bool, isSeqence: Bool) ->CGFloat {
        let weekDayHeight: CGFloat = isSameDay ? 0 : (6.0 * 3) + MessagePartsMargin
        let margin: CGFloat = isSeqence ? MessageSequenceMargin : MessageMargin
        let gap: CGFloat = (isSeqence == true && isSameDay == false) ? MessageMargin - MessageSequenceMargin : 0
        return self.ballonImageheight(message) + margin + weekDayHeight + gap
    }
}
