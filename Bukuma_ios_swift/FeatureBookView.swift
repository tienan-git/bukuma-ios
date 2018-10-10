//
//  FeatureBookView.swift
//  Bukuma_ios_swift
//
//  Created by hara on 5/9/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import UIKit

protocol FeatureBookViewProtocol {
    func bannerTapped(with bannerView: FeatureBookView, completion: @escaping ()-> Void)
}

class FeatureBookView: UIView {
    var delegate: FeatureBookViewProtocol?
    var banner: Banner? {
        didSet {
            if let imageUrl = self.banner?.imageUrl {
                self.isHidden = false
                let placeholderImage = UIImage.imageWithColor(UIColor.clear, size: CGSize(width: FeatureBookView.imageViewWidth, height: FeatureBookView.imageViewHeight))
                self.bannerButton?.downloadImageWithURL(imageUrl, placeholderImage: placeholderImage)
            } else {
                self.isHidden = true
                self.bannerButton?.setImage(nil, for: .normal)
            }
        }
    }

    static var bannerViewHeight: CGFloat {
        get { return FeatureBookView.viewHeight }
    }

    private static let viewMarginH: CGFloat = 10
    private static let viewMarginV: CGFloat = 10

    private static var imageViewWidth: CGFloat {
        get { return self.viewWidth - (self.viewMarginH * 2) }
    }
    private static var imageViewHeight: CGFloat {
        get { return self.imageViewWidth * 50 / 320 }
    }
    private static var viewWidth: CGFloat {
        get { return kCommonDeviceWidth }
    }
    private static var viewHeight: CGFloat {
        get { return self.imageViewHeight + (self.viewMarginV * 2) }
    }

    private var bannerButton: UIButton?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init() {
        super.init(frame: CGRect(x: 0, y: 0, width: FeatureBookView.viewWidth, height: FeatureBookView.viewHeight))

        self.bannerButton = self.createBunnerButton()
        self.addSubview(self.bannerButton!)
    }

    private func createBunnerButton()-> UIButton {
        let buttonFrame = CGRect(x: FeatureBookView.viewMarginH, y: FeatureBookView.viewMarginV, width: FeatureBookView.imageViewWidth, height: FeatureBookView.imageViewHeight)
        let bannerButton = UIButton(frame: buttonFrame)
        bannerButton.imageView?.contentMode = .scaleAspectFill
        bannerButton.contentVerticalAlignment = .center
        bannerButton.contentHorizontalAlignment = .center
        bannerButton.addTarget(self, action: #selector(self.bannerButtonTapped(_:)), for: .touchUpInside)
        return bannerButton
    }

    func bannerButtonTapped(_ sender: UIButton) {
        self.isUserInteractionEnabled = false
        self.delegate?.bannerTapped(with: self) { [weak self] () in
            DispatchQueue.main.async {
                self?.isUserInteractionEnabled = true
            }
        }
    }
}
