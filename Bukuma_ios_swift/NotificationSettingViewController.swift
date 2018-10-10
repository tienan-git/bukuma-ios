//
//  NotificationSettingViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class NotificationSettingViewController: BaseTableViewController, NotificationCellDelegate {
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate enum NotificationSettingViewControllerSectionType: Int {
        case pushNotification
        case email
    }

    // ================================================================================
    // MARK: setting
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "通知設定"
    }
    
    // ================================================================================
    // MARK: init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        Me.sharedMe.getNotification(nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView!.showsPullToRefresh = false
        self.automaticallyAdjustsScrollViewInsets = false
        tableView!.showsVerticalScrollIndicator = false
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())
        
        Me.sharedMe.getNotification {[weak self] (error) in
            DispatchQueue.main.async {
                self?.tableView?.reloadData()
            }
        }
    }
    
    // ================================================================================
    // MARK: - notofication delegate
    
    open func notificationSwitched(_ cell: NotificationCell) {
        let notificationType: NotificationType? =  NotificationType(rawValue: cell.notificationSwitch.tag)
        Me.sharedMe.updateNotification(notificationType!.parameterFromType(), isOn: cell.notificationSwitch.isOn) {[weak self] (error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                    cell.isOn = false
                    return
                }
            }
        }
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return  2
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch NotificationSettingViewControllerSectionType.init(rawValue: section)! {
        case .pushNotification:
            return Notification().remoteNotificationCount() + 1
        case .email:
            return Notification().emailNotificationCount() + 1
        }
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NotificationCell.cellHeightForObject(nil)
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String?
        
        switch NotificationSettingViewControllerSectionType.init(rawValue: indexPath.section)! {
        case .pushNotification:
            if indexPath.row == 0 {
                cellIdentifier = NSStringFromClass(BaseTitleCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as? BaseTitleCell
                if cell == nil {
                    cell = BaseTitleCell(reuseIdentifier: cellIdentifier!, delegate: self)
                }
                (cell as? BaseTitleCell)?.title = "通知設定"
            } else {
                cellIdentifier = NSStringFromClass(NotificationCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as? NotificationCell
                if cell == nil {
                    cell = NotificationCell(reuseIdentifier: cellIdentifier!, delegate: self)
                }
                (cell as? NotificationCell)?.notificationSwitch.tag = indexPath.row - 1
                (cell as? NotificationCell)?.title = NotificationType(rawValue: indexPath.row - 1)?.stringFromType()
                if Me.sharedMe.notification?.notifications != nil {
                    (cell as? NotificationCell)?.isOn = Me.sharedMe.notification!.notificationsAtIndex(indexPath.row - 1)!
                }
                
                if indexPath.row == Notification().remoteNotificationCount() + 1 {
                    cell?.isShortBottomLine = false
                }
            }
            break
        case .email:
            if indexPath.row == 0 {
                cellIdentifier = NSStringFromClass(BaseTitleCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as? BaseTitleCell
                if cell == nil {
                    cell = BaseTitleCell(reuseIdentifier: cellIdentifier!, delegate: self)
                }
                (cell as? BaseTitleCell)?.title = "メール通知設定"
            } else {
                cellIdentifier = NSStringFromClass(NotificationCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as? NotificationCell
                if cell == nil {
                    cell = NotificationCell(reuseIdentifier: cellIdentifier!, delegate: self)
                }
                (cell as? NotificationCell)?.notificationSwitch.tag = indexPath.row + 5
                (cell as? NotificationCell)?.title = NotificationType(rawValue: indexPath.row + 5)?.stringFromType()
                if Me.sharedMe.notification?.notifications != nil {
                    (cell as? NotificationCell)?.isOn = Me.sharedMe.notification!.notificationsAtIndex(indexPath.row + 5)!
                }
                
                if indexPath.row == Notification().emailNotificationCount() + 1 {
                    cell?.isShortBottomLine = false
                }
            }
            break
        }
        return cell!
    }
    
}
