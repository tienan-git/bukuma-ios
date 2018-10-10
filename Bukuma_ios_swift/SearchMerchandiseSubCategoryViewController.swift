//
//  SearchDetailCategory.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/14.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class SearchMerchandiseSubCategoryViewController: BaseTableViewController {
    
    var category: Category?
    var row: Int?
    
    // ================================================================================
    // MARK: init
    
    override open func footerHeight() -> CGFloat {
        return  64.0
    }
    
    override open func scrollIndicatorInsetBottom() ->CGFloat {
        return 0
    }

    required public init(category: Category, row: Int) {
        super.init(nibName: nil, bundle: nil)
        
        self.category = category
        let rootCategory: Category = Category()
        rootCategory.updateProperty(self.category!)
        rootCategory.tempName = "全て"
        var isInclude: Bool = false
        for category in category.subCategories ?? [Category()] {
            if category.id == rootCategory.id {
                isInclude = true
                break
            }
            isInclude = false
        }
        
        if isInclude == false {
            self.category?.subCategories?.insert(rootCategory, at: 0)
        }
        
        self.row = row
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = category?.categoryName
    }
    
    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        navigationBarView?.backgroundColor = SearchCategoryColor.searchCategoryColor(by: row!)
        
        tableView!.showsPullToRefresh = false
        
        emptyDataView?.removeFromSuperview()
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.category?.subCategories?.count ?? 0
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseIconTextTableViewCell?
        var cellIdentifier: String! = ""
        
        cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
        if cell == nil {
            cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
        }
        if self.category?.subCategories?[indexPath.row].tempName != nil {
           cell?.title = self.category?.subCategories?[indexPath.row].tempName.flatMap{$0}
        } else {
            cell?.title = self.category?.subCategories?[indexPath.row].categoryName.flatMap{$0}
        }
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let object: Category? = self.category?.subCategories?[indexPath.row]
        
        let color: UIColor =  navigationBarView!.backgroundColor!
        let controller: SearchMerchandiseCategoryTableViewController = SearchMerchandiseCategoryTableViewController(color: color)
        
        controller.category = object
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
