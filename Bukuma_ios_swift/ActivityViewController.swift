//
//  ActivityViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class ActivityViewController: BaseTableViewController {
    
    // ================================================================================
    // MARK: setting
    
    override open func registerDataSourceClass() -> AnyClass? {
        return ActivityDataSource.self
    }

    override open func registerCellClass() -> AnyClass? {
        return ActivityCell.self
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "お知らせはまだありません"
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return "出品した商品にいいねされた場合や、最安値が更新された場合ここに表示されます"
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "img_ph_01")
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "お知らせ"
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
        DBLog("-----------deinit ActivityViewController --------")
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
        
        AppDelegate.shouldUpdateActivity = false
    }

    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let object: Activity? = dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Activity
        
        if object == nil {
            return
        }
        
        self.goDetailBook(object?.book ?? Book(), completion: nil)
        
    }
}
