//
//  MoneyReqestViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

private let payoutScheduleUrl = "http://static.bukuma.io/bkm_app/guide/transfer.html#section02"

open class MoneyReqestViewController: BaseTableViewController {
    
    fileprivate var sections = [Section]()
    var willExpirePoint: Int = 0
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate enum MoneyReqestTableViewSectionType: Int {
        case moneyReqest
        case help
    }
    
    fileprivate enum MoneyReqestTableViewRowType: Int {
        case moneyReqestCurrentSale
        case moneyReqestNeedTransferSale
        case moneyReqestGetMoney
        case moneyReqestAttensionText
        case helpTitle
        case helpPayoutSchedule
    }
    
    fileprivate struct Section {
        var sectionType: MoneyReqestTableViewSectionType
        var rowItems: [MoneyReqestTableViewRowType]
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
        sections = [Section(sectionType: .moneyReqest, rowItems: [.moneyReqestCurrentSale, .moneyReqestNeedTransferSale, .moneyReqestGetMoney, .moneyReqestAttensionText]),
                    Section(sectionType: .help, rowItems: [.helpTitle, .helpPayoutSchedule])]
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "売上確認・振込手続き"
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        User.recalculatePoint { (error) in
            Me.sharedMe.syncronizeMyProfileWithCompletion({ [weak self] (error) in
                DispatchQueue.main.async {
                    self?.tableView?.reloadData()
                }
                })
        }
        self.refreshDataSource()
    }
    
    func reload() {
        tableView?.reloadData()
    }
    
    open override func refreshDataSource() {
        Point.getExpirePoints { (point, error) in
            DispatchQueue.main.async {
                self.willExpirePoint = point?.willExpireSales ?? 0
                self.tableView?.reloadData()
            }
        }
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
        return MoneyReqestCell.cellHeightForObject(nil)
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .moneyReqestCurrentSale:
            cellIdentifier = NSStringFromClass(MoneyReqestCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?MoneyReqestCell
            if cell == nil {
                cell = MoneyReqestCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! MoneyReqestCell).title = "現在の売上"
            (cell as! MoneyReqestCell).textLabelText = "¥\(Me.sharedMe.point?.normalPoint?.thousandsSeparator() ?? 0.string())"
            (cell as! MoneyReqestCell).selectionStyle = .none
            break
        case .moneyReqestNeedTransferSale:
            cellIdentifier = NSStringFromClass(MoneyReqestCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?MoneyReqestCell
            if cell == nil {
                cell = MoneyReqestCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! MoneyReqestCell).title = "振込申請期限が3ヶ月以内の売上金"
            (cell as! MoneyReqestCell).textLabelText = "¥\(willExpirePoint.thousandsSeparator())"
            (cell as! MoneyReqestCell).textlabel?.textColor = kMainGreenColor
            (cell as! MoneyReqestCell).selectionStyle = .none
            break
        case .moneyReqestGetMoney:
            cellIdentifier = NSStringFromClass(MoneyReqestCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?MoneyReqestCell
            if cell == nil {
                cell = MoneyReqestCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! MoneyReqestCell).title = "振込申請して現金を受け取る"
            (cell as! MoneyReqestCell).rightImage = UIImage(named: "ic_to")
            break
        case .moneyReqestAttensionText:
            cellIdentifier = NSStringFromClass(AttensionTextCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AttensionTextCell
            if cell == nil {
                cell = AttensionTextCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? AttensionTextCell)?.title = "※売上金を使って本を購入することができます。"
            break
        case .helpTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "ヘルプ"
            break
        case .helpPayoutSchedule:
            cellIdentifier = NSStringFromClass(MoneyReqestCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?MoneyReqestCell
            if cell == nil {
                cell = MoneyReqestCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! MoneyReqestCell).title = "振込のスケジュールは？"
            (cell as! MoneyReqestCell).rightImage = UIImage(named: "ic_to")
            break
        }
        
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .moneyReqestGetMoney:
            let controller: TrasfarProcedureViewController = TrasfarProcedureViewController()
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case .helpPayoutSchedule:
            if let url = URL(string: payoutScheduleUrl) {
                let controller = BaseWebViewController(url: url)
                controller.view.clipsToBounds = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
            break
        default:
            break
        }
    }
    
}
