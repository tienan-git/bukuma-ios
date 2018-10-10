//
//  BKMDiscoverLoadMoreCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/09.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public let CollectionLoadMoreCellIdentifier = "CollectionLoadMoreCellIdentifier"

open class CollectionLoadMoreCell: UICollectionViewCell {
    
    var indicatorView: UIActivityIndicatorView?
    
    deinit {
        indicatorView = nil
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        indicatorView!.color = UIColor.colorWithHex(0xaaaaaa)
        indicatorView!.x = (kCommonDeviceWidth - (10 * 2) - indicatorView!.width) / 2
        //indicatorView!.isHidden = true
        //indicatorView?.startAnimating()
        self.contentView.addSubview(indicatorView!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        indicatorView?.x = (kCommonDeviceWidth - (10 * 2) - indicatorView!.width) / 2
    }
    
    open func startAnimationg() {
        indicatorView?.startAnimating()
    }
    
    open func stopAnimationg() {
        indicatorView?.stopAnimating()
    }
    
    open class func loadMoreCellSize() ->CGSize {
        return CGSize(width: kCommonDeviceWidth, height: 25.0)
    }
}
