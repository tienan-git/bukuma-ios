//
//  UIViewController+Extension.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

extension UIViewController {
    var currentTopViewController: UIViewController? {
        if let viewController = self as? UINavigationController {
            return viewController.topViewController?.currentTopViewController
        }
        if let viewController = self as? UITabBarController {
            return viewController.selectedViewController?.currentTopViewController
        }
        if let viewController = self.presentedViewController {
            return viewController.currentTopViewController
        }
        return self
    }
}
