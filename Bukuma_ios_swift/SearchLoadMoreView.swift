//
//  LoadMoreView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/26.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public protocol SearchLoadMoreViewLoadMoreViewDelegate {
    func LoadMoreViewLoadMoreButtonTapped(_ view: SearchLoadMoreView, completion: (() ->Void)?)
}

let SearchLoadMoreViewDidTappedNotification: String = "SearchLoadMoreViewDidTappedNotification"
private let loadMoreButtonMargin: CGFloat = 50.0
private let viewHeight: CGFloat = 60.0
private let loadMoreButtonSize: CGSize = CGSize(width: kCommonDeviceWidth - loadMoreButtonMargin * 2, height: viewHeight)

public class SearchLoadMoreView: UICollectionReusableView {
    
    var delegate: SearchLoadMoreViewLoadMoreViewDelegate?
    fileprivate var loadMoreButton: UIButton?
    fileprivate var indicatorView: UIActivityIndicatorView?
    
    required override public init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: viewHeight))
        self.defaultSetUp()
    }
    
    convenience init () {
        self.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: viewHeight))
        self.defaultSetUp()
    }
    
    required public init(delegate: SearchLoadMoreViewLoadMoreViewDelegate) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: viewHeight))
        
        self.delegate = delegate
        
        self.defaultSetUp()
    }
    
    func defaultSetUp() {
        
        self.isHidden = true
        
        loadMoreButton = UIButton()
        loadMoreButton?.viewOrigin = CGPoint(x: loadMoreButtonMargin, y: 20.0)
        loadMoreButton?.clipsToBounds = true
        loadMoreButton?.viewSize = CGSize(width: loadMoreButtonSize.width, height: UIImage(named: "img_stretch_btn")!.size.height)
        loadMoreButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        loadMoreButton?.setBackgroundImage(UIImage(named: "img_stretch_btn")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        loadMoreButton?.backgroundColor = kMainGreenColor
        loadMoreButton?.layer.cornerRadius = 3.0
        loadMoreButton?.setTitleColor(UIColor.white, for: .normal)
        loadMoreButton?.setTitle("もっと見る", for: .normal)
        loadMoreButton?.addTarget(self, action: #selector(self.loadMoreButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(loadMoreButton!)
        
        indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        indicatorView?.color = UIColor.colorWithHex(0xaaaaaa)
        indicatorView?.isHidden = true
        indicatorView?.x = (kCommonDeviceWidth - indicatorView!.width) / 2
        indicatorView?.y = (type(of: self).size().height - indicatorView!.width) / 2
        self.addSubview(indicatorView!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func size() ->CGSize {
        return CGSize(width: kCommonDeviceWidth, height: viewHeight)
    }
    
    func loadMoreButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: SearchLoadMoreViewDidTappedNotification), object: nil)
    }
    
    func startLoading() {
        loadMoreButton?.isHidden = true
        indicatorView?.isHidden = false
        indicatorView?.startAnimating()
        self.isUserInteractionEnabled = false
    }
    
    func stopLoading() {
        loadMoreButton?.isHidden = false
        self.isUserInteractionEnabled = true
        indicatorView?.isHidden = true
        indicatorView?.stopAnimating()
    }
}
