//
//  ProfileViewHeaderView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

@objc public protocol ProfileSettingViewHeaderViewDelegate: NSObjectProtocol {
    func headerViewIconButtonTapped(_ view: ProfileSettingViewHeaderView)
}

private let iconImageViewIconSize = CGSize(width: 85, height: 85)
let backGroundGreenViewHeight: CGFloat = 300

open class ProfileSettingViewHeaderView: UIView {

    weak var delegate: ProfileSettingViewHeaderViewDelegate?
    let iconImageViewButton: UIButton! = UIButton()
    var backGroundGreenView: UIView?
    
    required public init(delegate: ProfileSettingViewHeaderViewDelegate) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 145))
        self.delegate = delegate
        self.backgroundColor = kMainGreenColor
        
        backGroundGreenView = UIView(frame: CGRect(x: 0, y: -backGroundGreenViewHeight, width: kCommonDeviceWidth, height: backGroundGreenViewHeight))
        backGroundGreenView!.backgroundColor = kMainGreenColor
        self.addSubview(backGroundGreenView!)
        
        iconImageViewButton.frame = CGRect(x: (kCommonDeviceWidth - iconImageViewIconSize.width) / 2,
                                     y: (self.height - iconImageViewIconSize.height) / 2,
                                     width:iconImageViewIconSize.width,
                                     height: iconImageViewIconSize.height)
        iconImageViewButton.clipsToBounds = true
        iconImageViewButton.layer.cornerRadius = iconImageViewButton.height / 2
        iconImageViewButton.layer.borderWidth = 2.0
        iconImageViewButton.layer.borderColor = UIColor.white.cgColor
        iconImageViewButton.imageView?.contentMode = .scaleToFill
        iconImageViewButton.contentVerticalAlignment = .fill
        iconImageViewButton.contentHorizontalAlignment = .fill
        iconImageViewButton.addTarget(self, action: #selector(self.iconImageViewButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(iconImageViewButton)
        
        let image: UIImage = UIImage(named: "img_profile_camera")!
        
        let cameraImageViewButton: UIButton! = UIButton()
        cameraImageViewButton.viewSize = CGSize(width: image.size.width, height: image.size.height)
        cameraImageViewButton.setImage(image, for: .normal)
        cameraImageViewButton.right = iconImageViewButton.right + 12.0
        cameraImageViewButton.bottom = iconImageViewButton.bottom - 2.0
        cameraImageViewButton.clipsToBounds = true
        cameraImageViewButton.layer.cornerRadius = cameraImageViewButton.height / 2
        cameraImageViewButton.addTarget(self, action: #selector(self.iconImageViewButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(cameraImageViewButton)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var user: User? {
        didSet {
             DBLog(user?.photo?.image)
            
            if user?.photo?.image != nil {
                iconImageViewButton.setImage(user?.photo?.image, for: .normal)
                return
            } else {
                if user?.facebook?.picture?.url != nil {
                    iconImageViewButton.downloadImageWithURL(user?.facebook?.picture?.url, placeholderImage: UIImage(named: "img_thumbnail_user"))
                } else {
                    iconImageViewButton.setImage(UIImage(named: "img_thumbnail_user"), for: .normal)
                }
                
                if user?.photo?.imageURL != nil {
                    
                    iconImageViewButton.downloadImageWithURL(user?.photo?.imageURL, placeholderImage: UIImage(named: "img_thumbnail_user"))
                } else {
                    iconImageViewButton.setImage(UIImage(named: "img_thumbnail_user"), for: .normal)
                }
            }
        }
    }
    
    func iconImageViewButtonTapped(_ sender: UIButton) {
        if self.delegate!.responds(to: #selector(ProfileSettingViewHeaderViewDelegate.headerViewIconButtonTapped(_:))){
            self.delegate!.headerViewIconButtonTapped(self)
        }
    }
}
