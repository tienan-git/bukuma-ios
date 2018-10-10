//
//  AppDelegate.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import FBSDKCoreKit
import SwiftyBeaver
import Siren
import Firebase
import FirebaseAnalytics
import FirebaseMessaging
import Crashlytics
import Timepiece
import LUKeychainAccess
import SVProgressHUD
import JDStatusBarNotification
import AppsFlyerLib
import SwiftTips
import UserNotifications

public let SBLog = SwiftyBeaver.self
let AppDelegateStatusBarTapped: String = "AppDelegateStatusBarTapped"
let AppDelegateRefreshAfterLoginKey: String = "AppDelegateRefreshAfterLoginKey"

//SwiftyBeaver
private let kSBAppId: String = "NxnnQx"
private let kSBAppSecretId: String = "hyxbmljzdL9yqr1qy2oL5hpbwqn7vfQp"
private let kSBAppEncryptionKey: String = "lxmvQnigntkmo2gqD8uYP1niwqb6mbaa"

private enum RemoteNotificationType: Int {
    case none
    case bookLike
    case bookUpdate
    case bookSale
    case transaction
    case message
    case news
    
    mutating func typeFromString(_ string: String) {
        switch string {
        case "book_like":
            self = .bookLike
            break
        case "message":
            self = .message
            break
        case "book_liked_selling_price":
            self = .bookUpdate
            break
        case "book.selling_price":
            self = .bookUpdate
            break
        case "merchandise_bought":
            self = .bookSale
            break
        case "item_transaction_update":
            self = .transaction
            break
        case "news":
            self = .news
        default:
            self = .none
            break
        }
    }
}

@UIApplicationMain
open class AppDelegate: UIResponder, UIApplicationDelegate,SirenDelegate {

    open var window: UIWindow?
    var tabBarController: TabBarViewController!
    var drawerViewController: KYDrawerController!
    fileprivate var remoteType: RemoteNotificationType = RemoteNotificationType.none
    
    static var shouldUpdateActivity: Bool = false
    static var shouldUpdateTransaction: Bool = false
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AnaliticsManager.initializeAnalytics()

        SBLog.addDestination(ConsoleDestination())
        SBLog.addDestination(FileDestination())
        SBLog.addDestination(SBPlatformDestination(appID: kSBAppId, appSecret: kSBAppSecretId, encryptionKey: kSBAppEncryptionKey))
        
        FIRApp.configure()
        
        window = UIWindow()
        window?.frame = UIScreen.main.bounds
        window?.backgroundColor = UIColor.white
        window?.tintColor = kMainGreenColor
        
        SVProgressHUD.show()

        self.registerForPushNotifications()
        
        self.tabBarController = TabManager.sharedManager.tabBarController
        
        Category.fetchCategoriesIfNeed()
        Tab.fetchTabsIfNeed()
    
        let attributes: NSDictionary! = [NSForegroundColorAttributeName: UIColor.white]
        
        UINavigationBar.appearance().titleTextAttributes = attributes as? [String : AnyObject]
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "navigationbar_clear_bg"), for: .default)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().shadowImage = UIImage.init()
        UINavigationBar.appearance().isTranslucent = true
        
        JDStatusBarNotification.setDefaultStyle { (style) -> JDStatusBarStyle! in
            style?.font = UIFont.systemFont(ofSize: 12)
            style?.textColor = UIColor.white
            style?.barColor = UIColor.black
            style?.animationType = .move
            return style
        }
        
        drawerViewController = KYDrawerController()
        let sideMenuController = SideMenuTableViewController()
        
        drawerViewController.mainViewController = NavigationController.init(rootViewController: tabBarController)
        drawerViewController.drawerViewController = NavigationController.init(rootViewController: sideMenuController)
        drawerViewController.drawerWidth = (kCommonDeviceWidth * 3) / 4
        
        self.window?.rootViewController = self.drawerViewController
        self.window?.makeKeyAndVisible()
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setForegroundColor(UIColor.black)
        SVProgressHUD.setRingThickness(4.0)
        
        RemoteNotification.registerForRemoteNotification()
        Me.sharedMe.sendDeviceInfo()
        
        if Me.sharedMe.isRegisterd == true {
            Me.sharedMe.syncronizeMyProfileWithCompletion({ (error) in
            })
            
            DispatchQueue.global(qos: .`default`).async {
                ChatRealtimeUpdater.sharedUpdater.startTracking()
                TransactionRealtimeUpdater.sharedUpdater.startTracking()
                ActivityRealtimeUpdater.sharedUpdater.startTracking()
            }
        
            AppsFlyerTracker.shared().customerUserID = Me.sharedMe.identifier ?? "-1"
            Crashlytics.sharedInstance().setUserIdentifier(Me.sharedMe.identifier)
            Crashlytics.sharedInstance().setUserName(Me.sharedMe.nickName)
            Crashlytics.sharedInstance().setUserEmail(Me.sharedMe.email?.currentEmail)
            Crashlytics.sharedInstance().setObjectValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"], forKey: "appversion")
            Crashlytics.sharedInstance().setObjectValue(UIDevice.current.modelName, forKey: "modelname")
            Crashlytics.sharedInstance().setObjectValue(UIDevice.current.systemVersion, forKey: "os")
        } else {
            ExternalServiceManager.syncExternalValues() { (error) in
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: ServiceManagerInitialpointNotification), object: nil)
            }
        }
        
        let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
        if notification != nil {
            self.actionForNotification(notification!)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.accountBanNotification(_:)), name: NSNotification.Name(rawValue: ErrorAccountBanNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshMeInfo(_:)), name: NSNotification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshAfterLogin), name: NSNotification.Name(rawValue: AppDelegateRefreshAfterLoginKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotificaiton(_:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showOfflineStatusBar(_:)), name: NSNotification.Name(rawValue: ErrorOfflineNotification), object: nil)
        
        FMDBManager.sharedManager.migrate()
        MaintenanceManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FBSDKApplicationDelegate.sharedInstance().application(application,
                                                              didFinishLaunchingWithOptions: launchOptions)
        
        ACTAutomatedUsageTracker.enableAutomatedUsageReporting(withConversionID: "967572505")
        ACTConversionReporter.report(withConversionID: "967572505", label: "5NH_CO_gmWsQmfivzQM", value: "400.00", isRepeatable: false)
        
        Siren.shared.appName = kAppName
        Siren.shared.alertType = .option
        Siren.shared.forceLanguageLocalization = .Japanese
        Siren.shared.checkVersion(checkType: .immediately)
        
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        AppsFlyerTracker.shared().continue(userActivity, restorationHandler: restorationHandler)
        return true
    }

    open func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this mxethod to pause the game.
    }

    open func applicationDidEnterBackground(_ application: UIApplication) {
        ChatRealtimeUpdater.sharedUpdater.endTracking()
        TransactionRealtimeUpdater.sharedUpdater.endTracking()
        ActivityRealtimeUpdater.sharedUpdater.endTracking()
    }

    open func applicationWillEnterForeground(_ application: UIApplication) {
        if Me.sharedMe.isRegisterd == true {
            DispatchQueue.global(qos: .`default`).async {
                ChatRealtimeUpdater.sharedUpdater.startTracking()
                TransactionRealtimeUpdater.sharedUpdater.startTracking()
                ActivityRealtimeUpdater.sharedUpdater.startTracking()
            }
        }
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
        AnaliticsManager.trackAppFlayerLaunch()
        application.applicationIconBadgeNumber = 0

        if Transaction.cachedItemTransaction() != nil {
            AppDelegate.shouldUpdateTransaction = true
        } else {
            AppDelegate.shouldUpdateTransaction = false
        }
        
        if Me.sharedMe.isRegisterd == true {
            Transaction.getItemTransactionList(15, page: 0) { (transactions, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        MaintenanceManager.shared.finishMaintenance()
                    }
                
                    if (transactions?.count ?? -1) > 0 {
                        AppDelegate.shouldUpdateTransaction = true
                    } else {
                        AppDelegate.shouldUpdateTransaction = false
                    }
                }
            }
        }
        
        self.refreshBanners()

        ExternalServiceManager.syncExternalValues() { (error) in
            DispatchQueue.main.async {
                if ExternalServiceManager.isMaintenance {
                    MaintenanceManager.shared.startLegacyMaintenance()
                } else {
                    MaintenanceManager.shared.finishLegacyMaintenance()
                }
            }
        }
    }
    
    func refreshBanners() {
        Banner.getBanners { (banners, error) in
            DispatchQueue.main.async(execute: {
                
                let homeController: HomeViewController? = self.tabBarController.viewControllers[0] as? HomeViewController
                
                if homeController == nil || homeController?.homePagerViewController == nil {
                    return
                }

                homeController!.homePagerViewController?.setBanners(banners)
                
                SVProgressHUD.dismiss()
            })
        }
    }
    
   open func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func refreshMeInfo(_ sender: Foundation.Notification) {
        Me.sharedMe.syncronizeMyProfileWithCompletion { (error) in
            
        }
    }
    
    func refreshAfterLogin() {
        DispatchQueue.global(qos: .`default`).async {
            //購入ページなど情報のキャッシュを使っているところが結構あるので、ログイン成功したらリフレッシュする
            //we use cache data in many places. for exsample when Purchase book use Credit card cache data. so, when sucsess login, resresh following data and save as cache
            Adress.getAdressList({ (adresses, error) in
                CreditCard.getCardInfo({ (cards, error) in
                    Bank.getBankAccountList({ (banks, error) in
                        ChatRoom.getRoomsList(nil, shouldRefresh: true, completion: { (latestPostUpdate, rooms, error) in
                            
                        })
                    })
                })
            })
        }
    }
    
    // for timeline
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first! as UITouch
        let location = touch.location(in: self.window)
        if UIApplication.shared.statusBarFrame.contains(location) {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: AppDelegateStatusBarTapped), object: nil)
        }
    }
    
    func tokenRefreshNotificaiton(_ notification: Foundation.Notification) {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                DBLog("Unable to connect with FCM. \(String(describing: error))")
                
            } else {
                DBLog("Connected to FCM.")
                
            }
        }
    }
    
    @objc private func showOfflineStatusBar(_ notification: Foundation.Notification) {
        JDStatusBarNotification.show(withStatus: "インターネット接続がオフラインのようです。", dismissAfter: 2.5)
    }

    // MARK: - BAN User

    func accountBanNotification(_ notification: Foundation.Notification) {
        DispatchQueue.main.async {
            self.accountBanAlert()
        }
    }

    private func accountBanAlert(_ completion: (() -> Void)? = nil) {
        alert(on: self.drawerViewController,
              title: "このアカウントは\n凍結されています。\n詳細は運営に\nお問い合わせください。",
              message: nil,
              defaultButtonTitle: "キャンセル",
              destructiveButtonTitle: "お問い合わせ",
              moreSetup: nil) { [weak self] (byDestructive) in
                DispatchQueue.main.async {
                    completion?()

                    if byDestructive {
                        let controller = ContactViewController(type: .none, object: nil)
                        let navi = NavigationController(rootViewController: controller)
                        self?.drawerViewController.present(navi, animated: true, completion: nil)
                    }

                    NotificationCenter.default.addObserver(self!, selector: #selector(self?.accountBanNotification(_:)), name: NSNotification.Name(rawValue: ErrorAccountBanNotification), object: nil)
                }
            }
    }
}

extension AppDelegate: PushNotificationProtocol {
    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Me.sharedMe.registerDeviceToken(deviceToken, completion: nil)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.prod)
    }

    open func application(_ application: UIApplication, didReceive notification: UILocalNotification) {

    }

    @available(iOS, deprecated: 10.0)
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        self.handleNotification(userInfo: userInfo)
    }

    fileprivate func handleNotification(userInfo: [AnyHashable: Any]) {
        AppsFlyerTracker.shared().handlePushNotification(userInfo)

        let aps: [String: AnyObject]? = userInfo["aps"] as? [String: AnyObject]
        let alert: [String: AnyObject]? = aps?["alert"] as? [String: AnyObject]
        let firebaseID: String? = userInfo["gcm.message_id"] as? String

        if Utility.isEmpty(firebaseID) == false {
            SBLog.error(userInfo)
        }

        _ = aps?["type"].map { (type) in
            remoteType.typeFromString(String(describing: type))
        }

        if aps?["book"] != nil || aps?["merchandise"] != nil {
            AppDelegate.shouldUpdateActivity = true
        }

        if aps?["item_transaction"] != nil {
            AppDelegate.shouldUpdateTransaction = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TransactionRefreshKey), object: nil)
        }

        weak var presentingViewController: UIViewController? = tabBarController.selectedViewController
        if aps?["room_id"] != nil {
            ChatRoom.updateCacheChatRoomList({ (error) in
                DispatchQueue.main.async(execute: {
                    if error != nil {
                        return
                    }
                    if presentingViewController is ChatListViewController {
                        (presentingViewController as? ChatListViewController)?.dataSource?.refreshDataSource()
                    }
                })
            })

            let badgeCount: Int = ChatRoom.sumUnReadCount ?? 0
            if presentingViewController is ChatListViewController == false {
                TabManager.sharedManager.setActivityBadgeCount(badgeCount, tabIndex: 3)
            }
        }

        if aps?["announcement_id"] != nil {
            (drawerViewController.drawerViewController as? SideMenuTableViewController)?.updateReadCount()
        }

        if UIApplication.shared.applicationState == .active {
            if alert?["body"] is String {
                JDStatusBarNotification.show(withStatus: alert?["body"] as! String, dismissAfter: 2.5)
            }
        } else if UIApplication.shared.applicationState == .inactive {
            self.actionForNotification(userInfo)
        }
    }

    fileprivate func actionForNotification(_ userInfo: [AnyHashable: Any]) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            return
        }

        var identifier: String?

        if aps["room_id"] != nil {
            identifier = aps["room_id"].map{ String(describing: $0) }

        } else if aps["book"] != nil {
            identifier = aps["book"].map{ String(describing: $0) }
        } else if aps["item_transaction"] != nil {
            identifier = aps["item_transaction"].map{ String(describing: $0) }
        } else if aps["announcement_id"] != nil {
            identifier = aps["announcement_id"].map{ String(describing: $0) }
        } else if aps["merchandise"] != nil {
            identifier = aps["merchandise"].map{ String(describing: $0) }
        }

        if Utility.isEmpty(identifier) == false {
            self.openViewControllerForAction(remoteType , identifier: identifier!)
        }
    }

    fileprivate func openViewControllerForAction(_ type: RemoteNotificationType, identifier: String) {

        if window?.rootViewController?.currentTopViewController is KYDrawerController == false {
            window?.rootViewController?.currentTopViewController?.dismiss(animated: false, completion: nil)
        }

        if window?.rootViewController?.currentTopViewController is KYDrawerController == true {

            drawerViewController.mainViewController = NavigationController(rootViewController: tabBarController)
            kAppDelegate.drawerViewController.setDrawerState(.closed, animated: false)

        }

        switch type {
        case .message:
            ChatRoom.updateCacheChatRoomList({[weak self] (error) in
                DispatchQueue.main.async(execute: {
                    let room: ChatRoom? = ChatRoom.searchRoomFromRoomID(identifier)
                    if room == nil {
                        return
                    }

                    if self?.tabBarController.selectedIndex != 3 {
                        self?.tabBarController.selectedIndex = 3
                    }

                    let controller: ChatListViewController = self?.tabBarController?.selectedViewController as! ChatListViewController
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                        controller.enterTheRoom(room!)
                    })
                })
            })
            break
        case .bookLike, .bookUpdate:
            Book.getBookInfoFromID(identifier, completion: { [weak self] (book, error) in
                DispatchQueue.main.async(execute: {
                    if error != nil {
                        return
                    }

                    if self?.tabBarController.selectedIndex != 0 {
                        self?.tabBarController.selectedIndex = 0
                    }

                    DetailPageTableViewController.generate(for: book) { (generatedViewController: DetailPageTableViewController?) in
                        guard let viewController = generatedViewController else {
                            return
                        }
                        self?.tabBarController?.selectedViewController.navigationController?.pushViewController(viewController, animated: true)
                    }
                })
            })
            break
        case .bookSale:
            Transaction.getTransactionFromBookId(identifier, completion: { (transaction) in
                DispatchQueue.main.async(execute: {
                    if transaction != nil || transaction?.id != nil {

                        if self.tabBarController.selectedIndex != 0 {
                            self.tabBarController.selectedIndex = 0
                        }

                        let controller: ShippingProgressTableViewController = ShippingProgressTableViewController(transaction: transaction!)
                        controller.view.clipsToBounds = true
                        let navi: NavigationController = NavigationController(rootViewController: controller)
                        self.tabBarController?.selectedViewController.present(navi, animated: true, completion: nil)
                    }
                })
            })
            break
        case .news:
            (drawerViewController.drawerViewController as? SideMenuTableViewController)?.openNewsViewController()
            break
        case .transaction:

            if self.tabBarController.selectedIndex != 0 {
                self.tabBarController.selectedIndex = 0
            }

            Transaction.getItemTransactionInfoFromId(identifier, completion: { (transaction, error) in
                DispatchQueue.main.async(execute: {
                    if transaction != nil {
                        let controller: ShippingProgressTableViewController = ShippingProgressTableViewController(transaction: transaction!)
                        controller.view.clipsToBounds = true
                        let navi: NavigationController = NavigationController(rootViewController: controller)
                        self.tabBarController?.selectedViewController.present(navi, animated: true, completion: nil)
                    }
                })
            })

            break
        case .none:
            break
        }
    }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        self.handleNotification(userInfo: userInfo)
    }
}
