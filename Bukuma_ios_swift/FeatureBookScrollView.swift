//
//  FeatureBookScrollView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/20.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SDWebImage

//public let FeatureBookScrollViewImageViewsHeight: CGFloat = 50.0

public let FeatureBookScrollViewViewsHeight: CGFloat = FeatureBookScrollView.imageViewHeight() + 20.0

public protocol FeatureBookScrollViewDelegate {
    func featureBookScrollViewBannerTapped(_ view: FeatureBookScrollView, tag: Int, completion:@escaping () ->Void)
}

open class FeatureBookScrollView: UIScrollView {
    
    var bannerButtons: [UIButton]?
    var aDelegate: FeatureBookScrollViewDelegate?
    
    deinit {
        for banner in bannerButtons! {
            banner.imageView?.image = nil
        }
        bannerButtons = nil
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: FeatureBookScrollViewViewsHeight))
        
        self.contentSize = CGSize(width: kCommonDeviceWidth * CGFloat(Banner.bannersCount), height: FeatureBookScrollView.imageViewHeight())
        self.isUserInteractionEnabled = true
        self.isScrollEnabled = true
        self.isPagingEnabled = true
        self.isExclusiveTouch = true
        self.showsHorizontalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        bannerButtons = Array()
        
    }
    
    func bannerTapped(_ sender: UIButton) {
        self.isUserInteractionEnabled = false
        self.aDelegate?.featureBookScrollViewBannerTapped(self, tag: sender.tag, completion: { [weak self] _ in
            DispatchQueue.main.async {
                self?.isUserInteractionEnabled = true
            }
        })
    }
    
    func createBanners(_ completion: () ->Void) {
        bannerButtons?.removeAll()
        
        if  bannerButtons != nil && Banner.bannersCount > 0 {
            if Banner.bannersCount == 1 {
                let bannerButton: UIButton = UIButton(frame: CGRect(x: 10 + CGFloat(0) * kCommonDeviceWidth, y: 10.0, width: FeatureBookScrollView.imageViewWidth(), height: FeatureBookScrollView.imageViewHeight()))
                bannerButton.imageView?.contentMode = .scaleAspectFill
                bannerButton.contentVerticalAlignment = .center
                bannerButton.contentHorizontalAlignment = .center
                bannerButton.tag = 0
                bannerButton.addTarget(self, action: #selector(self.bannerTapped(_:)), for: .touchUpInside)
                bannerButtons?.append(bannerButton)
                self.addSubview(bannerButton)
                self.contentSize.width = kCommonDeviceWidth * CGFloat(Banner.bannersCount)
                completion()
                return
            }
            for i in 0...(Banner.bannersCount - 1) {
                let bannerButton: UIButton = UIButton(frame: CGRect(x: 10 + CGFloat(i) * kCommonDeviceWidth, y: 10.0, width: FeatureBookScrollView.imageViewWidth(), height: FeatureBookScrollView.imageViewHeight()))
                bannerButton.imageView?.contentMode = .scaleAspectFill
                bannerButton.contentVerticalAlignment = .center
                bannerButton.contentHorizontalAlignment = .center
                bannerButton.tag = i
                bannerButton.addTarget(self, action: #selector(self.bannerTapped(_:)), for: .touchUpInside)
                bannerButtons?.append(bannerButton)
                self.addSubview(bannerButton)
            }
            self.contentSize.width = kCommonDeviceWidth * CGFloat(Banner.bannersCount)
            completion()
        }
    }
    
    class func imageViewHeight() ->CGFloat {
        return imageViewWidth()  * 50 / 320
    }
    
    class func imageViewWidth() ->CGFloat {
        return kCommonDeviceWidth - 20
    }
    
    var banners: [Banner]? {
        didSet {
            var i: Int = 0
            for banner in bannerButtons! {
                if (bannerButtons?.count ?? 0) > i && ((bannerButtons?.count ?? 0)) > 0 {
                    if let url = banners?[i].imageUrl {
                       // banner.sd_setBackgroundImage(with: url, for: .normal)
                        
                        banner.downloadImageWithURL(url, placeholderImage: UIImage.imageWithColor(UIColor.clear, size: CGSize(width: kCommonDeviceWidth, height: FeatureBookScrollView.imageViewHeight())))
                    }
                }
                i += 1
            }
        }
    }
}
