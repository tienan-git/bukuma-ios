//
//  Transition.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import UIKit

let animationDuration = 0.35
let animationScale = kCommonDeviceWidth / HomeCollectionGridWidth

class Transition : NSObject , UIViewControllerAnimatedTransitioning {
    var presenting = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as UIViewController!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as UIViewController!
        let containerView = transitionContext.containerView
        
        if presenting {
            let toView = toViewController?.view!
            containerView.addSubview(toView!)
            toView?.isHidden = true
            
            let waterFallView = (toViewController as! TransitionProtocol).transitionCollectionView()
            let pageView = (fromViewController as! TransitionProtocol).transitionCollectionView()
            waterFallView?.layoutIfNeeded()
            let indexPath = pageView?.fromPageIndexPath()
            let gridView = waterFallView?.cellForItem(at: indexPath!)
            let leftUpperPoint = gridView!.convert(CGPoint.zero, to: toViewController?.view)
            
            let snapShot = (gridView as! TansitionWaterfallGridViewProtocol).snapShotForTransition()
            snapShot?.transform = CGAffineTransform(scaleX: animationScale, y: animationScale)
            let pullOffsetY = (fromViewController as! HorizontalPageViewControllerProtocol).pageViewCellScrollViewContentOffset().y
            let offsetY : CGFloat = fromViewController!.navigationController!.isNavigationBarHidden ? 0.0 : NavigationHeightCalculator.navigationHeight()
            snapShot?.viewOrigin = CGPoint(x: 0, y: -pullOffsetY+offsetY)
            containerView.addSubview(snapShot!)
            
            toView?.isHidden = false
            toView?.alpha = 0
            toView?.transform = (snapShot?.transform)!
            toView?.frame = CGRect(x: -(leftUpperPoint.x * animationScale),y: -((leftUpperPoint.y-offsetY) * animationScale+pullOffsetY+offsetY),
                                   width: toView!.frame.size.width, height: toView!.frame.size.height)
            let whiteViewContainer = UIView(frame: UIScreen.main.bounds)
            whiteViewContainer.backgroundColor = UIColor.white
            containerView.addSubview(snapShot!)
            containerView.insertSubview(whiteViewContainer, belowSubview: toView!)
            
            UIView.animate(withDuration: animationDuration, animations: {
                snapShot?.transform = CGAffineTransform.identity
                snapShot?.frame = CGRect(x: leftUpperPoint.x, y: leftUpperPoint.y, width: (snapShot?.frame.size.width)!, height: (snapShot?.frame.size.height)!)
                toView?.transform = CGAffineTransform.identity
                toView?.frame = CGRect(x: 0, y: 0, width: (toView?.frame.size.width)!, height: (toView?.frame.size.height)!);
                toView?.alpha = 1
            }, completion:{finished in
                if finished {
                    snapShot?.removeFromSuperview()
                    whiteViewContainer.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            })
        }else{
            let fromView = fromViewController?.view
            let toView = toViewController?.view
            
            let waterFallView : UICollectionView = (fromViewController as! TransitionProtocol).transitionCollectionView()
            let pageView : UICollectionView = (toViewController as! TransitionProtocol).transitionCollectionView()
            
            containerView.addSubview(fromView!)
            containerView.addSubview(toView!)
            
            let indexPath = waterFallView.toIndexPath()
            let gridView = waterFallView.cellForItem(at: indexPath as IndexPath)
            
            let leftUpperPoint = gridView!.convert(CGPoint.zero, to: nil)
            pageView.isHidden = true
            pageView.scrollToItem(at: indexPath as IndexPath, at:.centeredHorizontally, animated: false)
            
            let offsetY : CGFloat = fromViewController!.navigationController!.isNavigationBarHidden ? 0.0 : NavigationHeightCalculator.navigationHeight()
            let offsetStatuBar : CGFloat = fromViewController!.navigationController!.isNavigationBarHidden ? 0.0 :
            kCommonStatusBarHeight;
            let snapShot = (gridView as! TansitionWaterfallGridViewProtocol).snapShotForTransition()
            containerView.addSubview(snapShot!)
            snapShot?.viewOrigin = leftUpperPoint
            UIView.animate(withDuration: animationDuration, animations: {
                snapShot?.transform = CGAffineTransform(scaleX: animationScale,
                                                        y: animationScale)
                snapShot?.frame = CGRect(x: 0, y: offsetY, width: (snapShot?.frame.size.width)!, height: (snapShot?.frame.size.height)!)
                
                fromView?.alpha = 0
                fromView?.transform = (snapShot?.transform)!
                fromView?.frame = CGRect(x: -(leftUpperPoint.x)*animationScale,
                                         y: -(leftUpperPoint.y-offsetStatuBar)*animationScale+offsetStatuBar,
                                         width: fromView!.frame.size.width,
                                         height: fromView!.frame.size.height)
            },completion:{finished in
                if finished {
                    snapShot?.removeFromSuperview()
                    pageView.isHidden = false
                    fromView?.transform = CGAffineTransform.identity
                    transitionContext.completeTransition(true)
                }
            })
        }
    }
}
