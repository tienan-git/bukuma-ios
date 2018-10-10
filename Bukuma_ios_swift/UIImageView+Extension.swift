//
//  UIImageView+Extension.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage

public extension UIImageView {
    private var duration: TimeInterval { return 0.25 }

    public func downloadImageWithURL(_ url: URL?, placeholderImage: UIImage?) {
        guard let _ = url else { return }
        guard let _ = placeholderImage else { return }

        SDWebImageManager.shared().loadImage(
            with: url,
            options: .continueInBackground,
            progress: { [weak self] (receivedSize, expectedSize, targetURL) in
                if self?.image == nil {
                    DispatchQueue.main.async {
                        self?.image = UIImage.imageWithColor(kBorderColor, size: (self?.viewSize)!)
                    }
                }
            },
            completed: { [weak self] (image, data, error, cacheType, finished, imageURL) in
                guard let newImage = image ?? placeholderImage else { return }
                if newImage == self?.image { return }

                DispatchQueue.main.async {
                    if cacheType == .none && newImage != placeholderImage {
                        if let duration = self?.duration {
                            UIView.animate(withDuration: duration, animations: { 
                                self?.alpha = 0.1
                            }, completion: { (finished: Bool) in
                                UIView.animate(withDuration: duration, animations: { 
                                    self?.image = newImage
                                    self?.alpha = 1
                                })
                            })
                        } else {
                            self?.image = newImage
                        }
                    } else {
                        self?.image = newImage
                    }
                }
            }
        )
    }

    public func resizedImageSize(_ originalImageSize: CGSize, fixedHeight: CGFloat, fixedWidth: CGFloat)-> CGSize {
        return originalImageSize.height > originalImageSize.width ?
            CGSize(width: (originalImageSize.width * fixedHeight) / originalImageSize.height, height: fixedHeight) :
            CGSize(width: fixedWidth, height: (originalImageSize.height * fixedWidth) / originalImageSize.width)
    }

    public func resize(_ originalImageSize: CGSize, fixedHeight: CGFloat, fixedWidth: CGFloat, center: CGFloat) {
        self.viewSize = self.resizedImageSize(originalImageSize, fixedHeight: fixedHeight, fixedWidth: fixedWidth)
        self.x = (center - self.viewSize.width) / 2
    }
}
