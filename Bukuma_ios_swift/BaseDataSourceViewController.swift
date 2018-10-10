//
//  BKMBaseDataSourceViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD

/**
 Dataを操作したいViewControllerのBaseになっており、
 主に、BaseTableViewControllerとBaseCollectionViewControllerで同じような処理をするために作られたClass
 BaseDataSourceDelegateやEmptyDataViewDelegateの処理をしている
 
 */


open class BaseDataSourceViewController: BaseViewController,
BaseDataSourceDelegate,
EmptyDataViewDelegate,
UIGestureRecognizerDelegate
{
    var dataSource: BaseDataSource? = nil
    var shouldRefreshWhenViewWillAppearOneTime: Bool?
    var emptyDataView: EmptyDataView?

    // ================================================================================
    // MARK: - setting
    
    deinit {
        emptyDataView = nil
        DBLog("-----------deinit BaseDataSourceViewController --------")
    }

    /**
    継承先のBaseTableViewControllerやBaseColelctionViewControllerで設定する
     DataSourceClass、CellClass
     
     */
    open func registerDataSourceClass() ->AnyClass? {
       return nil
    }
    
    open func registerCellClass() ->AnyClass? {
        return nil
    }
    
    open func pullToRefreshScrollHeight() ->CGFloat {
        return 50
    }
    
    open func pullToRefreshInsetTop() -> CGFloat{
        return NavigationHeightCalculator.navigationHeight()
    }
    
    var shouldRefreshDataSource: Bool {
        get {
            return self.dataSource != nil && (self.dataSource?.count() == 0 || self.dataSource?.isFinishFirstRefresh == false)
        }
    }
    
    var shouldReloadMainView: Bool {
        get {
            return self.dataSource != nil && !(self.dataSource?.count() == 0 && self.dataSource?.isFinishFirstRefresh == false)
        }
    }
    
    var shouldShowProgressHUDWhenDataSourceRefresh: Bool {
        get {
            return self.dataSource != nil && self.dataSource?.count() == 0
        }
    }
    
    func registerClasses() {
        if self.registerDataSourceClass() == nil {
            return
        }
        let registerDataSourceClass = self.registerDataSourceClass() as! BaseDataSource.Type
        self.dataSource = registerDataSourceClass.init()
        self.dataSource?.delegate = self
        
    }
    
    // ================================================================================
    // MARK: - emptyDataView delegate and func
    /**
    EmptyDataView class参照
     
     */
    
    open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return ""
    }
    
    open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return ""
    }
    
    open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage()
    }
    
    open func emptyViewCenterPositionY() -> CGFloat {
        return 0
    }
    
    func updateEmptyDataViewWithAnimationInfo(_ dic: [AnyHashable: Any])  {
        emptyDataView?.adjustEmptyViewWithAnimated(dic)
    }
    
    // ================================================================================
    // MARK: -init
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.registerClasses()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ================================================================================
    // MARK: -viewCycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        emptyDataView = EmptyDataView()
        emptyDataView?.delegate = self
        emptyDataView?.isHidden = true
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.shouldRefreshWhenViewWillAppearOneTime == true {
            self.shouldRefreshWhenViewWillAppearOneTime = false
            self.refreshDataSource()
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
     open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (self.navigationController?.interactivePopGestureRecognizer != nil
            && gestureRecognizer == self.navigationController!.interactivePopGestureRecognizer
            && self.navigationController!.viewControllers.count == 1){
            return false
        }
        return true
    }
    
    open func  completeRequest() {}
    
    open func failedRequest(_ error: Error) {}
    
    open func refreshDataSource() {
        DispatchQueue.main.async {
            if self.shouldShowProgressHUDWhenDataSourceRefresh == true {
                SVProgressHUD.show()
            }
            self.dataSource?.refreshDataSource()
        }
    }
    
    func goDetailBook(_ book: Book, completion: (() ->Void)?) {
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.show()

        DetailPageTableViewController.generate(for: book) { [weak self] (generatedViewController: DetailPageTableViewController?) in
            guard let viewController = generatedViewController else {
                SVProgressHUD.dismiss()
                self?.view.isUserInteractionEnabled = true
                completion?()
                return
            }
            self?.navigationController?.pushViewController(viewController, animated: true)

            SVProgressHUD.dismiss()
            self?.view.isUserInteractionEnabled = true
            completion?()
        }
    }
}
