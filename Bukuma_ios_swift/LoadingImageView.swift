//
//  LoadingImageView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class LoadingImageView: SheetView, CAAnimationDelegate {
    
    var imageView: UIImageView?
    var titleLabel: UILabel?
    var detailLabel: UILabel?
    
    public convenience init() {
        self.init(delegate: nil)
        
        self.backgroundColor = kBlackColor54
        
        sheetView.clipsToBounds = false
        
        let loadingImage: UIImage = UIImage(named: "ani_search-1")!
        imageView = UIImageView()
        imageView?.image = loadingImage
        imageView?.frame = CGRect(x: 0, y: 0, width: loadingImage.size.width, height: loadingImage.size.height)
        imageView?.clipsToBounds = true
        imageView?.layer.cornerRadius = 2.0
        imageView?.animationRepeatCount = 1
        imageView?.animationImages = self.buttonImages()
        imageView?.animationDuration = 0.3
        sheetView.addSubview(imageView!)
        
        self.sheetView.width = imageView!.width
        
        self.sheetView.x = (kCommonDeviceWidth - self.sheetView.width) / 2
        
        titleLabel = UILabel()
        titleLabel?.frame = CGRect(x: 0,
                                   y: imageView!.bottom + 33.0,
                                   width: sheetView.width,
                                   height: 25.0)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel?.textColor = kBlackColor87
        titleLabel?.text = "情報を取得しています"
        titleLabel?.textAlignment = .center
        sheetView.addSubview(titleLabel!)
        
        detailLabel = UILabel()
        detailLabel?.frame = CGRect(x: 20.0,
                                    y: titleLabel!.bottom + 15.0,
                                    width: sheetView.width - 20.0 * 2,
                                    height: 0)
        detailLabel?.font = UIFont.systemFont(ofSize: 12)
        detailLabel?.textAlignment = .center
        detailLabel?.numberOfLines = 0
        detailLabel?.text = "取得まで数分かかることがあります"
        detailLabel?.textColor = kBlackColor70
        detailLabel?.height = detailLabel!.text!.getTextHeight(detailLabel!.font, viewWidth: detailLabel!.width)
        sheetView.addSubview(detailLabel!)
        
        sheetView.height = detailLabel!.bottom + 33.0
        sheetView.y = kCommonDeviceHeight
        
    }
    
    func startAnimation() {
       DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.8 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute:  {
            let animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "LoadingImageViewAnimation")
            animation.calculationMode = kCAAnimationDiscrete
            animation.duration = 0.3
            animation.repeatCount = 1
            animation.delegate = self
            animation.fillMode = kCAFillModeForwards
            self.imageView?.layer.add(animation, forKey: kCATransition)
            self.imageView?.startAnimating()
        })
    }
    
    func stopAnimation() {
        imageView?.layer.removeAllAnimations()
        imageView?.layer.removeAnimation(forKey: "LoadingImageViewAnimation")
        imageView?.stopAnimating()
    }
    
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag == true {
            self.startAnimation()
        }
    }
    
    fileprivate func buttonImages() ->Array<UIImage> {
        var array: Array<UIImage> = Array()
        for i in 1...15 {
            let imagePath: String = "ani_search-\(i)"
            let image: UIImage = UIImage(named: imagePath)!
            array.append(image)
        }
        return array
    }

    override open func disappear(_ completion: (() ->Void)?) {
        if self.superview == nil {
            return
        }
        
        UIView.animate(withDuration:0.25, animations: {
            self.alpha = 0.0
            
        }) { (isFinished) in
            UIView.animate(withDuration:0.25, animations: {
                self.sheetView.top = self.height
                }, completion: { (isFinished) in
                    if completion != nil {
                        completion!()
                    }
                    self.removeFromSuperview()
            })
        }
    }
}
