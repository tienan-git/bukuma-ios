//
//  MediaMessageCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/13.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public let MediaMessageCellReuseIdentifier: String = "MediaMessageCellReuseIdentifier"

let MediaButtonWidth: CGFloat = 220.0
let MediaButtonHeight: CGFloat = 220.0

public enum MediaButtonState: Int {
    case sending
    case failedSend
    case sent
}

open class MediaButton: UIButton {
    
    var mediaState: MediaButtonState? {
        didSet {
            if mediaState == nil {
                return
            }
            
            switch mediaState! {
            case .sending:
                self.isUserInteractionEnabled = false
                break
            case .failedSend:
                self.isUserInteractionEnabled = true
                break
            case .sent:
                self.isUserInteractionEnabled = true
                break
            }
        }
    }
        
    required public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: MediaButtonWidth, height: MediaButtonHeight))
        
        self.imageView?.contentMode = .scaleAspectFill
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 3.0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public protocol MediaMessageCellDelegate: BaseTableViewCellDelegate {
    func mediaMessageCellMediaButtonTapped(_ cell: MediaMessageCell)
}

open class MediaMessageCell: MessageCell {
    
    var mediaButton: MediaButton?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        mediaButton = MediaButton()
        mediaButton?.addTarget(self, action: #selector(self.mediaButtonTapped(_:)), for: .touchUpInside)
        self.contentView.addSubview(mediaButton!)
        
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func setMessage(_ message: Message, isSameWeekDay: Bool, isSequenced: Bool) {
        super.setMessage(message, isSameWeekDay: isSameWeekDay, isSequenced: isSequenced)
        
        if message.imageUrl != nil && message.imageUrl != URL(string: "") {
            mediaButton?.downloadImageWithURL(message.imageUrl, placeholderImage: kPlacejolderBookImage)
            return
        }
        mediaButton?.setImage(message.image, for: .normal)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let cellMargin: CGFloat = isSequenced == true ? MessageSequenceMargin : MessageMargin
        
        if message?.isMine == true {
            mediaButton?.viewOrigin = CGPoint(x: kCommonDeviceWidth - mediaButton!.width - 11.0 ,
                                          y: isSameWeekDay == true ? cellMargin : weekDayLabal!.bottom + 6.0)
            dateLabel?.viewOrigin = CGPoint(x: mediaButton!.x - dateLabel!.width - 4.0,
                                        y: mediaButton!.bottom - dateLabel!.height)
        } else {
            iconImageViewButton.viewOrigin = CGPoint(x: MessageMargin,
                                                 y: isSameWeekDay == true ? cellMargin : weekDayLabal!.bottom + 6.0)
            mediaButton?.viewOrigin = CGPoint(x: iconImageViewButton.right + MessageMargin,
                                          y: isSameWeekDay == true ? cellMargin : weekDayLabal.bottom + 6.0)
            dateLabel?.viewOrigin = CGPoint(x: mediaButton!.right + 4.0,
                                        y: mediaButton!.bottom - dateLabel!.height)
        }
        self.layoutFollowingSendingStatus()
    }
    
    override func layoutFollowingSendingStatus() {
        super.layoutFollowingSendingStatus()
        
        if message?.isMine == true {
            if sendingStatus == nil {
                return
            }
            switch sendingStatus! {
            case .sending:
                mediaButton?.mediaState = .sending
                break
            case .failed:
                mediaButton?.mediaState = .failedSend
                break
            case .complete:
                mediaButton?.mediaState = .sent
                break
            }
        }
    }
    
    func mediaButtonTapped(_ sender: UIButton) {
        (delegate as? MediaMessageCellDelegate)?.mediaMessageCellMediaButtonTapped(self)
    }
    
    open class func mediaCellHeight(_ isSameWeekDay: Bool, isSequenced: Bool) ->CGFloat {
        let weekDayHeight: CGFloat = isSameWeekDay ? 0 : (6.0 * 3) + MessagePartsMargin
        let margin: CGFloat = isSequenced ? MessageSequenceMargin : MessageMargin
        let gap: CGFloat = (isSequenced && !isSameWeekDay) ? MessageMargin - MessageSequenceMargin : 0
        return MediaButtonHeight + margin + weekDayHeight + margin + gap
    }
    
    override  open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return MediaButtonHeight + MessageMargin * 2
    }
}
