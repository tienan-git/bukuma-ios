//
//  HomeSearchViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2017/01/12.
//  Copyright © 2017年 Hiroshi Chiba. All rights reserved.
//

import Foundation

class HomeSearchViewController: HomeCollectionViewController {
    
    // ================================================================================
    // MARK: init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func pullToRefreshInsetTop() -> CGFloat {
        return  NavigationHeightCalculator.navigationHeight() + 50.0 + 30.0
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func updateFrame() {
        DispatchQueue.main.async {
            if NavigationHeightCalculator.isTethering() {
                self.collectionView?.contentInsetTop = NavigationHeightCalculator.navigationHeight() + 40.0 + 30.0
                self.collectionView?.changeScrollHeight(50.0, contentInsetTop: NavigationHeightCalculator.navigationHeight() + 40.0 + 30.0)
                self.collectionView?.contentInsetBottom = kCommonTabBarHeight + 40.0
                self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
                return
            }
            self.navigationBarView?.height = NavigationHeightCalculator.navigationHeight()
            self.collectionView?.contentInsetTop = self.pullToRefreshInsetTop()
            self.collectionView?.changeScrollHeight(50.0, contentInsetTop: self.pullToRefreshInsetTop())
            self.collectionView?.contentInsetBottom = kCommonTabBarHeight + 10.0
            self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
        }
    }
    
    //デザリングしながら、アプリを初回起動したとき
    override func updateFrameWhenDidLoad() {
        DispatchQueue.main.async {
            if NavigationHeightCalculator.isTethering() {
                self.navigationBarView?.height = NavigationHeightCalculator.navigationHeight() - 10.0
                self.collectionView?.contentInsetTop = NavigationHeightCalculator.navigationHeight()
                self.collectionView?.changeScrollHeight(50.0, contentInsetTop: NavigationHeightCalculator.navigationHeight())
                self.collectionView?.contentInsetBottom = kCommonTabBarHeight + 30.0
                self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
            }
        }
    }
}

