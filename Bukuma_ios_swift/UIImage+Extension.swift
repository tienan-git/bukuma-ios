//
//  UIImage+Extension.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/11.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import CoreGraphics

private struct SizeReletaion {
    private enum Element {
        case Height
        case Width
    }
    private let longerSide: (value: CGFloat, element: Element)
    private let shoterSide: (value: CGFloat, element: Element)
    init(size: CGSize, scale: CGFloat) {
        longerSide = size.width > size.height ? (size.width * scale, .Width) : (size.height * scale, .Height)
        shoterSide = size.width > size.height ? (size.height * scale, .Height) : (size.width * scale, .Width)
    }
    func centerTrimRect() -> CGRect {
        let delta = (longerSide.value - shoterSide.value) / 2
        let x = longerSide.element == .Height ? 0 : delta
        let y = longerSide.element == .Width ? 0 : delta
        return CGRect(x: x, y: y, width: shoterSide.value, height: shoterSide.value)
    }
    
    func relativeCenterTrimRect(targetSize: CGSize) -> CGRect {
        let delta = -(longerSide.value - shoterSide.value) / 2
        let x = longerSide.element == .Height ? 0 : delta
        let y = longerSide.element == .Width ? 0 : delta
        let width = longerSide.element == .Width ? longerSide.value : shoterSide.value
        let height = longerSide.element == .Height ? longerSide.value : shoterSide.value
        let scale = shoterSide.element == .Height ? targetSize.height / height : targetSize.width / width
        return CGRect(
            x: x * scale,
            y: y * scale,
            width: width * scale,
            height: height * scale
        )
    }
}

public extension UIImage {
    
    public func resizeImageFromImageSize(_ size: CGSize) ->UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    public class func imageWithColor(_ color: UIColor, size: CGSize) ->UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public class func imageWithColor(_ color: UIColor, _ cornerRadius: CGFloat, size: CGSize) ->UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        bezierPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    func roundedCenterTrimImage(cornerRadius: CGFloat, targetSize: CGSize) -> UIImage? {
        let sizeRelation = SizeReletaion(size: size, scale: scale)
        guard let newImage = trimmedImage(rect: sizeRelation.centerTrimRect()) else {
            return nil
        }
        let scaledSize = CGSize(width: targetSize.width * scale, height: targetSize.height * scale)
        UIGraphicsBeginImageContext(scaledSize)
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height), cornerRadius: cornerRadius)
        let imageView = UIImageView(image: newImage)
        imageView.frame = CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height)
        imageView.layer.masksToBounds = true
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        imageView.layer.mask = maskLayer
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        imageView.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func trimmedImage(rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage!.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    public class func imageWithColor(_ color: UIColor) ->UIImage? {
        return self.imageWithColor(color, size: CGSize(width: 1.0, height: 1.0))
    }
    
    public func imageAddingImage(_ image: UIImage, offset: CGPoint) ->UIImage? {
        var size: CGSize  = self.size
        let scale: CGFloat = self.scale
        
        size.width *= scale
        size.height *= scale
        
        UIGraphicsBeginImageContext(size)
        
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        image.draw(in: CGRect(x: scale * offset.x, y: scale * offset.y, width: image.size.width * scale, height: image.size.height * scale))
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        guard let bitmapContext = context.makeImage() else { return nil }
        let destImage = UIImage(cgImage: bitmapContext, scale: image.scale, orientation: .up)
        UIGraphicsEndImageContext()
        return destImage
    }    
}
