//
//  UIButton+Extension.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit
import SDWebImage

public extension UIButton {
    
    public func imageWithColor(_ color: UIColor) ->UIImage? {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)

        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public func setBackgroundColor(_ color: UIColor, state: UIControlState) {
        self.setBackgroundImage(self.imageWithColor(color), for: state)
    }
    
    public func downloadImageWithURL(_ url: URL?, placeholderImage: UIImage?) {
        guard let _ = url else { return }
        guard let _ = placeholderImage else { return }

        SDWebImageManager.shared().loadImage(
            with: url,
            options: .continueInBackground,
            progress: { [weak self] (receivedSize, expectedSize, targetURL) in
                if self?.image(for: .normal) == nil {
                    DispatchQueue.main.async {
                        self?.setImage(UIImage.imageWithColor(kBorderColor, size: (self?.viewSize)!), for: .normal)
                    }
                }
            },
            completed: { [weak self] (image, data, error, cacheType, finished, imageURL) in
                guard let newImage = image ?? placeholderImage else { return }
                if newImage == self?.image(for: .normal) { return }

                DispatchQueue.main.async {
                    if cacheType == .none && newImage != placeholderImage {
                        self?.alpha = 0.0
                        UIView.animate(withDuration: 0.25, animations: {
                            self?.setImage(newImage, for: .normal)
                            self?.alpha = 1.0
                        })
                    } else {
                        self?.setImage(newImage, for: .normal)
                    }
                }
            }
        )
    }
}
