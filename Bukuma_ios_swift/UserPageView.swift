//
//  File.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit

@objc public protocol UserPageViewDelegate: NSObjectProtocol {
    func userPageViewIconTapped(_ view: UserPageView)
    func userPageVieweChatButtonTapped(_ view: UserPageView)
}

open class UserPageView: UIView {
    
    weak var delegate: UserPageViewDelegate?
    let headerView = UIView()
    let userIconButton = UIButton()
    let userNameLabel = UILabel()
    let statusLabel = UILabel()
    let bioLabel = UILabel()
    let chatButton = UIButton()
    let officalLabel = UILabel()
    let officalIconImage = UIImageView()
    
    let userIconSize: CGSize = CGSize(width: 90, height: 90)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(delegate: UserPageViewDelegate) {
        self.init()
        self.delegate = delegate
        
        self.backgroundColor = UIColor.white
        
        headerView.frame =  CGRect(x: 0, y: 0.0, width: kCommonDeviceWidth, height: 60)
        headerView.backgroundColor = kMainGreenColor
        self.addSubview(headerView)
        
        userIconButton.frame = CGRect(x: 0, y: 10.0, width: userIconSize.width, height: userIconSize.height)
        userIconButton.center.x = kCommonDeviceWidth / 2
        userIconButton.adjustsImageWhenHighlighted = false
        userIconButton.clipsToBounds = true
        userIconButton.layer.cornerRadius = userIconButton.width / 2.0
        userIconButton.layer.borderWidth = 3.0
        userIconButton.layer.borderColor = UIColor.white.cgColor
        userIconButton.imageView!.contentMode = .scaleAspectFill
        userIconButton.contentVerticalAlignment = .fill
        userIconButton.contentHorizontalAlignment = .fill
        userIconButton.addTarget(self, action: #selector(self.userIconButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(userIconButton)
        
        officalLabel.frame = CGRect(x:0, y: userIconButton.bottom + 7.0, width: kCommonDeviceWidth, height: 14)
        officalLabel.font = UIFont.boldSystemFont(ofSize: 10)
        officalLabel.text = "認証アカウント"
        officalLabel.textColor = kBlackColor54
        officalLabel.textAlignment = .center
        self.addSubview(officalLabel)
        
        userNameLabel.frame = CGRect(x: 0, y: userIconButton.bottom + 7.0, width: kCommonDeviceWidth, height: 20)
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        userNameLabel.textColor = kBlackColor87
        userNameLabel.textAlignment = .center
        self.addSubview(userNameLabel)
        
        let iconOfficial = UIImage(named: "ic_official")!
        officalIconImage.image = iconOfficial
        officalIconImage.frame = CGRect(x: 0, y: userIconButton.bottom + 7.0, width: iconOfficial.size.width, height: iconOfficial.size.height)
        self.addSubview(officalIconImage)
        
        statusLabel.frame = CGRect(x: 0, y: userNameLabel.bottom + 5.0, width: kCommonDeviceWidth, height: 0)
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textColor = kMainGreenColor
        statusLabel.textAlignment = .center
        //statusLabel.text = "未設定 / 未設定"
        self.addSubview(statusLabel)
        
        bioLabel.frame = CGRect(x: 10, y: statusLabel.bottom + 7.0, width: kCommonDeviceWidth - 10 * 2, height: 100)
        bioLabel.font = UIFont.systemFont(ofSize: 12)
        bioLabel.textColor = kBlackColor87
        bioLabel.textAlignment = .center
        bioLabel.numberOfLines = 0
        self.addSubview(bioLabel)
        
        chatButton.viewSize = CGSize(width: kCommonDeviceWidth - 50 * 2, height: UIImage(named: "img_stretch_btn")!.size.height)
        chatButton.viewOrigin = CGPoint(x: 50, y: bioLabel.bottom + 20.0)
        chatButton.clipsToBounds = true
        chatButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        chatButton.setTitleColor(UIColor.white, for: UIControlState())
        chatButton.setBackgroundImage(UIImage(named: "img_stretch_btn")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: UIControlState())
        chatButton.addTarget(self, action: #selector(self.chatButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(chatButton)
    
    }
    
    var user: User? {
        didSet {
            if user?.photo?.imageURL != nil {
                userIconButton.downloadImageWithURL(user?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)

            } else {
                userIconButton.setImage(kPlaceholderUserImage, for: .normal)
            }
            userNameLabel.text = user?.nickName.map{$0}
            
            if user?.isOfficial ?? false {
                officalLabel.isHidden = false
                officalIconImage.isHidden = false
                
                let nameSizeMax = CGSize(width: kCommonDeviceWidth - officalIconImage.width * 2, height: 20)
                let nameSize = userNameLabel.sizeThatFits(nameSizeMax)
                officalIconImage.x = min((kCommonDeviceWidth + nameSize.width) / 2.0 + 4.0, kCommonDeviceWidth - officalIconImage.width)
                officalIconImage.y = officalLabel.bottom + 4.0
                
                userNameLabel.frame = CGRect(x: 0, y: officalLabel.bottom + 4.0, width: kCommonDeviceWidth, height: 20)
                
                statusLabel.y = userNameLabel.bottom + 5.0
                bioLabel.y = statusLabel.bottom + 7.0
                chatButton.y = bioLabel.bottom + 20.0
            } else {
                officalLabel.isHidden = true
                officalIconImage.isHidden = true
                
                userNameLabel.y = userIconButton.bottom + 7.0
                statusLabel.y = userNameLabel.bottom + 5.0
                bioLabel.y = statusLabel.bottom + 7.0
                chatButton.y = bioLabel.bottom + 20.0
            }
            
            chatButton.setTitle(Me.sharedMe.isMine(user?.identifier ?? "0") == true ? "プロフィール設定" : "メッセージを送る", for: UIControlState())
            
            bioLabel.text = user?.bio.map{$0}
            if Utility.isEmpty(user?.bio) {
                 bioLabel.text = ""
            } else {
                bioLabel.text = user!.bio!
            }
            bioLabel.height =  bioLabel.text!.getTextHeight(bioLabel.font, viewWidth: bioLabel.width)
            chatButton.y = bioLabel.bottom + 20.0
            self.height = chatButton.bottom + 15.0
        }
    }
    
    func userIconButtonTapped(_ sender: UIButton) {
        if self.delegate!.responds(to: #selector(UserPageViewDelegate.userPageViewIconTapped(_:))) {
            self.delegate!.userPageViewIconTapped(self)
        }
    }

    func chatButtonTapped(_ sender: UIButton) {
        if self.delegate!.responds(to: #selector(UserPageViewDelegate.userPageVieweChatButtonTapped(_:))) {
            self.delegate!.userPageVieweChatButtonTapped(self)
        }
    }
}
