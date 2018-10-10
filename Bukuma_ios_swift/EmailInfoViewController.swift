//
//  EmailInfoViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class EmailInfoViewController: BaseTableViewController {
    
    fileprivate var sections = [Section]()
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate enum EmailInfoTableViewSectionType: Int {
        case emailInfo
        case forgetPass
    }
    
    fileprivate enum EmailInfoTableViewRowType: Int {
        case emailInfoTitle
        case emailInfoEmail
        case emailInfoPassword
        case forgetPassTitle
        case forgetPassPassword
    }
    
    fileprivate struct Section {
        var sectionType: EmailInfoTableViewSectionType
        var rowItems: [EmailInfoTableViewRowType]
    }
    
    // ================================================================================
    // MARK: setting
    
    override open func footerHeight() -> CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    override func initializeTableViewStruct() {
        sections = [Section(sectionType: .emailInfo, rowItems: [.emailInfoTitle, .emailInfoEmail, .emailInfoPassword]), Section(sectionType: .forgetPass, rowItems: [.forgetPassTitle, .forgetPassPassword])]
    }
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "メールとパスワード"
        
    }
    
    // ================================================================================
    // MARK: init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadCellInfo), name: NSNotification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
    }
    
    func reloadCellInfo() {
        tableView?.reloadData()
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
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .emailInfoTitle, .forgetPassTitle:
            return BaseTitleCell.cellHeightForObject(nil)
        default:
            return 50.0
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .emailInfoTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "登録済みの情報"
            break
        case .emailInfoEmail:
            cellIdentifier = NSStringFromClass(BaseIconTitleTextCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = Utility.isEmpty(Me.sharedMe.email?.currentEmail) ? "メールアドレスは登録されていません" : Me.sharedMe.email!.currentEmail
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            (cell as! BaseIconTextTableViewCell).rightImage = UIImage(named: "ic_to")
            break
        case .emailInfoPassword:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell(reuseIdentifier: cellIdentifier, delegate: self)
            }
           (cell as! BaseIconTextTableViewCell).title = Utility.isEmpty(Me.sharedMe.isRegisterd) ? "Passwordは登録されていません" : "*******"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            (cell as! BaseIconTextTableViewCell).rightImage = UIImage(named: "ic_to")
            break
        case .forgetPassTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "パスワードリセット"
            break
        case .forgetPassPassword:
            cellIdentifier = NSStringFromClass(BaseIconTitleTextCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "パスワードをリセットする"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            (cell as! BaseIconTextTableViewCell).rightImage = UIImage(named: "ic_to")
            break
        }
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        var controller: BaseViewController?
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .emailInfoEmail:
            controller = EmailPasswordSettingViewController(type: .email)
            break
        case .emailInfoPassword:
            controller = EmailPasswordSettingViewController(type: .password)
            break
        case .forgetPassPassword:
            controller = EmailPasswordSettingViewController(type: .resetPass)
            break
        default:
            break
        }
        if controller != nil {
            controller!.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller!, animated: true)
        }
    }
    
}
