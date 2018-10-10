//
//  MaintenanceManager.swift
//  Bukuma_ios_swift
//
//  Created by tani on 2017/06/14.
//  Copyright © 2017年 Labit Inc. All rights reserved.
//

import SVProgressHUD

class MaintenanceManager {
    
    class var shared : MaintenanceManager {
        
        struct Static {
            static let instance = MaintenanceManager()
        }
        
        return Static.instance
    }
    
    var isMaintenance = false
    var isLegacyMaintenance = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) {
        NotificationCenter.default.addObserver(self, selector: #selector(startMaintenance), name: NSNotification.Name(rawValue: ErrorMaintenanceNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMaintenanceInfo(sender:)), name: NSNotification.Name(rawValue: MaintenanceViewJumpToNewsControllerNotification), object: nil)
    }
    
    @objc func startMaintenance() {
        isMaintenance = true
        showMaintenanceView()
    }
    
    func finishMaintenance() {
        isMaintenance = false
        if isLegacyMaintenance {
            return
        }
        Category.fetchCategoriesIfNeed()
        Tab.fetchTabsIfNeed()
        hideMaintenanceView()
    }
    
    func startLegacyMaintenance() {
        isLegacyMaintenance = true
        showMaintenanceView()
    }
    
    func finishLegacyMaintenance() {
        isLegacyMaintenance = false
        if isMaintenance {
            return
        }
        hideMaintenanceView()
    }
    
    private var isAppearTabs: Bool {
        return TabManager.sharedManager.homeViewController?.homePagerViewController != nil
    }
    
    private func showMaintenanceView() {
        SVProgressHUD.dismiss()
        MaintenanceView.shared.appear(to: kAppDelegate.drawerViewController.view)
    }
    
    private func hideMaintenanceView() {
        MaintenanceView.shared.disappear(nil)
    }
    
    @objc private func showMaintenanceInfo(sender: Foundation.Notification) {
        guard let url = sender.object as? URL,
              let rootViewController = kAppDelegate.window?.rootViewController else {
            return
        }
        
        let contoller = BaseWebViewController(url: url)
        let navi = NavigationController(rootViewController: contoller)
        rootViewController.present(navi, animated: true, completion: nil)
    }
    
    
}
