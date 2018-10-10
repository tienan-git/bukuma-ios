//
//  BKMTabBarViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/11.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import RDVTabBarController
import SVProgressHUD
import RMUniversalAlert

open class TabBarViewController: RDVTabBarController, HomeThanksDownloadViewDelegate {
   
    var centerButton: UIButton! = UIButton()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // false にしておかないと、child view controller の表示消去時に中に含まれる UIScrollView 由来の view.contentInset.top が
        // 64 pixel 自動調整されてしまい表示がズレてしまう
        self.automaticallyAdjustsScrollViewInsets = false

        let buttonImage: UIImage = UIImage(named: "tab_03_normal")!
        let buttonisSelectedImage: UIImage = UIImage(named: "tab_03_active")!
        
        centerButton.frame = CGRect(x: (kCommonDeviceWidth - buttonImage.size.width) / 2,
                                    y: kCommonDeviceHeight - buttonImage.size.height,
                                    width: buttonImage.size.width,
                                    height: buttonImage.size.height)
        if NavigationHeightCalculator.isTethering() {
            centerButton.y = kCommonDeviceHeight - buttonImage.size.height - 20.0
        }
        centerButton.setImage(buttonImage, for: .normal)
        centerButton.setImage(buttonisSelectedImage, for: .selected)
        centerButton.setImage(buttonisSelectedImage, for: .highlighted)
        centerButton.adjustsImageWhenHighlighted = false
        centerButton.addTarget(self, action: #selector(self.centerButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(centerButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCenterFrame), name: Foundation.NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCenterFrame()
    }
    
    func updateCenterFrame() {
        let buttonImage: UIImage = UIImage(named: "tab_03_normal")!
        DBLog(UIApplication.shared.statusBarFrame.size.height)
        
        if NavigationHeightCalculator.isTethering() {
            centerButton.y = kCommonDeviceHeight - buttonImage.size.height - 20.0
        } else {
            centerButton.y = kCommonDeviceHeight - buttonImage.size.height
        }
    }
    
    func centerButtonTapped(_ sender: UIButton) {
        if Me.sharedMe.isRegisterd == false {
            let registerView: HomeThanksDownloadView = HomeThanksDownloadView(delegate: self,
                                                                              image: UIImage(named: "img_cover_after_purchase")!,
                                                                              title: "",
                                                                              detail: "",
                                                                              buttonText: "会員登録する")
            let title: String =  "会員登録で\(ExternalServiceManager.initialPoint)ポイント贈呈中！"
            let detail: String = "新規ダウンロードキャンペーン中。アカウント登録で\(ExternalServiceManager.initialPoint)ポイントをプレゼントしています。"
            registerView.config(title, detail: detail)
            registerView.appearOnViewController(self.navigationController ?? self)
            return
        }
        let barcodeViewController: BarcodeScannerViewController = BarcodeScannerViewController.init()
        let navi: NavigationController = NavigationController.init(rootViewController: barcodeViewController)
        self.present(navi, animated: true, completion: nil)
    }
    
    open override func tabBar(_ tabBar: RDVTabBar!, didSelectItemAt index: Int) {
        if Me.sharedMe.isRegisterd == false && (index == 4 || index == 3) {
            self.selectedIndex = 0
            let registerView: HomeThanksDownloadView = HomeThanksDownloadView(delegate: self,
                                                                              image: UIImage(named: "img_cover_after_purchase")!,
                                                                              title: "",
                                                                              detail: "",
                                                                              buttonText: "会員登録する")
            let title: String =  "会員登録で\(ExternalServiceManager.initialPoint)ポイント贈呈中！"
            let detail: String = "新規ダウンロードキャンペーン中。アカウント登録で\(ExternalServiceManager.initialPoint)ポイントをプレゼントしています。"
            registerView.config(title, detail: detail)
            registerView.appearOnViewController(self.navigationController ?? self)
            return
        }
        super.tabBar(tabBar, didSelectItemAt: index)
    }
    
    override open func tabBar(_ tabBar: RDVTabBar!, shouldSelectItemAt index: Int) -> Bool {
        
//        if self.selectedViewController!.isKindOfClass(BaseViewController) {
//            let vc: BaseViewController = self.selectedViewController as! BaseViewController
//            if vc.navigationController!.viewControllers.count == 1 && Int(self.selectedIndex) == index{
//                vc.scrollToTop()
//                return false
//            }
//        }
        return true
    }
    
    open func homeThanksDownloadViewFacebookButtonTapped(_ view: HomeThanksDownloadView, type: HomeThanksDownloadViewAlertType, completion:(() ->Void)?) {
        kDrawerViewController?.screenEdgePanGestreEnabled = true
        let user: User = User()
        FacebookManager.sharedManager.loginFacebook(self) { (error) in
            if error != nil {
                self.simpleAlert(nil, message: "ログイン失敗しました。もう一度お試し下さい", cancelTitle: "OK", completion: nil)
                return
            }
            
            self.view.isUserInteractionEnabled = false
            
            FacebookManager.sharedManager.getFacebookUser({ [weak self] (facebok, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.view.isUserInteractionEnabled = true
                        self?.simpleAlert(nil, message: "不明なエラーです", cancelTitle: "OK", completion: nil)
                        return
                    }
                    
                    FacebookManager.sharedManager.checkSnsAlreadyExsistence(facebok!.id!, completion: { (exsistence, error) in
                        user.facebook = facebok
                        if exsistence == false {
                            //register
                            FacebookManager.sharedManager.getFacebookLargeImage({ (facebook, error) in
                                DispatchQueue.main.async {
                                    if error != nil {
                                        self?.view.isUserInteractionEnabled = true
                                        self?.simpleAlert(nil, message: "不明なエラーです", cancelTitle: "OK", completion: nil)
                                        return
                                    }
                                    self?.view.isUserInteractionEnabled = true
                                    user.facebook?.picture = facebook?.picture
                                    let controller: FacebookLoginViewController = FacebookLoginViewController(user: user)
                                    controller.view.clipsToBounds = true
                                    self?.navigationController?.pushViewController(controller, animated: true)
                                }
                            })
                        } else {
                            //login
                            SVProgressHUD.show()
                            Me.sharedMe.singInWithSNSAccount {[weak self] (error) in
                                DispatchQueue.main.async {
                                    self?.view.isUserInteractionEnabled = true
                                    if error != nil {
                                        self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                                        return
                                    }
                                    SVProgressHUD.dismiss()
                                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: AppDelegateRefreshAfterLoginKey), object: nil)
                                    RMUniversalAlert.show(in: self!,
                                                          withTitle: nil,
                                                          message: "ログインに成功しました",
                                                          cancelButtonTitle: "OK",
                                                          destructiveButtonTitle: nil,
                                                          otherButtonTitles: nil) { (al, index) in
                                                            DispatchQueue.main.async {
                                                                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MeFirstRegisterkey), object: nil)
                                                            }
                                    }
                                }
                            }
                        }
                    })
                }
                })
        }
    }
    
    open func homeThanksDownloadViewEmailButtonTapped(_ view: HomeThanksDownloadView, type: HomeThanksDownloadViewAlertType, completion:(() ->Void)?) {
        kDrawerViewController?.screenEdgePanGestreEnabled = true
        if view.type == .register {
            let controller: EmailLoginViewController = EmailLoginViewController(type: .register)
            let navi: NavigationController = NavigationController(rootViewController: controller)
            self.present(navi, animated: true, completion: nil)
            return
        }
        
        let controller: EmailLoginViewController = EmailLoginViewController(type: .login)
        let navi: NavigationController = NavigationController(rootViewController: controller)
        self.present(navi, animated: true, completion: nil)
    }
    
    open func baseSuggestViewCancelButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {
        
    }
    
    open func baseSuggestViewActionButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {
        
    }
    
    func simpleAlert(_ title: String?, message: String?, cancelTitle: String?, completion: (() ->Void)?) {
        SVProgressHUD.dismiss()
        RMUniversalAlert.show(in: self,
                              withTitle: title,
                              message: message,
                              cancelButtonTitle: cancelTitle,
                              destructiveButtonTitle: nil,
                              otherButtonTitles: nil) { (al, index) in
                                DispatchQueue.main.async {
                                    if completion != nil {
                                        completion!()
                                    }
                                }
        }
    }

}
