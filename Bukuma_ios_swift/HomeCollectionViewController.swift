//
//  HomeCollectionView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/17.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import CollectionViewWaterfallLayout
import Firebase
import FirebaseAnalytics
import FirebaseMessaging

open class HomeCollectionViewController: BaseCollectionViewController, HomeCollectionCellDelegate, FeatureBookScrollViewDelegate {
    
    // ================================================================================
    // MARK: - property
    
    override var shouldShowRightNavigationButton: Bool {
        get {
            return true
        }
    }
    
    open var category: Category? {
        didSet {
            if let category = self.category {
                (dataSource as? HomeDataSource)?.category = category
            }
        }
    }
    
    open var isShowFeatureBooks: Bool = false {
        didSet {
            let layout: CollectionViewWaterfallLayout? =  collectionView?.collectionViewLayout as? CollectionViewWaterfallLayout
            if isShowFeatureBooks == true && layout != nil && collectionView != nil {
                layout!.sectionInset =  UIEdgeInsets(top: FeatureBookScrollViewViewsHeight, left: 10, bottom: 0, right: 10)
                collectionView?.collectionViewLayout = layout!
                collectionView?.reloadData()
            }
            
            scrollView?.isHidden =  !isShowFeatureBooks
            scrollView?.isUserInteractionEnabled = isShowFeatureBooks
        }
    }
    var scrollView: FeatureBookScrollView? = FeatureBookScrollView()
    
    // ================================================================================
    // MARK: - setting
    
    override open func registerDataSourceClass() -> AnyClass? {
        return HomeDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return HomeCollectionCell.self
    }
    
    override open func pullToRefreshInsetTop() -> CGFloat {
        return  NavigationHeightCalculator.navigationHeight() + 40.0
    }
    
    override open func emptyViewCenterPositionY() -> CGFloat {
        let contentWithBannerHeight: CGFloat = self.view.height - NavigationHeightCalculator.navigationHeight() - 40.0 - kAppDelegate.tabBarController.tabBar.height - FeatureBookScrollViewViewsHeight
        let contentWithBannerBottom: CGFloat = contentWithBannerHeight - kAppDelegate.tabBarController.tabBar.height
        return isShowFeatureBooks == true ?  (contentWithBannerBottom + contentWithBannerHeight) / 2 : super.emptyViewCenterPositionY()
    }
    
    // ================================================================================
    // MARK: -init
    
    deinit {
        scrollView = nil
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView?.delegate = self
        scrollView?.isUserInteractionEnabled = false
        collectionView?.addSubview(scrollView!)
        
        self.setBannerLayout(isShowFeatureBooks )
        
        self.collectionView?.contentInset.bottom =  kCommonTabBarHeight + 10.0
        self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
        self.collectionView?.scrollIndicatorInsets.bottom = self.collectionScrollBottom()
        
        self.registerStatusBarNotification()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: ExhibitTableViewControllerPostedMerchandiseKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFrame), name: Foundation.NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        
        //起動時リフレッシュ
        self.refreshDataSource()
        self.updateFrameWhenDidLoad()
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setBannerLayout(isShowFeatureBooks)
    }
    
    func registerStatusBarNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollToTop), name: NSNotification.Name(rawValue: AppDelegateStatusBarTapped), object: nil)
    }
    
    func reload() {
        self.refreshDataSource()
    }
    
    func setBanners (_ banners: [Banner]?) {
        self.scrollView?.banners = banners
    }
    
    func createBanners(_ completion: () ->Void) {
        scrollView?.createBanners(completion)
    }
    
    override open func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let object = dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Book
        
        if object == nil {
            return CollectionLoadMoreCell.loadMoreCellSize()
        }
        return HomeCollectionCell.cellHeightForObject(object)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let object = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Book
        
        self.goDetailBook(object ?? Book(), completion: nil)
    }
    
    open func homeCellLikeButtonTapped(_ cell: HomeCollectionCell, completion:@escaping (_ isLiked:Bool?, _ numLike: Int) ->Void) {
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
    
    public func featureBookScrollViewBannerTapped(_ view: FeatureBookScrollView, tag: Int, completion:@escaping () ->Void) {
        if view.banners?[tag].contentUrl == nil {
            completion()
            return
        }
        let controller: BaseWebViewController = BaseWebViewController(url: view.banners![tag].contentUrl!)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
        completion()
    }
    
    func setBannerLayout(_ isShowBanner: Bool) {
        let layout: CollectionViewWaterfallLayout? =  collectionView?.collectionViewLayout as? CollectionViewWaterfallLayout
        if isShowBanner == true && layout != nil && collectionView != nil {
            layout!.sectionInset = UIEdgeInsets(top: FeatureBookScrollViewViewsHeight, left: 10.0, bottom: 0, right: 10.0)
            collectionView!.collectionViewLayout = layout!
        }
        
        scrollView?.isHidden =  !isShowFeatureBooks
        scrollView?.isUserInteractionEnabled = isShowFeatureBooks
    }
    
    func updateFrame() {
        DispatchQueue.main.async {
            if NavigationHeightCalculator.isTethering() {
                self.collectionView?.contentInsetTop = NavigationHeightCalculator.navigationHeight() + 30.0
                self.collectionView?.changeScrollHeight(50.0, contentInsetTop: NavigationHeightCalculator.navigationHeight() + 30.0)
                self.collectionView?.contentInsetBottom = kCommonTabBarHeight + 40.0
                self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
                return
            }
            self.navigationBarView?.height = NavigationHeightCalculator.navigationHeight()
            self.collectionView?.contentInsetTop = NavigationHeightCalculator.navigationHeight() + 40.0
            self.collectionView?.changeScrollHeight(50.0, contentInsetTop: NavigationHeightCalculator.navigationHeight() + 40.0)
            self.collectionView?.contentInsetBottom = kCommonTabBarHeight + 10.0
            self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
        }
    }
    
    //デザリングしながら、アプリを初回起動したとき
    func updateFrameWhenDidLoad() {
        DispatchQueue.main.async {
            if NavigationHeightCalculator.isTethering() {
                self.navigationBarView?.height = NavigationHeightCalculator.navigationHeight() - 10.0
                self.collectionView?.contentInsetTop = NavigationHeightCalculator.navigationHeight()
                self.collectionView?.changeScrollHeight(50.0, contentInsetTop: NavigationHeightCalculator.navigationHeight())
                self.collectionView?.contentInsetBottom = kCommonTabBarHeight + 30.0
                self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
            }
        }
    }
}
