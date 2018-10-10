//
//  CollectionLoadMoreView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/27.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


private let viewHeight: CGFloat = 25.0

open class CollectionLoadMoreView: UICollectionReusableView {
    
    fileprivate var indicatorView: UIActivityIndicatorView?
    
    required public override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: viewHeight))
        self.defaultSetUp()
    }
    
    convenience public init () {
        self.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: viewHeight))
        self.defaultSetUp()
    }
    
    func defaultSetUp() {
        
        self.backgroundColor = UIColor.clear
        
        indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        indicatorView?.color = UIColor.colorWithHex(0xaaaaaa)
        indicatorView?.x = (kCommonDeviceWidth - indicatorView!.width) / 2
        indicatorView?.y = (type(of: self).size().height - indicatorView!.height) / 2
        self.addSubview(indicatorView!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func size() ->CGSize {
        return CGSize(width: kCommonDeviceWidth, height: viewHeight)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        indicatorView?.x = (kCommonDeviceWidth - indicatorView!.width) / 2
        indicatorView?.y = (type(of: self).size().height - indicatorView!.height) / 2
    }
    
    func startLoading() {
        indicatorView?.startAnimating()
    }
    
    func stopLoading() {
        indicatorView?.stopAnimating()
    }
}
