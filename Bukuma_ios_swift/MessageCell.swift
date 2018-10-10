//
//  MessageCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/01.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit

public let MessageMargin: CGFloat = 12.0
public let MessageSequenceMargin: CGFloat = 4.0
public let MessageBallonPadding: CGFloat = 14.0
let MininumTextHeight: CGFloat = 36.0
let MessagePartsMargin: CGFloat = 10.0
let MessageTextLabelFont: UIFont = UIFont.systemFont(ofSize: 15)

public enum MessageCellSendingStatus: Int {
    case sending = 1
    case complete
    case failed
}

open class MessageCell: UserIconCell {
    
    deinit {
        // objectが適切に解放されたら、呼ばれる
    }
    
    var messageTextLabel: UILabel! = UILabel()
    let dateLabel: UILabel! = UILabel()
    let weekDayLabal: UILabel! = UILabel()
    let chatBallonImageView: UIImageView! = UIImageView()
    let myBallonImage: UIImage! =  UIImage(named: "chat_balloon_mine")!.stretchableImage(withLeftCapWidth: 10, topCapHeight: 15)
    let otherBallonImage: UIImage! =  UIImage(named: "chat_balloon_others")!.stretchableImage(withLeftCapWidth: 30, topCapHeight: 15)
    let sendingStatusImage: UIImage! = UIImage(named: "ic_chat_sending_arrow")
    let failedStatusImage: UIImage! = UIImage(named: "ic_chat_sending_alert")
    var sendStatusImageView: UIImageView?
    
    open var isMine: Bool?
    open var isSameWeekDay: Bool?
    open var isSequenced: Bool?
    open var message: Message?
    open var sendingStatus: MessageCellSendingStatus? {
        didSet {
            self.layoutFollowingSendingStatus()
        }
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.separatorInset = UIEdgeInsets.zero
        
        weekDayLabal.viewSize = CGSize(width: kCommonDeviceWidth, height: 24.0)
        weekDayLabal.textAlignment = .center
        weekDayLabal.textColor = kGrayColor
        weekDayLabal.font = UIFont.systemFont(ofSize: 11)
        weekDayLabal.clipsToBounds = true
        weekDayLabal.layer.cornerRadius = 12.0
        self.contentView.addSubview(weekDayLabal)
        
        dateLabel.viewSize = CGSize(width: 34, height: 14)
        dateLabel.textAlignment = .center
        dateLabel.textColor = kGrayColor
        dateLabel.font = UIFont.systemFont(ofSize: 11)
        self.contentView.addSubview(dateLabel)
        
        chatBallonImageView.backgroundColor = UIColor.clear
        chatBallonImageView.clipsToBounds = false
        self.contentView.addSubview(chatBallonImageView)

        messageTextLabel.font = MessageTextLabelFont
        messageTextLabel.numberOfLines = 0
        messageTextLabel.lineBreakMode = .byCharWrapping
        self.contentView.addSubview(messageTextLabel)
        
        sendStatusImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10.0, height: 10.0))
        self.contentView.addSubview(sendStatusImageView!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let message: Message = object as! Message
        return self.textCellHeight(message.text!, isSameWeekDay: true)
    }
    
    open func setMessage(_ message: Message, isSameWeekDay: Bool, isSequenced: Bool) {
        self.message = message
        self.isSameWeekDay = isSameWeekDay
        self.isSequenced = isSequenced
        
        weekDayLabal.text = self.message?.date?.chatDate()
        weekDayLabal.isHidden = isSameWeekDay
        
        dateLabel.text = self.message?.date?.chatDateTodayWithDate()
        iconImageViewButton.isHidden = self.message?.isMine == true || self.isSequenced == true
        
        if Utility.isEmpty(self.message?.id) == false {
            self.sendingStatus = .complete
        } else {
            if self.message?.sendingFaild == true {
                DBLog("message.isMine: \(String(describing: message.isMine))")
                self.sendingStatus = .failed
            } else {
                self.sendingStatus = .sending
            }
        }
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let user: User? = cellModelObject as? User
            if Utility.isEmpty(user?.identifier) {
                return
            }
            
            if Me.sharedMe.isMine(user!.identifier!) == false {
                if user?.photo?.imageURL != nil {
                    iconImageViewButton.downloadImageWithURL(user?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)
                } else {
                    iconImageViewButton.setImage(kPlaceholderUserImage, for: UIControlState.normal)
                }
            }
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        weekDayLabal.center.x = self.center.x
        weekDayLabal.y = 10.0
        
        bottomLineView?.isHidden = true
    }
    
    func  layoutFollowingSendingStatus() {
        if sendingStatus == nil {
            return
        }
        switch sendingStatus! {
        case .sending:
            dateLabel.isHidden = false
            sendStatusImageView?.image = nil
            sendStatusImageView?.image = sendingStatusImage
            sendStatusImageView?.viewSize = sendingStatusImage.size
            sendStatusImageView?.y = dateLabel.y - sendStatusImageView!.height - 3.0
            sendStatusImageView?.center.x = dateLabel.center.x
            break
        case .failed:
            dateLabel.isHidden = true
            sendStatusImageView?.image = nil
            sendStatusImageView?.image = failedStatusImage
            sendStatusImageView?.viewSize = failedStatusImage.size
            sendStatusImageView?.bottom = dateLabel.bottom
            sendStatusImageView?.right = dateLabel.right - 3.0
            break
        case .complete:
            dateLabel.isHidden = false
            sendStatusImageView?.image = nil
            break
        }
    }
    
    class func maxBallonWidth() -> CGFloat {
        return kCommonDeviceWidth / 2
    }
    
    class func textCellHeight(_ text: String, isSameWeekDay: Bool, isSequenced: Bool, lineHeight: CGFloat) -> CGFloat {
        var width: CGFloat = text.getTextWidthWithFont(MessageTextLabelFont, viewHeight: CGFloat.greatestFiniteMagnitude)
        width = width > MessageCell.maxBallonWidth() ? MessageCell.maxBallonWidth() : width
        let weekDayHeight: CGFloat = isSameWeekDay ? 0 : (6.0 * 3) + MessagePartsMargin
        let margin: CGFloat = isSequenced ? MessageSequenceMargin : MessageMargin
        let gap: CGFloat = (isSequenced == true && isSameWeekDay == false) ? MessageMargin - MessageSequenceMargin : 0
        return max(lineHeight, text.getTextHeight(MessageTextLabelFont, viewWidth: width) + 14.0) + margin + weekDayHeight + gap
    }
    
    class func textCellHeight(_ text: String, isSameWeekDay: Bool, isSequenced: Bool) -> CGFloat {
        return self.textCellHeight(text, isSameWeekDay: isSameWeekDay, isSequenced: isSequenced, lineHeight: MininumTextHeight)
    }
    
    class func textCellHeight(_ text: String, isSameWeekDay: Bool) -> CGFloat {
        return self.textCellHeight(text, isSameWeekDay: isSameWeekDay, isSequenced: false)
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {}
    
    override open func setSelected(_ selected: Bool, animated: Bool) {}
    

}
