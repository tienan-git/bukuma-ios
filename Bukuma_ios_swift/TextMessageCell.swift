//
//  TextMessageCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/13.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public protocol TextMessageCellDelegate: BaseTableViewDelegate {
    func textMessageCell(cell: TextMessageCell)
}

open class TextMessageCell: MessageCell {
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        chatBallonImageView.backgroundColor = UIColor.clear
        chatBallonImageView.clipsToBounds = false
        self.contentView.addSubview(chatBallonImageView)
        
        messageTextLabel.font = MessageTextLabelFont
        messageTextLabel.numberOfLines = 0
        self.contentView.addSubview(messageTextLabel)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTapGesture(sender:)))
        self.contentView.addGestureRecognizer(gesture)

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func setMessage(_ message: Message, isSameWeekDay: Bool, isSequenced: Bool) {
        super.setMessage(message, isSameWeekDay: isSameWeekDay, isSequenced: isSequenced)
        messageTextLabel.text = message.text
       
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        weekDayLabal.y = 10.0
        
        var width: CGFloat = 0
        _ = messageTextLabel.text.map{ width = $0.getTextWidthWithFont(MessageTextLabelFont, viewHeight: CGFloat.greatestFiniteMagnitude)}
        messageTextLabel.width = width > MessageCell.maxBallonWidth() ? MessageCell.maxBallonWidth() : width
        messageTextLabel.height = messageTextLabel.text!.getTextHeight(MessageTextLabelFont, viewWidth: messageTextLabel.width) + 14.0
        
        let cellMargin: CGFloat = isSequenced == true ? MessageSequenceMargin : MessageMargin
        
        if self.message?.isMine == true {
            iconImageViewButton.isHidden = true
            iconImageViewButton.isUserInteractionEnabled = false
            
            chatBallonImageView.image = myBallonImage
            chatBallonImageView.frame = CGRect(x: kCommonDeviceWidth - messageTextLabel.width - MessageMargin - 10.0 - 12.0,
                                               y: isSameWeekDay == true ? cellMargin : weekDayLabal.bottom + 6.0,
                                               width: messageTextLabel.width + MessageBallonPadding * 2,
                                               height: max(MininumTextHeight, messageTextLabel.height))
            
            messageTextLabel.viewOrigin = CGPoint(x: chatBallonImageView.x + MessageBallonPadding - 4.0,
                                              y: 0)
            messageTextLabel.center.y = chatBallonImageView.center.y
            messageTextLabel.textColor = UIColor.white
            
            dateLabel.viewOrigin = CGPoint(x: chatBallonImageView.x - dateLabel.width - 4.0,
                                       y: chatBallonImageView.bottom - dateLabel.height)
        } else {
//            iconImageViewButton.isHidden = false
//            iconImageViewButton.isUserInteractionEnabled = true
            
            iconImageViewButton.viewOrigin = CGPoint(x: 12.0, y: isSameWeekDay == true ? cellMargin : weekDayLabal.bottom + 6.0)
            
            chatBallonImageView.image = otherBallonImage
            chatBallonImageView.frame = CGRect(x: iconImageViewButton.right + 6.0,
                                               y: iconImageViewButton.y,
                                               width: messageTextLabel.width + MessageBallonPadding * 2,
                                               height: max(MininumTextHeight, messageTextLabel.height))
            
            messageTextLabel.viewOrigin = CGPoint(x: chatBallonImageView.x + MessageBallonPadding + 4.0,
                                              y: 0)
            messageTextLabel.center.y = chatBallonImageView.center.y
            messageTextLabel.textColor = UIColor.black
            
            dateLabel.viewOrigin = CGPoint(x: chatBallonImageView.right + 4.0,
                                       y: chatBallonImageView.bottom - dateLabel.height)
        }
        
        self.layoutFollowingSendingStatus()
    }

    func longTapGesture(sender: UILongPressGestureRecognizer) {
        (delegate as? TextMessageCellDelegate)?.textMessageCell(cell: self)
    }

}
