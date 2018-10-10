//
//  EmptyDataView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/06.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


@objc public protocol EmptyDataViewDelegate: NSObjectProtocol {
    func emptyViewCenterPositionY() ->CGFloat
    func placeHolderImageOnEmptyView(_ view: EmptyDataView) ->UIImage?
    func titleOnEmptyView(_ view: EmptyDataView) ->String
    func bodyOnEmptyView(_ view: EmptyDataView) ->String
}

private let EmptyDataViewMargin: CGFloat = 10.0

public struct EmptyDataViewConfig {
    var titleTextColor: UIColor?
    var bodyColor: UIColor?
}

open class EmptyDataView: UIView {
    
    let label: UILabel = UILabel()
    let emptyDataImageView: UIImageView = UIImageView()
    var titleLabel: UILabel?
    let descriptionLabel: UILabel! = UILabel()
    var config: EmptyDataViewConfig? = EmptyDataViewConfig()
    weak var delegate: EmptyDataViewDelegate?
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 0))
        
        emptyDataImageView.center.x = self.width / 2
        self.addSubview(emptyDataImageView)
        
        titleLabel = UILabel()
        titleLabel?.frame = CGRect(x: EmptyDataViewMargin * 2,
                                   y: 0,
                                   width: kCommonDeviceWidth - EmptyDataViewMargin * 4,
                                   height: 0)
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 2
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.addSubview(titleLabel!)

        descriptionLabel.frame = CGRect(x: EmptyDataViewMargin * 2,
                                        y: 0,
                                        width: kCommonDeviceWidth - EmptyDataViewMargin * 4,
                                        height: 0)
        
        descriptionLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel?.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(descriptionLabel)
        config?.titleTextColor = UIColor.colorWithHex(0x595959)
        config?.bodyColor = UIColor.colorWithHex(0x797979)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func adjustEmptyView() {
        
        emptyDataImageView.image = self.delegate?.placeHolderImageOnEmptyView(self)
        emptyDataImageView.sizeToFit()
        emptyDataImageView.center.x = self.center.x
        
        titleLabel?.text = self.delegate?.titleOnEmptyView(self)
        titleLabel?.textColor = config!.titleTextColor!
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel?.height = titleLabel!.text!.getTextHeight(titleLabel!.font, viewWidth: titleLabel!.width)
        titleLabel?.y = emptyDataImageView.bottom + (UIScreen.is3_5inchDisplay() ? EmptyDataViewMargin / 2 : EmptyDataViewMargin)
        
        descriptionLabel.text = self.delegate?.bodyOnEmptyView(self)
        descriptionLabel?.textColor = config!.bodyColor!
        descriptionLabel.height = descriptionLabel.text!.getTextHeight(descriptionLabel!.font, viewWidth: descriptionLabel.width)
        descriptionLabel.y = titleLabel!.bottom + 7.0
        self.viewSize = CGSize(width: kCommonDeviceWidth, height: descriptionLabel.bottom)
        self.center.y = self.delegate!.emptyViewCenterPositionY()
    }
    
    open func adjustEmptyViewWithAnimated(_ animationInfo: [AnyHashable: Any]) {
        let duration: Float = (animationInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        let animationCurve: UInt = (animationInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue
        UIView.animate(withDuration:TimeInterval(duration),
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.init(rawValue: animationCurve),
                                   animations: {
                                    self.adjustEmptyView()
            }, completion: nil)
    }
    
    open func showWithText(_ text: String, dismissAfter: Double, onViewController: UIViewController) {
        label.text = text
        let viewControllerRect: CGRect = onViewController.view.bounds
        self.y = viewControllerRect.height
        self.alpha = 0.0
        onViewController.view.addSubview(self)
        
        UIView.animate(withDuration:0.25, animations: {
            self.alpha = 1.0
            self.y = viewControllerRect.height - self.height
            
        }) { (finished) in
             DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(dismissAfter * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                UIView.animate(withDuration:0.25, animations: {
                    self.y = viewControllerRect.height
                    }, completion: { (finished) in
                        self.alpha = 0.0
                        self.removeFromSuperview()
                })
            })
        }
    }
}
