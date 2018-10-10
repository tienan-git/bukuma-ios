//
//  BKMBaseViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Crashlytics
import SVProgressHUD
import RMUniversalAlert

/*
 全てのViewControllerはBaseViewControllerを継承して作られている
 
    <property説明>
       - isActiveViewController: Bool(今表示中のViewControllerかどうか)
       - navigationBarView: NavigationBarView(navigationBarの緑のview、このprojectではNaviBarの基本の色は透明にして、その上にCostomViewを乗せている)
       - buttonController: UIViewController(操作すべきNavigationBarItemを持っているViewControllerである。このprojectはKYDrawerControllerがrootViewControllerになっていて、drawerViewControllerがTabViewControllerを持っていて、それがViewControllerたちを持っているという少し複雑な階層になっているため、self.navigationItemでアクセスできないことがあった)
       -statusBarHidden: statusBarをhiddenするかどうか.継承先でこのpropertyを変更することで変えられるように
       -thanksDownloadView: ダウンロードありがとうView。登録を促す。
       - isModal: Modalかどうか
       - isNeedKeyboardNotification: キーボードのNotificationを受け取るかどうか(keybordを使うViewControllerが多かったので)
       - shouldShowRightNavigationButton: 右のnaviBar buttonを表示させるかどうか
       - shouldShowLeftNavigationButton: 左のnaviBar buttonを表示させるかどうか
    <medhod説明>
        -initializeNavigationLayout() : navigationBarに対する設定を継承先でかく
 　　　　 -setNavigationBarButton(): navigationBarにbuttonをセットするときのメソッド
        - navigationbarBackButtonIcon(): navigationBarに乗せるbackするときのアイコン。特定の継承先で変えたければ、ここを変える
 　　　　- navigationbarCancelButtonIcon() :navigationBarに乗せるcancelするときのアイコン。特定の継承先で変えたければ、ここを変える
        - showPermitNotification : 通知許可しますかのアラート
        - homeThanksDownloadViewFacebookButtonTapped: Facebookで登録を押したときの登録もしくわログイン処理。まずこのfacebookが登録されているかserverに問い合わせて、存在しなかったら、登録、あったらログイン
        - homeThanksDownloadViewEmailButtonTapped: Email登録、ログイン処理
 
 */

open class BaseViewController:UIViewController,
UINavigationControllerDelegate,
UIScrollViewDelegate,
HomeThanksDownloadViewDelegate {

    var isActiveViewController : Bool!
    open var navigationBarView : NavigationBarView?
    var buttonController: UIViewController?
    var statusBarHidden: Bool = false
    var thanksDownloadView: HomeThanksDownloadView?
    
    //========================================================================
    // MARK: - deinit
    deinit {
        DBLog("-----------deinit BaseViewController --------")
        NotificationCenter.default.removeObserver(self)
        //_ = self.view.subviews.flatMap{self._releaseView($0)}
        
        navigationBarView = nil
    }
    
    fileprivate func _releaseView(_ view: UIView) {
        for v in view.subviews {
            if v is UIImageView {
                let imageView = v as? UIImageView
                imageView?.image = nil
            }
            if v is UIButton {
                let button = v as? UIButton
                button?.imageView?.image = nil
            }
        }
    }
    
    //========================================================================
    // MARK: - setting
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override open var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    open func initializeNavigationLayout() {}
    
    func controllers() -> Array<UIViewController>? {
        return self.navigationController?.viewControllers
    }
    
    //NabigationBarにButtonをsetする時はこれ統一で！
    func setNavigationBarButton(_ barButton: UIBarButtonItem?, isLeft: Bool) {
        
        var buttonController: UIViewController = kAppDelegate.drawerViewController.mainViewController
        
        if buttonController is UINavigationController {
            let nav = buttonController as! UINavigationController
            if nav.viewControllers.count > 0 {
                buttonController = nav.viewControllers[0]
            }
            
            if isLeft == false {
                if self.isModal == true {
                    self.navigationItem.rightBarButtonItem = nil
                    self.navigationItem.rightBarButtonItem = barButton
                }else {
                    buttonController.navigationItem.rightBarButtonItem = nil
                    buttonController.navigationItem.rightBarButtonItem = barButton
                }
            } else {
                if self.isModal == true {
                    self.navigationItem.leftBarButtonItem = nil
                    self.navigationItem.leftBarButtonItem = barButton
                } else {
                    buttonController.navigationItem.leftBarButtonItem = nil
                    if barButton == nil {
                        buttonController.navigationItem.leftBarButtonItem = kAppDelegate.drawerViewController.leftButtonForCenterViewController()
                    } else {
                        buttonController.navigationItem.leftBarButtonItem = barButton
                    }
                }
            }
        }
        
        //pushで行った時
        if controllers() != nil {
            if self.controllers()!.count >= 2 {
                if isLeft == true {
                    self.navigationItem.leftBarButtonItem = barButton
                } else {
                    self.navigationItem.rightBarButtonItem = barButton
                }
            }
        }
        
        self.buttonController = buttonController
    }
    
    func navigationbarBackButtonIcon() ->UIImage {
        return UIImage(named: "ic_nav_back")!
    }
    
    func navigationbarCancelButtonIcon() -> UIImage {
        return UIImage(named: "navigation_ic_cancel_normal")!
    }
    
    //========================================================================
    // MARK: - viewCycle
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.autoresizesSubviews = false
        self.view.clipsToBounds = false
        self.view.backgroundColor = kBackGroundColor
        self.automaticallyAdjustsScrollViewInsets = false
        
        navigationBarView = NavigationBarView()
        navigationBarView!.frame.origin.x = -kCommonDeviceWidth / 2
        navigationBarView!.backgroundColor = kMainGreenColor
        
        self.view.addSubview(navigationBarView!)
        
        thanksDownloadView = HomeThanksDownloadView(delegate: self,
                                                    image: UIImage(named: "img_cover_after_purchase")!,
                                                    title: "",
                                                    detail: "",
                                                    buttonText: "会員登録する")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPermitNotification), name: NSNotification.Name(rawValue: MeFirstRegisterkey), object: nil)

    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isActiveViewController = true
                
        if shouldShowLeftNavigationButton == false {
            self.setNavigationBarButton(nil, isLeft: true)
        }
        
        if shouldShowRightNavigationButton == false {
            self.setNavigationBarButton(nil, isLeft: false)
        }
        
        self.navigationBarTitle = nil
        self.initializeNavigationLayout()
        
        kDrawerViewController?.screenEdgePanGestreEnabled = true
        let controllers: Array<UIViewController>? = self.navigationController?.viewControllers
        if controllers != nil {
            if controllers!.count >= 2 {
                kDrawerViewController?.screenEdgePanGestreEnabled = false
                let backButton: BarButtonItem = BarButtonItem.backButton(navigationbarBackButtonIcon(), target: self, action: #selector(BaseViewController.back(_:)))
                self.navigationItem.leftBarButtonItem = backButton
            }
            
            if isModal == true && controllers!.count < 2 {
                let cancelButton: BarButtonItem = BarButtonItem.barButtonItemWithImage(navigationbarCancelButtonIcon(), isLeft: true, target: self, action: #selector(BaseViewController.cancel(_:)))
                self.navigationItem.leftBarButtonItem = cancelButton
            }
        }
        
        AnaliticsManager.sendScreenName(NSStringFromClass(type(of: self)))
        
    }
    
    func back(_ sender: UIBarButtonItem) {
       self.popViewController()
    }
    
    func cancel(_ sender: UIBarButtonItem) {
        self.dismiss()
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func popViewController() {
       _ = self.navigationController?.popViewController(animated: true)
    }
    
    func showPermitNotification() {
        RemoteNotification.registerForRemoteNotification()
    }
    
    open func scrollToTop() {}
    
    func showPointAl() {
        if Me.sharedMe.isRegisterd == false {
            DispatchQueue.main.async(execute: {
                let title: String =  "会員登録で\(ExternalServiceManager.initialPoint)ポイント贈呈中！"
                let detail: String = "新規ダウンロードキャンペーン中。アカウント登録で\(ExternalServiceManager.initialPoint)ポイントをプレゼントしています。"
                self.thanksDownloadView?.config(title, detail: detail)
                self.thanksDownloadView?.appearOnWindow()
                
            })
        }
    }
    
    // ================================================================================
    // MARK: - register alerat delegate
    
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
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppDelegateRefreshAfterLoginKey), object: nil)
                                    self?.simpleAlert(nil, message:  "ログインに成功しました", cancelTitle: "OK", completion: { 
                                        DispatchQueue.main.async {
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MeFirstRegisterkey), object: nil)
                                        }
                                    })
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
    
    open func baseSuggestViewCancelButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {}
    
    open func baseSuggestViewActionButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {}
    
    func showUnRegisterAlert() {
        kDrawerViewController?.screenEdgePanGestreEnabled = false
        let title: String =  "会員登録で\(ExternalServiceManager.initialPoint)ポイント贈呈中！"
        let detail: String = "新規ダウンロードキャンペーン中。アカウント登録で\(ExternalServiceManager.initialPoint)ポイントをプレゼントしています。"
        self.thanksDownloadView?.config(title, detail: detail)
        self.thanksDownloadView?.appearOnWindow()
    }
    
    func showUnVerifiedAlert() {
        _ = RMUniversalAlert.show(in: self,
                                  withTitle: nil,
                                  message: "電話番号を認証していません",
                                  cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: ["認証する"]) {[weak self] (al, index) in
                                    DispatchQueue.main.async(execute: {
                                        if index == al.firstOtherButtonIndex {
                                            let controller: RegisterPhoneNumberViewController = RegisterPhoneNumberViewController(type: .input)
                                            let navi: NavigationController = NavigationController(rootViewController: controller)
                                            self?.present(navi, animated: true, completion: nil)
                                        }
                                    })
        }
    }

    func simpleAlert(_ title: String?, message: String?, cancelTitle: String?, completion: (() ->Void)?) {
        SVProgressHUD.dismiss()
        _ = RMUniversalAlert.show(in: self,
                                  withTitle: title,
                                  message: message,
                                  cancelButtonTitle: cancelTitle,
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: nil) { (al, index) in
                                    DispatchQueue.main.async(execute: {
                                        if completion != nil {
                                            completion!()
                                        }
                                    })
        }
    }

    //========================================================================
    // MARK: - property setter getter

    var isModal: Bool! {
        get {
            return (self.presentingViewController != nil && self.presentingViewController!.presentedViewController == self) ||
                (self.navigationController != nil && self.navigationController!.presentingViewController != nil &&
                    self.navigationController!.presentingViewController!.presentedViewController == self.navigationController)
        }
    }

    final public var isNeedKeyboardNotification : Bool!{
        didSet {
            if isNeedKeyboardNotification == true {
                NotificationCenter.default.addObserver(self,selector:#selector(BaseViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                NotificationCenter.default.addObserver(self,selector:#selector(BaseViewController.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
                
            }else{
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
                
            }
        }
    }
    
    var shouldShowRightNavigationButton: Bool {
        get {
           return false
        }
    }
    
    var shouldShowLeftNavigationButton: Bool {
        get {
            return true
        }
    }
    
    var navigationBarTitle: String? {
        get {
            guard let controllers = self.controllers() else {
                return nil
            }
            if controllers.count >= 2 || self.isModal == true {
                return self.title
            } else {
                return kRootViewControllerController.navigationItem.title
            }
        } 
        
        set(newValue) {
            guard let controllers = self.controllers() else {
                return
            }

             if controllers.count >= 2 || self.isModal == true {
                self.title = newValue                
            } else {
                kRootViewControllerController.navigationItem.title = newValue
            }
        }
    }

    func keyboardDidShow(_ notification: Foundation.Notification) -> Void{}
    
    func keyboardDidHide(_ notification: Foundation.Notification) -> Void{}
    
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func convertOldGender() {
        if Me.sharedMe.isRegisterd == true  && Me.sharedMe.isOldGender() == true {
            let user: User = User()
            user.gender = Gender.other.int()
            Me.sharedMe.updateUserInfo(user) { (error) in }
        }
    }
}
