//
//  BaseMensionCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/20.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

let BaseMensionCellbuttonHeight: CGFloat = 35.0

public protocol BaseMensionCellDelegate:BaseTableViewCellDelegate {
    func baseMensionCellActionButtonTapped(_ message: Message)
}

open class BaseMensionCell: MessageCell {
    
    var mensionImageView: UIImageView?
    var borderView: UIView?
    var actionButton: UIButton?
    var toImageView: UIImageView?
    
    class func mensionImage() ->UIImage? {
        return nil
    }
    
    class func actionTitle() ->String? {
        return nil
    }
    
    class func imageSize() ->CGSize {
        return CGSize(width: (maxBallonWidth() + MessageBallonPadding * 2) - 10.0 - 16.0, height: 120.0)
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        chatBallonImageView.backgroundColor = UIColor.clear
        chatBallonImageView.clipsToBounds = false
        chatBallonImageView.isUserInteractionEnabled = true
        self.contentView.addSubview(chatBallonImageView)
        
        mensionImageView = UIImageView()
        mensionImageView?.clipsToBounds = true
        //mensionImageView?.layer.borderWidth = 1
        mensionImageView?.backgroundColor = UIColor.clear
        mensionImageView?.image = type(of: self).mensionImage()
        mensionImageView?.viewSize = type(of: self).mensionImage()?.size ?? CGSize.zero
        self.contentView.addSubview(mensionImageView ?? UIImageView())

        borderView = UIView()
        borderView?.y = mensionImageView!.bottom - 0.5
        borderView?.backgroundColor = kBorderColor
        borderView?.clipsToBounds = true
        self.contentView.addSubview(borderView ?? UIView())
        
        actionButton = UIButton()
        actionButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        actionButton?.setTitle(type(of: self).actionTitle(), for: UIControlState.normal)
        actionButton?.addTarget(self, action: #selector(self.actionButtonTapped(_:)), for: .touchUpInside)
        //actionButton?.layer.borderWidth = 1
        self.contentView.addSubview(actionButton ?? UIButton())
        
        toImageView = UIImageView(image: UIImage(named: "ic_s_arrow_whtie"))
        toImageView?.clipsToBounds = true
        toImageView?.isUserInteractionEnabled = true
        //toImageView?.layer.borderWidth = 1
        self.contentView.addSubview(toImageView ?? UIImageView())
    
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func setMessage(_ message: Message, isSameWeekDay: Bool, isSequenced: Bool) {
        super.setMessage(message, isSameWeekDay: isSameWeekDay, isSequenced: isSequenced)
        
    }
    
    func actionButtonTapped(_ sender: UIButton) {
        (delegate as? BaseMensionCellDelegate)?.baseMensionCellActionButtonTapped(message ?? Message())
    }
    
    fileprivate class func mensionHeight(_ message: Message) ->CGFloat {
        let mergin: CGFloat = Utility.isEmpty(message.merchandise?.id) ? 0 : 10.0
        return MessageBookMensionView.viewHeight(message.merchandise ?? Merchandise()) + mergin
    }
    
    class func mensionCellHeight(_ message: Message?, isSameDay: Bool, isSeqence: Bool) ->CGFloat {
        let weekDayHeight: CGFloat = isSameDay ? 0 : (6.0 * 3) + MessagePartsMargin
        let margin: CGFloat = isSeqence ? MessageSequenceMargin : MessageMargin
        let gap: CGFloat = (isSeqence == true && isSameDay == false) ? MessageMargin - MessageSequenceMargin : 0
        return self.ballonImageheight(message) + margin + weekDayHeight + gap
    }

    class func ballonImageheight(_ message: Message?) ->CGFloat {
        if message == nil {
            return 0
        }
        if message?.isMine == true {
            return (self.mensionImage()?.size.height ?? 0) + BaseMensionCellbuttonHeight + 10.0 + 10.0
        }
        return (self.mensionImage()?.size.height ?? 0) + BaseMensionCellbuttonHeight + 10.0 + 10.0 + 5.0
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
            
            mensionImageView?.viewOrigin = CGPoint(x: chatBallonImageView.x + (chatBallonImageView.width - mensionImageView!.width) / 2, y: chatBallonImageView!.y + 10.0)
            actionButton?.viewSize = CGSize(width: chatBallonImageView.width - 6.0, height: BaseMensionCellbuttonHeight)
            actionButton?.setTitleColor(UIColor.white, for: UIControlState.normal)
            
            toImageView?.image = nil
            toImageView?.viewSize = CGSize.zero
            
            toImageView?.image = UIImage(named: "ic_s_arrow_whtie")
            toImageView?.viewSize = CGSize(width: UIImage(named: "ic_s_arrow_whtie")?.size.width ?? 0, height: UIImage(named: "ic_s_arrow_whtie")?.size.height ?? 0)
            toImageView?.viewOrigin = CGPoint(x: chatBallonImageView.right - 6.0 - 10.0 - toImageView!.width, y: mensionImageView!.bottom + 10.0)
            
            actionButton?.y = mensionImageView!.bottom + 10.0
            actionButton?.x = chatBallonImageView.x
            
            borderView?.isHidden = true
            
            dateLabel.viewOrigin = CGPoint(x: chatBallonImageView.x - dateLabel.width - 4.0,
                                       y: chatBallonImageView.bottom - dateLabel.height)
        } else {
            
            iconImageViewButton.viewOrigin = CGPoint(x: 12.0, y: isSameWeekDay == true ? cellMargin : weekDayLabal.bottom + 6.0)
            
            chatBallonImageView.image = otherBallonImage
            chatBallonImageView.frame = CGRect(x: iconImageViewButton.right + 6.0,
                                               y: iconImageViewButton.y,
                                               width: MessageCell.maxBallonWidth() + MessageBallonPadding * 2,
                                               height: type(of: self).ballonImageheight(message))
            mensionImageView?.viewOrigin = CGPoint(x: chatBallonImageView.x + (chatBallonImageView.width - mensionImageView!.width) / 2 + 10.0, y: chatBallonImageView!.y + 10.0)
            actionButton?.viewSize = CGSize(width: chatBallonImageView.width - 6.0, height: BaseMensionCellbuttonHeight)
            actionButton?.setTitleColor(kGray03Color, for: UIControlState.normal)

            borderView?.viewSize = CGSize(width: chatBallonImageView.width - 10.0 * 2 - 6.0 * 3, height: 0.5)
            borderView?.y = mensionImageView!.bottom + 10.0
            
            toImageView?.image = nil
            toImageView?.viewSize = CGSize.zero
            
            toImageView?.image = UIImage(named: "ic_to")
            toImageView?.viewSize = CGSize(width: UIImage(named: "ic_to")?.size.width ?? 0, height: UIImage(named: "ic_to")?.size.height ?? 0)
            toImageView?.viewOrigin = CGPoint(x: chatBallonImageView.right - 6.0 - toImageView!.width, y: borderView!.bottom - 7.5)
            
            actionButton?.y = borderView!.bottom
            actionButton?.x = chatBallonImageView.x + 6.0

            borderView?.isHidden = false
            
            borderView?.x = actionButton!.x + 10.0 + 6.0

            dateLabel.viewOrigin = CGPoint(x: chatBallonImageView.right + 4.0,
                                       y: chatBallonImageView.bottom - dateLabel.height)
        }
        
        self.layoutFollowingSendingStatus()
    }
}
