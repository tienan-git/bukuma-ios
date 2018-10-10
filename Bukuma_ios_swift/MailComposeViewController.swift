//
//  MailComposeViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import MessageUI

open class MailComposeViewController: MFMailComposeViewController {
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        //create before init
        UINavigationBar.appearance().setBackgroundImage(nil, for: .default)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().shadowImage = UIImage.init()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barTintColor = kMainGreenColor
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if self.responds(to: #selector(self.setNeedsStatusBarAppearanceUpdate)) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        self.navigationBar.tintColor = UIColor.white
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         UINavigationBar.appearance().setBackgroundImage(UIImage(named: "navigationbar_clear_bg"), for: .default)
         UINavigationBar.appearance().tintColor = UIColor.clear
    }
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override open var prefersStatusBarHidden : Bool {
        return false
    }
    
}
