//
//  SideTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


public let kSideMenuBackgroundColor: UIColor = UIColor.colorWithHex(0x585B5A)

open class SideMenuTableViewController: BaseTableViewController {
    
    // ================================================================================
    // MARK: tableView struct
    
    fileprivate var sections = [Section]()
 
    fileprivate enum SideMenuTableViewSectionType: Int {
        case sideMenu
    }
    
    fileprivate enum SideMenuTableViewRowType {
        case sideMenuHome
        case sideMenuNews
        case sideMenuLikeBook
        case sideMenuSallingBook
        case sideMenuBoughtBook
        case sideMenuSetting
        case sideMenuTutorial
        case sideMenuContact
        case sideMenuInvitation
    }
    
    fileprivate struct Section {
        var sectionType: SideMenuTableViewSectionType
        var rowItems: [SideMenuTableViewRowType]
    }

    // ================================================================================
    // MARK:- setting 
    
    override var shouldShowRightNavigationButton: Bool {
        get {
            return true
        }
    }

    override open func pullToRefreshInsetTop() -> CGFloat {
        return 0
    }
    
    // ================================================================================
    // MARK: init
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initializeTableViewStruct() {
        self.sections = ExternalServiceManager.isOnBati ?
            [Section(sectionType: .sideMenu, rowItems: [.sideMenuHome, .sideMenuNews, .sideMenuLikeBook , .sideMenuSallingBook, .sideMenuBoughtBook, .sideMenuSetting, .sideMenuTutorial, .sideMenuContact])] :
            [Section(sectionType: .sideMenu, rowItems: [.sideMenuHome, .sideMenuNews, .sideMenuLikeBook , .sideMenuSallingBook, .sideMenuBoughtBook, .sideMenuSetting, .sideMenuTutorial, .sideMenuContact, .sideMenuInvitation])]
    }
    
    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationBarView!.backgroundColor = UIColor.clear
        navigationBarView!.isHidden = true
        
        tableView!.showsPullToRefresh = false
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())

        self.view.backgroundColor = UIColor.colorWithHex(0xF9F9F9)
        tableView!.backgroundColor = UIColor.colorWithHex(0xF9F9F9)

        let logoImageView = UIImageView(image: UIImage(named: "img_cover_drawer"))
        let headerView: UIView! = UIView(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: logoImageView.height))
        headerView.backgroundColor = kMainGreenColor
        headerView.addSubview(logoImageView)
        
        tableView!.tableHeaderView = headerView
        
        let headerGreenColorView = UIView(frame: CGRect(x: 0, y: -400, width: kCommonDeviceWidth, height: 400))
        headerGreenColorView.backgroundColor = kMainGreenColor
        logoImageView.addSubview(headerGreenColorView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateReadCount), name: NSNotification.Name(rawValue: AnnouncementReadKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.udpateStruct), name: NSNotification.Name(rawValue: ServiceManagerIsOnBatiNotification), object: nil)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateReadCount()
    }
    
    func udpateStruct() {
        self.initializeTableViewStruct()
        self.tableView?.reloadData()
    }
    
    func updateReadCount() {
        let indexPass: IndexPath = IndexPath(row: 1, section: 0)
        let cell: SideMenuCell? = tableView?.cellForRow(at: indexPass) as? SideMenuCell
        
        if Me.sharedMe.isRegisterd == true {
            Announcement.unReadCount { (unreadCount, error) in
                DispatchQueue.main.async {
                    cell?.unReadCount = unreadCount
                }
            }
        }
    }
    
    func openNewsViewController() {
        let controller: NewsViewController = NewsViewController()
        let navigationController =  NavigationController.init(rootViewController: controller)
        kAppDelegate.drawerViewController.mainViewController = navigationController
        kAppDelegate.drawerViewController.setDrawerState(.closed, animated: true)
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return  sections.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowItems.count
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SideMenuCell.cellHeightForObject(nil)
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SideMenuCell?
        var cellIdentifier: String! = ""
        
        cellIdentifier = NSStringFromClass(SideMenuCell.self)
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?SideMenuCell
        if cell == nil {
            cell = SideMenuCell.init(reuseIdentifier: cellIdentifier, delegate: self)
        }
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .sideMenuHome:
            cellIdentifier = NSStringFromClass(SideMenuHomeCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?SideMenuHomeCell
            if cell == nil {
                cell = SideMenuHomeCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }

            cell!.title = "ホーム"
            cell!.iconImage = UIImage(named: "ic_dw_home")
            break
        case .sideMenuNews:
            cell!.title = "運営からのお知らせ"
            cell!.iconImage = UIImage(named: "ic_dw_news")
            break
        case .sideMenuLikeBook:
            cell!.title = "いいねした商品"
            cell!.iconImage = UIImage(named: "ic_dw_like")
            break
        case .sideMenuSallingBook:
            cell!.title = "出品中の商品"
            cell!.iconImage = UIImage(named: "ic_dw_sell")
            break
        case .sideMenuBoughtBook:
            cell!.title = "購入した商品"
            cell!.iconImage = UIImage(named: "ic_dw_buy")
            break
        case .sideMenuSetting:
            cell!.title = "設定"
            cell!.iconImage = UIImage(named: "ic_dw_cog")
            break
        case .sideMenuTutorial:
            cell!.title = "ブクマ！の使い方"
            cell!.iconImage = UIImage(named: "ic_dw_tutorial")
            break
        case .sideMenuContact:
            cell!.title = "お問い合わせ"
            cell!.iconImage = UIImage(named: "ic_dw_question")
            break
        case .sideMenuInvitation:
            cell!.title = "ブクマ！に友達を招待"
            cell!.iconImage = UIImage(named: "ic_dw_invite")
            break
        }
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        var controller: UIViewController?
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .sideMenuHome:
            controller = kAppDelegate.tabBarController
            break
        case .sideMenuNews:
            controller = NewsViewController()
            break
        case .sideMenuLikeBook:
            controller = LikeListViewController()
            break
        case .sideMenuSallingBook:
            controller = ExhibitingBookListViewController(user: Me.sharedMe)
            break
        case .sideMenuBoughtBook:
            controller = BoughtBookListViewController()
            break
        case .sideMenuSetting:
            controller = SettingViewController()
            break
        case .sideMenuTutorial:
            let kTutorialUrl: URL = URL(string: "http://static.bukuma.io/bkm_app/how-to-use.html")!
            controller = BaseWebViewController(url: kTutorialUrl)
            controller?.view.backgroundColor = kBackGroundColor
            (controller as? BaseWebViewController)?.webView?.backgroundColor = kBackGroundColor
            controller?.title = "ブクマ！の使い方"
            break
        case .sideMenuContact:
            controller = BeforeContactViewController.generate()
            break
        case .sideMenuInvitation:
            controller = InvitationUserViewController()
            break
        }
        let navigationController =  NavigationController.init(rootViewController: controller!)
        kAppDelegate.drawerViewController.mainViewController = navigationController
        kAppDelegate.drawerViewController.setDrawerState(.closed, animated: true)
    }
}
