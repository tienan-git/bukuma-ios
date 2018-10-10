//
//  TransactionHistoryViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


class TransactionHistoryViewController: BaseTableViewController {
    
    // ================================================================================
    // MARK: setting
    
    override open func registerDataSourceClass() -> AnyClass? {
        return TransactionHistoryDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return TransactionHistoryCell.self
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "履歴"
    }
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }
    
    override open func scrollIndicatorInsetBottom() ->CGFloat {
        return 0
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "履歴はまだありません"
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return ""
    }
    
    // ================================================================================
    // MARK: init
    
    deinit {
        DBLog("-----------deinit TransactionHistoryViewController --------")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ================================================================================
    // MARK:- viewC
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTableView()
        
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            if dataSource == nil {
                return 0
            }
            if dataSource?.count() == 0 {
                return 0
            }
            return dataSource!.count()! + 1
        default:
            return 0
        }
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch indexPath.section {
        case 0:
            return TransactionHistorySalsBalanceCell.cellHeightForObject(nil)
        case 1:
            if indexPath.row == 0 {
                return BaseTitleCell.cellHeightForObject(nil)
            }
            let pointTransaction: PointTransaction? = self.dataSource?.dataAtIndex(indexPath.row - 1, isAllowUpdate: false) as? PointTransaction
            return TransactionHistoryCell.cellHeightForObject(pointTransaction)
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
                cellIdentifier = NSStringFromClass(TransactionHistorySalsBalanceCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?TransactionHistorySalsBalanceCell
                if cell == nil {
                    cell = TransactionHistorySalsBalanceCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                if let dataSource = dataSource as? TransactionHistoryDataSource {
                    (cell as? TransactionHistorySalsBalanceCell)?.pointInfo = dataSource.getPointTransactionResponse
                }

            } else if indexPath.row == 1 {
                cellIdentifier = NSStringFromClass(TransactionHistoryPointCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?TransactionHistoryPointCell
                if cell == nil {
                    cell = TransactionHistoryPointCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                if let dataSource = dataSource as? TransactionHistoryDataSource {
                    (cell as? TransactionHistoryPointCell)?.pointInfo = dataSource.getPointTransactionResponse
                }
            }
            
            break
        case 1:
            if indexPath.row == 0 {
                cellIdentifier = NSStringFromClass(BaseTitleCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
                if cell == nil {
                    cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                (cell as? BaseTitleCell)?.title = "取引の内容"
                break
            }
            
            let pointTransaction: PointTransaction? = self.dataSource?.dataAtIndex(indexPath.row - 1, isAllowUpdate: true) as? PointTransaction
            
            if pointTransaction == nil {
                cellIdentifier = TableViewLoadMoreCell.description()
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
                if cell == nil {
                    cell = TableViewLoadMoreCell()
                }
            } else {
                cellIdentifier = NSStringFromClass(TransactionHistoryCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?TransactionHistoryCell
                if cell == nil {
                    cell = TransactionHistoryCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                (cell as? TransactionHistoryCell)?.cellModelObject = pointTransaction
                //(cell as? TransactionHistoryCell)?.testLabel.text = pointTransaction?.id
                break
            }
           
        default:
            break
        }
        
        return cell ?? UITableViewCell()
    }
}
