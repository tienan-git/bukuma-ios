//
//  BKMNavigationController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit

open class NavigationController: UINavigationController {
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
       return .lightContent
    }
}

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        
        let fromVCConfromA = (fromVC as? TransitionProtocol)
        let fromVCConfromB = (fromVC as? WaterFallViewControllerProtocol)
        
        let toVCConfromA = (toVC as? TransitionProtocol)
        if((fromVCConfromA != nil)&&(toVCConfromA != nil)&&(
            (fromVCConfromB != nil))){
            let transition = Transition()
            transition.presenting = operation == .pop
            return  transition
        }else{
            return nil
        }
    }
}

