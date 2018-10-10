//
//  BaseImagePickerController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/11.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class BaseImagePickerController: UIImagePickerController {

    override open var prefersStatusBarHidden: Bool {
        return false
    }
    
    override open var preferredStatusBarStyle:  UIStatusBarStyle {
        return .lightContent
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.allowsEditing = true
    }
    
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
         super.pushViewController(viewController, animated: animated)
        if self.responds(to: #selector(self.setNeedsStatusBarAppearanceUpdate)) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open class func generateProfileIcon(_ img: UIImage) ->UIImage? {
        let width: CGFloat = img.size.width
        let height: CGFloat = img.size.height
        var iconImage: UIImage?
        let imageNormalSize: CGFloat = 500
        if width == height {
            iconImage = img.resizeImageFromImageSize(CGSize(width: imageNormalSize, height: imageNormalSize))
        } else if width > height {
            guard let tmpResizedImage = img.resizeImageFromImageSize(CGSize(width: imageNormalSize, height: imageNormalSize * height / width)) else { return nil }
            guard let backImage = UIImage.imageWithColor(UIColor.white, size: CGSize(width: imageNormalSize, height: imageNormalSize)) else { return nil }
            iconImage = backImage.imageAddingImage(tmpResizedImage, offset: CGPoint(x: 0, y: (imageNormalSize - tmpResizedImage.size.height) / 2))
        } else {
            guard let tmpResizedImage = img.resizeImageFromImageSize(CGSize(width: imageNormalSize * width / height, height: imageNormalSize)) else { return nil }
            guard let backImage = UIImage.imageWithColor(UIColor.white, size: CGSize(width: imageNormalSize, height: imageNormalSize)) else { return nil }
            iconImage = backImage.imageAddingImage(tmpResizedImage, offset: CGPoint(x: (imageNormalSize - tmpResizedImage.size.width)/2.0, y: 0))
        }
        return iconImage
    }
    
}
