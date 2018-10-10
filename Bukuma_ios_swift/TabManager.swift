//
//  BKMTabManager.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/11.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import RDVTabBarController

/**
 このClassではTabの管理をしています
 RDVTabBarControllerというライブラリを使っています
 
 */

open class TabManager: NSObject {
    
    fileprivate var badgeCounts: [Int: Int]?
    open var tabBarController: TabBarViewController?
    open var homeViewController: HomeViewController?
    
    open class var sharedManager: TabManager {
        struct Static {
            static let instance = TabManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        badgeCounts = [0:0, 1:0, 2:0, 3:0, 4:0]
        homeViewController = HomeViewController()
        
        let searchViewController: SearchMerchandiseViewController = SearchMerchandiseViewController()
        
        let dummyViewController = UIViewController()
        
        let chatListViewController: ChatListViewController = ChatListViewController.init()

        let userPageViewController: UserPageViewController = UserPageViewController(user: nil)
        
        self.tabBarController = TabBarViewController.init()
        self.tabBarController!.viewControllers = [homeViewController!,searchViewController,dummyViewController,chatListViewController,userPageViewController]
        
        self._customizeTabBarForController(self.tabBarController!)
    }
    
    func _customizeTabBarForController(_ tabBarController: TabBarViewController) {
        let tabBarItemImages: Array<String> = ["tab_01","tab_02","dummiy","tab_04","tab_05"]
        
        for i in 0 ..< tabBarController.tabBar.items.count {
            let item: RDVTabBarItem = tabBarController.tabBar.items[i] 
            item.backgroundColor = UIColor.white
            item.badgeBackgroundColor = kTintGreenColor
            // Magic numbers
            //            item.titlePositionAdjustment = UIOffsetMake(0, -10.0)
            
            item.imagePositionAdjustment = UIOffsetMake(0,0)
            item.badgePositionAdjustment = UIOffsetMake(-25.0, 1.0)
        
            item.selectedTitleAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 10),NSForegroundColorAttributeName: UIColor.white]
            item.unselectedTitleAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 10),NSForegroundColorAttributeName: UIColor.white]
            
            let isSelectedImage: UIImage! = UIImage(named: "\(tabBarItemImages[i])" + "_active")
            let unisSelectedImage: UIImage! = UIImage(named: "\(tabBarItemImages[i])" + "_normal")
            
            let image: UIImage = UIImage(named: "tab_bg")!
            
            item.setBackgroundSelectedImage(image, withUnselectedImage: image)
            
            item.setFinishedSelectedImage(isSelectedImage, withFinishedUnselectedImage: unisSelectedImage)
        }
    }
    
    open func activeNavigationController() ->NavigationController {
        return tabBarController!.selectedViewController as! NavigationController
    }
    
    open func activityBadgeCountForTabIndex(_ tabIndex: Int) ->Int {
        return badgeCounts![tabIndex]!
    }
    
    open func setActivityBadgeCount(_ activityBadgeCount: Int, tabIndex: Int){
        badgeCounts![tabIndex] = activityBadgeCount
        
        let activityItem: RDVTabBarItem = tabBarController!.tabBar.items[tabIndex] 
        
        if activityBadgeCount > 9{
            activityItem.badgeValue = "＋"
        } else {
            
            activityItem.badgeValue =  (activityBadgeCount == 0 || activityBadgeCount < 0) ? "" : badgeCounts![tabIndex]?.string()
        }
    }
    
    //========================================================================
    // MARK: - property setter getter

    open var isTabBarHidden: Bool? {
        get{
           return tabBarController!.isTabBarHidden
        }
        
        set (newValue){
            tabBarController?.setTabBarHidden(newValue!, animated: true)
        }
    }
}

