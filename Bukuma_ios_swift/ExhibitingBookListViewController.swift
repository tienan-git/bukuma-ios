//
//  ExhibitingTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/04.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD

open class ExhibitingBookListViewController: BaseTableViewController {

    fileprivate var user: User?
    fileprivate var isMyPage: Bool? {
        get {
            return user == nil || user?.identifier?.characters.count == 0 || Me.sharedMe.identifier == user?.identifier
        }
    }

    // ================================================================================
    // MARK: setting
    
    override open func registerDataSourceClass() -> AnyClass? {
        return ExhibitingBookListDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return ExhibitingBookListCell.self
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "出品中の商品はまだありません"
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "出品中の商品"
        self.title = "出品中の商品"
    }
    
    override open func pullToRefreshInsetTop() -> CGFloat {
        return NavigationHeightCalculator.navigationHeight()
    }
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }
    
    override open func scrollIndicatorInsetBottom() ->CGFloat {
        return 0
    }
    
    // ================================================================================
    // MARK: init
    
    deinit {
        DBLog("-----------deinit ExhibitingBookListViewController --------")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(user: User?) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        self.setUserInfo(user)
    }

    func setUserInfo(_ user: User?) {
        (dataSource as? ExhibitingBookListDataSource)?.user = user
    }

    // ================================================================================
    // MARK:- viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: ExhibitEditViewControllerEditNotification), object: nil)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTableView()
        
    }
    
    func reload() {
        self.refreshDataSource()
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let object: Merchandise? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate:false) as? Merchandise
        
        self.view.isUserInteractionEnabled = false
        
        if Me.sharedMe.isMine(user?.identifier ?? "-1") == true {
            let transaction: Transaction? = Transaction.searchTransactionFromId(object?.id)
            if transaction == nil || transaction?.id == nil {
                
                self.goDetailBook(object?.book ?? Book(), completion: nil)
            } else {
                SVProgressHUD.show()
                transaction?.getItemTransactionInfo({ (error) in
                    let controller: ShippingProgressTableViewController = ShippingProgressTableViewController(transaction: transaction!)
                    controller.view.clipsToBounds = true
                    self.navigationController?.pushViewController(controller, animated: true)
                    self.view.isUserInteractionEnabled = true
                    SVProgressHUD.dismiss()
                })
            }
            return
        }
        
        self.goDetailBook(object?.book ?? Book(), completion: nil)
        
    }
}




