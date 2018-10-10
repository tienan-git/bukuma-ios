//
//  UserPageViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

open class UserPageViewController: BaseTableViewController,
UserPageViewDelegate,
UserPageCollectionCellDelegate {
    
    var user: User?
    var userPageView: UserPageView! = UserPageView()
    var isMyPage: Bool? {
        get {
            return user == nil || user?.identifier?.characters.count == 0 || Me.sharedMe.identifier == user?.identifier
        }
    }
    
    var backGroundGreenView: UIView?
    var merchandiseListDataSource: UserMerchandiseListDataSource?
    
    // ================================================================================
    // MARK: setting
    
    override open func registerDataSourceClass() -> AnyClass? {
        return UserTimeLineDataSource.self
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return ""
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return ""
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "")
    }
    
    var shouldReloadMerchandiseList: Bool {
        get {
            return merchandiseListDataSource != nil && !(merchandiseListDataSource?.count() == 0)
        }
    }

    var shouldShowProgressHUDWhenMerchandiseDataSourceRefresh: Bool {
        get {
            return merchandiseListDataSource != nil && merchandiseListDataSource?.count() == 0
        }
    }

    override open func initializeNavigationLayout() {
        let rightButton = BarButtonItem.barButtonItemWithImage(UIImage(named: "tab_head_block")!,
                                                               isLeft: false,
                                                               target: self,
                                                               action: #selector(self.rightButtonTapped(_:)))
        if isMyPage == false {
            self.setNavigationBarButton(rightButton, isLeft: false)
        }
    }
    
    override open func footerHeight() -> CGFloat {
        return kAppDelegate.tabBarController.tabBar.height
    }

    override open func scrollIndicatorInsetBottom() -> CGFloat {
        if (self.navigationController?.viewControllers.count ?? 0) >= 2 {
            return 0
        }
        return super.scrollIndicatorInsetBottom()
    }
    // ================================================================================
    // MARK: init
    
    required public init(user: User?) {
        super.init(nibName: nil, bundle: nil)
        merchandiseListDataSource = UserMerchandiseListDataSource()
        merchandiseListDataSource?.delegate = self
        self.user = user
        
        if isMyPage == true {
            self.user = Me.sharedMe
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        emptyDataView?.removeFromSuperview()
        
        userPageView = UserPageView(delegate: self)
        
        tableView?.backgroundColor = UIColor.clear
        
        backGroundGreenView = UIView(frame: CGRect(x: 0, y: -backGroundGreenViewHeight, width: kCommonDeviceWidth, height: backGroundGreenViewHeight + userPageView.height - NavigationHeightCalculator.navigationHeight()))
        backGroundGreenView?.backgroundColor = kMainGreenColor
        self.view.insertSubview(backGroundGreenView!, belowSubview: tableView!)
        
        userPageView.user = user
        tableView!.tableHeaderView = userPageView

        (dataSource as? UserTimeLineDataSource)?.user = user
        merchandiseListDataSource?.user = user
        
        self.refreshDataSource()
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userPageView.user = self.user
        tableView!.tableHeaderView = userPageView
        (dataSource as? UserTimeLineDataSource)?.user = user
        merchandiseListDataSource?.user = user
        self.reloadTableView()
    }
    
    override func reloadTableView() {
        if self.shouldReloadMainView == true {
            self.dataSource?.update()
            self.tableView?.reloadData()
        }
        
        if self.shouldRefreshDataSource == true {
            self.refreshDataSource()
        }
        
        if shouldReloadMerchandiseList == true {
            merchandiseListDataSource?.update()
            tableView?.reloadData()
            self.reloadCollectionView()
        }
        
        if shouldShowProgressHUDWhenMerchandiseDataSourceRefresh == true {
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
            merchandiseListDataSource?.refreshDataSource()
        }
    }
    
    override open func completeRequest() {
        super.completeRequest()
        
        DispatchQueue.main.async {
            self.reloadCollectionView()
        }
    }
    
    func reloadCollectionView() {
        
        let collectionIndexPass: IndexPath = IndexPath(row: 1, section: 0)
        let cell: UserPageCollectionTableCell?  = self.tableView?.cellForRow(at: collectionIndexPass) as? UserPageCollectionTableCell
        cell?.collectionView?.reloadData()
    }
    
    func rightButtonTapped(_ sender: UIButton)  {
        if isMyPage == true {
            return
        }
        
        if user == nil || user?.identifier == nil {
            self.simpleAlert("ユーザーがいません", message: "すでに退会したユーザーを通報することはできません", cancelTitle: "OK", completion: nil)
            return
        }
        
        self.showUserReportMenu(user!) {[weak self] (isBlocked) in
            if isBlocked {
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: ChatRoomUserBlockKey), object: self?.user?.identifier ?? "")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                    self?.popViewController()
                })
            }
        }
    }
    
    override open func refreshDataSource() {
        super.refreshDataSource()
        if shouldShowProgressHUDWhenMerchandiseDataSourceRefresh == true {
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
        }
        merchandiseListDataSource?.refreshDataSource()
        
        user?.getUserInfo({[weak self] (error) in
            DispatchQueue.main.async {
                if error != nil {
                    return
                }
                self?.tableView?.reloadData()
                self?.reloadCollectionView()
            }
        })
    }
    
    // ================================================================================
    // MARK: -  userPageCollection delegate
    
    open func userPageCollectionDidSelectAdRow(_ row: Int, merchandise: Merchandise) {
        if let book = merchandise.book {
            self.goDetailBook(book, completion: nil)
        }
    }
    
    // ================================================================================
    // MARK: - userPageView delegate
    
    open func userPageViewIconTapped(_ view: UserPageView) {
        if Me.sharedMe.isRegisterd == false {
            showUnRegisterAlert()
            return
        }
        RMUniversalAlert.showActionSheet(in: self,
                                         withTitle: nil,
                                         message: nil,
                                         cancelButtonTitle: "キャンセル",
                                         destructiveButtonTitle: nil,
                                         otherButtonTitles: isMyPage == true ? ["プロフィール写真を表示","プロフィール編集"] : ["プロフィール写真を表示"],
                                         popoverPresentationControllerBlock: { (popover) in
                                            popover.sourceView = self.view
                                            popover.sourceRect = self.view.frame
        }) {[weak self] (alert, buttonIndex) in
            if buttonIndex == alert.cancelButtonIndex {
                return
            } else if buttonIndex == alert.firstOtherButtonIndex {
                self!.showPhoto(view.user?.photo)
            } else {
                self!.showPrifileSettingViewController()
            }
        }
    }

    open func userPageVieweChatButtonTapped(_ view: UserPageView) {
        if Me.sharedMe.isRegisterd == false {
            showUnRegisterAlert()
            return
        }
        
        if Me.sharedMe.verified == false {
            self.showUnVerifiedAlert()
            return
        }
        
        if user == nil || user?.identifier == nil {
            self.simpleAlert("ユーザーがいません", message: "すでに退会したユーザーにメッセージを送ることはできません", cancelTitle: "OK", completion: nil)
            return
        }
        
        if isMyPage == false {
            self.enterChatRoom(withUser: view.user ?? User(), transaction: nil, isCancel: false, isSendMension: false, completion: nil)
        } else {
            let controller: ProfileSettingViewController = ProfileSettingViewController()
            let navi = NavigationController(rootViewController: controller)
            self.present(navi, animated: true, completion: nil)
        }
    }
        
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return  3
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if user?.merchandisesCount == 0.string() || user?.merchandisesCount == nil {
                return 1
            }
            return 2
        case 1:
            return 1
        case 2:
            return dataSource?.count() ?? 0
        default:
            return 0
        }
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return UserPageMerchandiseTitleCell.cellHeightForObject(nil)
            }
            let merchandises: [Merchandise]? = merchandiseListDataSource?.dataSource as? [Merchandise]
            if indexPath.row == 1 && (merchandises?.count == 0 || merchandises == nil) {
                return 0
            }
            return UserPageCollectionTableCell.cellHeightForObject(nil)
            
        case 1:
            return UserPageEvaluateTitleCell.cellHeightForObject(nil)
        case 2:
            let object: Review? = dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Review
            return UserPageTimelineCell.cellHeightForObject(object)

        default:
            return 0
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        var cellIdentifier: String! = ""
    
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cellIdentifier = NSStringFromClass(UserPageMerchandiseTitleCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?UserPageMerchandiseTitleCell
                if cell == nil {
                    cell = UserPageMerchandiseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }                
                (cell as? UserPageMerchandiseTitleCell)?.cellModelObject = user?.merchandisesCount as AnyObject?
                break
            }
            
            cellIdentifier = NSStringFromClass(UserPageCollectionTableCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?UserPageCollectionTableCell
            if cell == nil {
                cell = UserPageCollectionTableCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? UserPageCollectionTableCell)?.dataSource = merchandiseListDataSource
            
            let merchandises: [Merchandise]? = merchandiseListDataSource?.dataSource as? [Merchandise]
            (cell as? UserPageCollectionTableCell)?.cellModelObject = merchandises as AnyObject?
            break
        case 1:
            cellIdentifier = NSStringFromClass(UserPageEvaluateTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?UserPageEvaluateTitleCell
            if cell == nil {
                cell = UserPageEvaluateTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? UserPageEvaluateTitleCell)?.cellModelObject = user
            break
        case 2:
            let object: Review? = dataSource?.dataAtIndex(indexPath.row , isAllowUpdate: true) as? Review
            if object == nil {
                cellIdentifier = TableViewLoadMoreCell.description()
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TableViewLoadMoreCell
                if cell == nil {
                    cell = TableViewLoadMoreCell()
                }
            }else {
                cellIdentifier = NSStringFromClass(UserPageTimelineCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?UserPageTimelineCell
                if cell == nil {
                    cell = UserPageTimelineCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                (cell as? UserPageTimelineCell)?.cellModelObject = object
            }
            break
        default:
            break
        }
       
        return cell ?? UITableViewCell()
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if Me.sharedMe.isRegisterd == false {
            showUnRegisterAlert()
            return
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let controller: ExhibitingBookListViewController = ExhibitingBookListViewController(user: user)
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
        
        if indexPath.section == 1 {
            return
        }
        
        let review: Review? = dataSource?.dataAtIndex(indexPath.row , isAllowUpdate: false) as? Review
        
        let controller: UserPageViewController = UserPageViewController(user: review?.user)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
        
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return kCommonTableSectionHeight
        }
        return  0
    }
}
