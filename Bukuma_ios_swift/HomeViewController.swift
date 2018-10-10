//
//  HomeViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/14.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class HomeViewController: BaseViewController {
    
    var homePagerViewController: HomePagerViewController?
    
    func setTabs(_ tabs: [Tab]?, completion: () ->Void) {
        guard let tabs = tabs else { return }
        homePagerViewController = HomePagerViewController(tabs: tabs)
        self.addChildViewController(homePagerViewController!)
        self.view.addSubview(homePagerViewController!.view)
        homePagerViewController!.didMove(toParentViewController: self)
        completion()
    }
    
    override open func initializeNavigationLayout() {
        let logoView = UIImageView(image: UIImage(named: "logo_nav_white"))
        kRootViewControllerController.navigationItem.titleView = logoView
    }

    //========================================================================
    // MARK: - viewCycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPointAl), name: NSNotification.Name(rawValue: ServiceManagerInitialpointNotification), object: nil)
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         self.convertOldGender()
        
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        kRootViewControllerController.navigationItem.titleView = nil
    }

    override open func scrollToTop() {
        homePagerViewController?.scrollToTop()
    }
    
}
