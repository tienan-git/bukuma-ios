//
//  TimelineViewController.swift
//  Bukuma_ios_swift
//
//  Created by tani on 2017/05/30.
//  Copyright © 2017年 Labit Inc. All rights reserved.
//

open class MerchandiseCollectionViewController: HomeCollectionViewController {
    
    var url: String
    var pageTitle: String?
    var color: UIColor?
    
    public init(url: String, title: String? = nil, color: UIColor? = nil) {
        self.url = url
        self.pageTitle = title
        self.color = color
        
        super.init(nibName: nil, bundle: nil)
        
        (dataSource as? HomeDataSource)?.url = url
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = pageTitle
        self.title = pageTitle
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.contentInset.bottom = 0
        if let color = color {
            navigationBarView?.backgroundColor = color
        }
        viewReloadOnlyDataUpdated = true
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadCollectionView()
    }
    
    open override func completeRequest() {
        super.completeRequest()
        
        if pageTitle != nil { return }
        
        if let title = (dataSource as? HomeDataSource)?.title {
            pageTitle = title
            navigationBarTitle = pageTitle
            self.title = pageTitle
        }
    }
    
    override open func pullToRefreshInsetTop() -> CGFloat {
        return  NavigationHeightCalculator.navigationHeight()
    }
    
    override func collectionScrollBottom() ->CGFloat {
        return 0
    }
    
    override func registerStatusBarNotification() {}
}
