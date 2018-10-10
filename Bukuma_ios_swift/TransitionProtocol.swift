//
//  TransitionProtocol.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import UIKit

@objc protocol TransitionProtocol{
    func transitionCollectionView() -> UICollectionView!
}

@objc protocol TansitionWaterfallGridViewProtocol {
    func snapShotForTransition() -> UIView!
}

@objc protocol WaterFallViewControllerProtocol : TransitionProtocol {
    func viewWillAppearWithPageIndex(_ pageIndex : NSInteger)
}

@objc protocol HorizontalPageViewControllerProtocol : TransitionProtocol {
    func pageViewCellScrollViewContentOffset() -> CGPoint
}
