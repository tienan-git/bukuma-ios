//
//  MerchandiseHomeCollectionViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/04/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class MerchandiseHomeCollectionViewController: HomeCollectionViewController {
    
    var row: Int?
    var color: UIColor?
    
    override open func registerDataSourceClass() -> AnyClass? {
        return SearchTimelineDataSource.self
    }
    
    override open var category: Category? {
        didSet {
            if let category = self.category {
                
                (dataSource as? SearchTimelineDataSource)?.cateory = category
                
            }
        }
    }

    override open func initializeNavigationLayout() {
        self.navigationBarTitle = self.category?.categoryName
        self.title = self.category?.categoryName
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "このカテゴリーにはまだ商品はまだありません"
    }
    
    override open func pullToRefreshInsetTop() -> CGFloat {
        return  NavigationHeightCalculator.navigationHeight()
    }

    override func collectionScrollBottom() ->CGFloat {
        return 0
    }
    
    // ================================================================================
    // MARK: -init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(color: UIColor) {
        super.init(nibName: nil, bundle: nil)
        self.color = color
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.contentInset.bottom = 0
        navigationBarView?.backgroundColor = color
        viewReloadOnlyDataUpdated = true
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadCollectionView()
    }
    
    override func registerStatusBarNotification() {}

}
