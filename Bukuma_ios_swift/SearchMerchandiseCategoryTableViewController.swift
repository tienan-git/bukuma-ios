//
//  SearchMerchandiseTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/09.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class SearchMerchandiseCategoryTableViewController: BaseTableViewController {
    
    var row: Int?
    var color: UIColor?
    var category: Category? {
        didSet {
            if let category = self.category {
                (dataSource as? SearchTimelineDataSource)?.cateory = category
            }
        }
    }
    
    // ================================================================================
    // MARK: setting
    
    override open func registerDataSourceClass() -> AnyClass? {
        return SearchTimelineDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return SearchMerchandiseCell.self
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "このカテゴリーにはまだ商品はまだありません"
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "img_ph_01")
    }
    
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = self.category?.categoryName
        self.title = self.category?.categoryName
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
        DBLog("-----------deinit SearchMerchandiseTableViewController --------")
    }
    
    required public init(color: UIColor) {
        super.init(nibName: nil, bundle: nil)
        self.color = color
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
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let object: Book? = dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Book
        
        if object == nil {
            return
        }
        
        self.goDetailBook(object!, completion: nil)
        
    }
}

extension SearchMerchandiseCategoryTableViewController: SearchMerchandiseCellDelegate {
    open func searchMerchandiseCellLikeButtonTapped(_ cell: SearchMerchandiseCell, completion:@escaping (_ isLiked:Bool?, _ numLike: Int) ->Void) {
        if Me.sharedMe.isRegisterd == false {
            self.showUnRegisterAlert()
            completion(false, (cell.cellModelObject as? Book)?.numOfLike ?? 0)
            return
        }
        
        (cell.cellModelObject as? Book)?.toggleLikeBook({ (isLiked, num, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                    completion((cell.cellModelObject as? Book)?.liked, (cell.cellModelObject as? Book)?.numOfLike ?? 0)
                    return
                }
                completion(isLiked, num)
            }
        })
    }
}
