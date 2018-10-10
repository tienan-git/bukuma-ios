//
//  ChatBookMensionCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/14.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class MessageBookMensionView: MensionBookView {
    
    override open func defaultSetUp() {
        super.defaultSetUp()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 2.0
        
        cancelButton?.removeFromSuperview()
        
    }
    
    override class func bookTitleMaxWidth(_ imageViewWidth: CGFloat) ->CGFloat {
        return MessageCell.maxBallonWidth() - imageViewWidth - 12.0 - 12.0 - 10.0
    }
    
}

open class ChatBookMensionCell: TextMessageCell {
    
    var bookmensionView: MessageBookMensionView?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        bookmensionView = MessageBookMensionView()
        bookmensionView?.width = MessageCell.maxBallonWidth()
        self.contentView.addSubview(bookmensionView!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func setMessage(_ message: Message, isSameWeekDay: Bool, isSequenced: Bool) {
        super.setMessage(message, isSameWeekDay: isSameWeekDay, isSequenced: isSequenced)
        
        bookmensionView?.merchandise = message.merchandise
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        messageTextLabel.width = MessageCell.maxBallonWidth()
        
        if self.message?.isMine == true {
            chatBallonImageView.x = kCommonDeviceWidth - messageTextLabel.width - MessageMargin - 10.0 - 12.0
            chatBallonImageView.width = messageTextLabel.width + MessageBallonPadding * 2
            chatBallonImageView.height = messageTextLabel.height + bookmensionView!.height + 10.0
            
            messageTextLabel.x = chatBallonImageView.x + MessageBallonPadding - 4.0
            messageTextLabel.y = chatBallonImageView.y
            
            dateLabel.viewOrigin = CGPoint(x: chatBallonImageView.x - dateLabel.width - 4.0,
                                       y: chatBallonImageView.bottom - dateLabel.height)
            
        } else {
            chatBallonImageView.x = iconImageViewButton.right + 6.0
            chatBallonImageView.height = messageTextLabel.height + bookmensionView!.height + 10.0
            chatBallonImageView.width = messageTextLabel.width + MessageBallonPadding * 2
            
            messageTextLabel.x = chatBallonImageView.x + MessageBallonPadding + 4.0
            messageTextLabel.y = chatBallonImageView.y
            
            dateLabel.viewOrigin = CGPoint(x: chatBallonImageView.right + 4.0,
                                       y: chatBallonImageView.bottom - dateLabel.height)
        }
        
        bookmensionView?.x = messageTextLabel.x
        bookmensionView?.y = messageTextLabel.bottom
        
        self.layoutFollowingSendingStatus()
    }
    
    fileprivate class func mensionHeight(_ message: Message) ->CGFloat {
        let mergin: CGFloat = Utility.isEmpty(message.merchandise?.id) ? 0 : 10.0
        return MessageBookMensionView.viewHeight(message.merchandise ?? Merchandise()) + mergin
    }
    
    class func mensionCellHeight(_ message: Message?, isSameDay: Bool, isSeqence: Bool) ->CGFloat {
        return  self.textCellHeight(message?.text ?? "", isSameWeekDay: isSameDay, isSequenced: isSeqence, lineHeight: 36.0) + self.mensionHeight(message ?? Message())
    }
    
    override func longTapGesture(sender: UILongPressGestureRecognizer) {
        
    }
}
