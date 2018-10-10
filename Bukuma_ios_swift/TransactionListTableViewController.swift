//
//  TodoListTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/23.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class TransactionListTableViewController: BaseTableViewController {
    // ================================================================================
    // MARK: setting
    
    deinit {
        DBLog("-------------deinit TransactionListTableViewController ----------")
        
    }
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }
    
    override open func scrollIndicatorInsetBottom() ->CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return TransactionListDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return TransactionListCell.self
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "現在やることリストはありません"
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return "取り引きが開始されると、あなたにやってほしいことが表示されます"
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "img_ph_05")
    }

    // ================================================================================
    // MARK: init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "取引一覧"
    }
    
    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshDataSource()
        self.restoreCellPositionner.restoreCellPosition(of: self.tableView!)
    }
    
    // MARK: - UITableViewDataSource

    private let sections: Int = 2

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataSource = self.dataSource as? TransactionListDataSource {
            return dataSource.todoDatas[section].count
        } else {
            return 0
        }
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.activeTableViewtag = tableView.tag

        var cellData: Transaction?
        if let dataSource = self.dataSource as? TransactionListDataSource {
            cellData = dataSource.todoDatas[indexPath.section][indexPath.row]
        }

        let tableViewCellClass = self.registerCellClass() as! BaseTableViewCell.Type
        return tableViewCellClass.cellHeightForObject(cellData)
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellClass = self.registerCellClass() as! BaseTableViewCell.Type
        let cellId = NSStringFromClass(cellClass)
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? TransactionListCell
        if cell == nil {
            cell = cellClass.init(reuseIdentifier: cellId, delegate: self) as? TransactionListCell
        }

        var cellData: Transaction?
        if let dataSource = self.dataSource as? TransactionListDataSource {
            cellData = dataSource.todoDatas[indexPath.section][indexPath.row]
        }
        cell?.cellModelObject = cellData
        cell?.markAsMyToDo(indexPath.section == 0)

        return cell!
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        guard let dataSource = self.dataSource as? TransactionListDataSource else {
            return
        }
        let transaction = dataSource.todoDatas[indexPath.section][indexPath.row]

        self.restoreCellPositionner.saveCellPosition(with: indexPath, of: tableView)

        let controller: ShippingProgressTableViewController = ShippingProgressTableViewController(transaction: transaction)
        self.navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - UITableViewDelegate

    private let sectionHeaderHeight: CGFloat = 40.0
    private let sectionHeaderOffset: CGFloat = 12.0
    private let sectionHeaderColor: UIColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    private let sectionHeaderTextSize: CGFloat = 13.0
    private let sectionHaederTextColor: UIColor = UIColor.black
    private let sectionHeaderTexts: [String] = ["やることリスト", "相手の対応待ち"]

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.sectionHeaderHeight
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.numberOfRows(inSection: 0) == 0 && tableView.numberOfRows(inSection: 1) == 0 {
            // データが無い時に何もしないと sectionHeaderHeight 分の色の段差ができてしまうことの回避策
            let emptyHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: self.sectionHeaderHeight))
            emptyHeaderView.backgroundColor = UIColor.clear
            return emptyHeaderView
        }

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: self.sectionHeaderHeight))
        headerView.backgroundColor = self.sectionHeaderColor

        let labelView = UILabel(frame: CGRect(x: self.sectionHeaderOffset, y: 0, width: kCommonDeviceWidth - self.sectionHeaderOffset, height: self.sectionHeaderHeight))
        labelView.backgroundColor = self.sectionHeaderColor
        labelView.font = UIFont.systemFont(ofSize: self.sectionHeaderTextSize)
        labelView.textColor = self.sectionHaederTextColor

        labelView.text = self.sectionHeaderTexts[section]

        headerView.addSubview(labelView)
        return headerView
    }

    // MARK: - RestoreCellPositionProtocol.

    private var restoreCellPositionner = RestoreCellPosition()
}
