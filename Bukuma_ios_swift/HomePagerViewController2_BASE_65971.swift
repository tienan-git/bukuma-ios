//
//  HomePagerViewController2.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2017/01/18.
//  Copyright © 2017年 Hiroshi Chiba. All rights reserved.
//

import CollectionViewWaterfallLayout
import SVProgressHUD
import RMUniversalAlert

/**
 やることリスト、activityのBarButtonの赤いBadge
 */
class NotificationBadge2: UIImageView {
    
    required override public init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIImage(named: "ic_nav_badge")!.size.width, height: UIImage(named: "ic_nav_badge")!.size.height))
        self.clipsToBounds = true
        self.image = UIImage(named: "ic_nav_badge")
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.red.cgColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomePagerBarButtonItem2: BarButtonItem {
    
    var badgeView: NotificationBadge2?
    var contentAvailable: Bool? {
        didSet {
            _ = contentAvailable.map { badgeView?.isHidden = !$0}
        }
    }
    
    open class func barButtonItem(_ image: UIImage, target: AnyObject, action: Selector) ->HomePagerBarButtonItem2 {
        let dummyItem = BarButtonItem.barButtonItemWithImage(image, isLeft: false, target: target, action: action)
        let barButtonItem = HomePagerBarButtonItem2.init(customView: dummyItem.customView!)
        
        barButtonItem.badgeView = NotificationBadge2(frame: CGRect.zero)
        barButtonItem.badgeView?.isHidden = true
        barButtonItem.customView?.viewSize = CGSize(width: image.size.width, height: image.size.height)
        barButtonItem.customView?.addSubview(barButtonItem.badgeView!)
        
        return barButtonItem
    }
}

/**
 タイムライン
 */
class HomePagerViewController2 : BaseViewController {
    
    fileprivate var pagerHeaderView: PagerHeaderView!
    fileprivate var scrollView: UIScrollView!
    fileprivate var serchBarTextField: UITextField!
    fileprivate var serchBar: BukumaSearchBar!
    fileprivate var searchText: String?
    fileprivate var tableView: BaseTableView!
    fileprivate var blarView: UIView!
    fileprivate var searchView: UIView!
    
    fileprivate let scrollViewTag: Int = 1800
    fileprivate let searchTableTag: Int = 1200
    
    fileprivate var lastScrollY: CGFloat = 0
    fileprivate var currentPageIndex: Int = 0
    fileprivate var activeTag: Int = 0
    
    fileprivate var categories: [Category] = []
    fileprivate var bannerViews: [FeatureBookView] = []
    
    fileprivate var searchDataSource: SearchBookDataSource!
    
    fileprivate var todoListButton: UIBarButtonItem?
    fileprivate var activityButton: UIBarButtonItem?
    
    fileprivate enum TableViewRow: Int {
        case searchHistoryContents
        case searchBooks
        case deleteHistoryCacshe
        case unexpect
    }
    
    fileprivate var isSearching: Bool = false {
        didSet {
            if isSearching == false {
                searchDataSource?.cancelTimer()
                searchDataSource?.searchText = nil
            }
        }
    }
    
    fileprivate var shouldReloadSection: Bool {
        return self.page(at: currentPageIndex) == 1 || self.page(at: currentPageIndex) == 0
    }
    
    fileprivate var allCollectionView: UICollectionView!
    fileprivate var publishCollectionView: UICollectionView!
    fileprivate var bulkCollectionView: UICollectionView!
    fileprivate var priceCollectionView: UICollectionView!
    
    fileprivate var allEmptyView: EmptyDataView!
    fileprivate var publishEmptyView: EmptyDataView!
    fileprivate var bulkEmptyView: EmptyDataView!
    fileprivate var priceEmptyView: EmptyDataView!
    
    fileprivate var allDataSource: HomeDataSource!
    fileprivate var publishDataSource: HomeDataSource!
    fileprivate var bulkDataSource: HomeDataSource!
    fileprivate var priceDataSource: HomeDataSource!

    fileprivate let searchNavigationHeight: CGFloat = NavigationHeightCalculator.navigationHeight() + BukumaSearchBar.searchBarHeight - BukumaSearchBar.searchHeightAdjuster

    func collectionView(page: Int) ->UICollectionView {
        switch page {
        case 0:
            return allCollectionView
        case 1:
            return publishCollectionView
        case 2:
            return bulkCollectionView
        case 3:
            return priceCollectionView
        default:
            fatalError()
        }
    }
    
    func emptyDataView(page: Int) ->EmptyDataView {
        switch page {
        case 0:
            return allEmptyView
        case 1:
            return publishEmptyView
        case 2:
            return bulkEmptyView
        case 3:
            return priceEmptyView
        default:
            fatalError()
        }
    }
    
    func collectionDataSource(page: Int) ->HomeDataSource {
        switch page {
        case 0:
            return allDataSource
        case 1:
            return publishDataSource
        case 2:
            return bulkDataSource
        case 3:
            return priceDataSource
        default:
            fatalError()
        }
    }
    
    var isShowFeatureBooks: Bool = false {
        didSet {
            
            for i in 0..<4 {
                let layout: CollectionViewWaterfallLayout? =  self.collectionView(page: i).collectionViewLayout as? CollectionViewWaterfallLayout
                if isShowFeatureBooks == true && layout != nil {
                    let topInset = Banner.bannersCount == 0 ? 10 : FeatureBookView.bannerViewHeight
                    layout!.sectionInset =  UIEdgeInsets(top: topInset, left: 10, bottom: 0, right: 10)
                    self.collectionView(page: i).collectionViewLayout = layout!
                    self.collectionView(page: i).reloadData()
                }
                
                for b in bannerViews {
                    b.isHidden = !isShowFeatureBooks
                    b.isUserInteractionEnabled = isShowFeatureBooks
                }
            }
        }
    }
    
    override var shouldShowRightNavigationButton: Bool {
        get {
            return true
        }
    }
    
    override func setNavigationBarButton(_ barButton: UIBarButtonItem?, isLeft: Bool) {
        var buttonController: UIViewController = kAppDelegate.drawerViewController.mainViewController
        
        let todoListButton: UIBarButtonItem = HomePagerBarButtonItem2.barButtonItem(UIImage(named: "ic_nav_check")!,
                                                                                   target: self,
                                                                                   action: #selector(self.todoListButtonTapped(_:)))
        (todoListButton as? HomePagerBarButtonItem2)?.badgeView?.x = 7.0
        (todoListButton.customView as? UIButton)?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 7.0, bottom: 0, right: -7.0)
        
        let activityButton: UIBarButtonItem = HomePagerBarButtonItem2.barButtonItem(UIImage(named: "ic_nav_bell")!,
                                                                                   target: self,
                                                                                   action: #selector(self.self.activityButtonTapped(_:)))
        (activityButton.customView as? UIButton)?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: -10.0)
        (activityButton as? HomePagerBarButtonItem2)?.badgeView?.x = 10.0
        
        if buttonController is UINavigationController {
            let nav = buttonController as! UINavigationController
            if nav.viewControllers.count > 0 {
                buttonController = nav.viewControllers[0]
            }
            buttonController.navigationItem.rightBarButtonItems = [todoListButton, activityButton]
        }
    }
    
    open func setContentAvailable(_ isActivity: Bool, contentAvailable: Bool) {
        var buttonController: UIViewController? = kAppDelegate.drawerViewController.mainViewController
        
        if buttonController is UINavigationController {
            let nav = buttonController as? UINavigationController
            if (nav?.viewControllers.count ?? 0) > 0 {
                buttonController = nav?.viewControllers[0]
            }
        }
        
        if (buttonController?.navigationItem.rightBarButtonItems as? [BarButtonItem]) is [HomePagerBarButtonItem2] {
            let activity: HomePagerBarButtonItem2? = buttonController?.navigationItem.rightBarButtonItems?[1] as? HomePagerBarButtonItem2
            let todo: HomePagerBarButtonItem2? = buttonController?.navigationItem.rightBarButtonItems?[0] as? HomePagerBarButtonItem2
            if isActivity {
                activity?.contentAvailable = contentAvailable
                return
            }
            todo?.contentAvailable = contentAvailable
        }
    }
    
    override open func initializeNavigationLayout() {
        self.setNavigationBarButton(nil, isLeft: false)
    }

    func todoListButtonTapped(_ sender: UIBarButtonItem) {
        if Me.sharedMe.isRegisterd == false {
            self.showUnRegisterAlert()
            return
        }
        
        let controller: TransactionListTableViewController = TransactionListTableViewController()
        let navi = NavigationController.init(rootViewController: controller)
        self.present(navi, animated: true, completion: nil)
    }
    
    func activityButtonTapped(_ sender: UIBarButtonItem) {
        if Me.sharedMe.isRegisterd == false {
            self.showUnRegisterAlert()
            return
        }
        
        let controller: ActivityViewController = ActivityViewController()
        let navi = NavigationController.init(rootViewController: controller)
        self.present(navi, animated: true, completion: nil)
    }
    
    func toggeleUpdateActivity(_ update: Bool) {
        if update {
            self.setContentAvailable(true, contentAvailable: true)
            return
        }
        self.setContentAvailable(true, contentAvailable: false)
    }
    
    func toggeleUpdateTransaction(_ update: Bool) {
        if update {
            self.setContentAvailable(false, contentAvailable: true)
            return
        }
        self.setContentAvailable(false, contentAvailable: false)
    }

    required public init(categories: Array<Category>) {
        super.init(nibName: nil, bundle: nil)
        self.categories = categories
        
        searchDataSource = SearchBookDataSource()
        searchDataSource.delegate = self
        
        allDataSource = HomeDataSource()
        allDataSource.cateory = categories[0]
        allDataSource.tabIndex = 0
        allDataSource.delegate = self
        
        publishDataSource = HomeDataSource()
        publishDataSource.cateory = categories[1]
        publishDataSource.tabIndex = 1
        publishDataSource.delegate = self
        
        bulkDataSource = HomeDataSource()
        bulkDataSource.cateory = categories[2]
        bulkDataSource.tabIndex = 2
        bulkDataSource.delegate = self
        
        priceDataSource = HomeDataSource()
        priceDataSource.cateory = categories[3]
        priceDataSource.tabIndex = 3
        priceDataSource.delegate = self

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.width = kCommonDeviceWidth * 4
        
        scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.scrollsToTop = false
        scrollView.tag = scrollViewTag
        scrollView.contentSizeWidth = kCommonDeviceWidth * 4
        scrollView.clipsToBounds = false
        scrollView.isUserInteractionEnabled = true
        self.view.insertSubview(scrollView, belowSubview: navigationBarView!)
        
        navigationBarView?.x = 0
        navigationBarView?.width = kCommonDeviceWidth
        navigationBarView?.height = self.searchNavigationHeight
        navigationBarView?.clipsToBounds = true
        
        pagerHeaderView = PagerHeaderView(delegate: self)
        pagerHeaderView.y = self.searchNavigationHeight
        self.view.addSubview(pagerHeaderView)
        
        allCollectionView = self.generateCollectionView()
        allCollectionView.x = 0
        allCollectionView.tag = 0
        allCollectionView.register(HomeCollectionCell.self, forCellWithReuseIdentifier:"\(String(describing: HomeCollectionCell.self))\(allCollectionView.tag)")
        allCollectionView.register(CollectionLoadMoreCell.self, forCellWithReuseIdentifier: "\(String(describing: CollectionLoadMoreCell.self))\(allCollectionView.tag)")
        
        allEmptyView = EmptyDataView()
        allEmptyView.delegate = self
        allEmptyView.isHidden = true
        allCollectionView.addSubview(allEmptyView)
        allEmptyView.adjustEmptyView()
        
        let allBanner = FeatureBookView()
        allBanner.delegate = self
        allCollectionView.addSubview(allBanner)
        
        scrollView.addSubview(allCollectionView)
        
        publishCollectionView = self.generateCollectionView()
        publishCollectionView.x = kCommonDeviceWidth
        publishCollectionView.tag = 1
        publishCollectionView.register(HomeCollectionCell.self, forCellWithReuseIdentifier:"\(String(describing: HomeCollectionCell.self))\(publishCollectionView.tag)")
        publishCollectionView.register(CollectionLoadMoreCell.self, forCellWithReuseIdentifier: "\(String(describing: CollectionLoadMoreCell.self))\(publishCollectionView.tag)")
        
        publishEmptyView = EmptyDataView()
        publishEmptyView.delegate = self
        publishEmptyView.isHidden = true
        publishCollectionView.addSubview(publishEmptyView)
        publishEmptyView.adjustEmptyView()
        
        let publishBanner = FeatureBookView()
        publishBanner.delegate = self
        publishCollectionView.addSubview(publishBanner)
        
        scrollView.addSubview(publishCollectionView)
        
        bulkCollectionView = self.generateCollectionView()
        bulkCollectionView.x = kCommonDeviceWidth * 2
        bulkCollectionView.tag = 2
        bulkCollectionView.register(HomeCollectionCell.self, forCellWithReuseIdentifier:"\(String(describing: HomeCollectionCell.self))\(bulkCollectionView.tag)")
        bulkCollectionView.register(CollectionLoadMoreCell.self, forCellWithReuseIdentifier: "\(String(describing: CollectionLoadMoreCell.self))\(bulkCollectionView.tag)")
        
        bulkEmptyView = EmptyDataView()
        bulkEmptyView.delegate = self
        bulkEmptyView.isHidden = true
        bulkCollectionView.addSubview(bulkEmptyView)
        bulkEmptyView.adjustEmptyView()
        
        let bulkBanner = FeatureBookView()
        bulkBanner.delegate = self
        bulkCollectionView.addSubview(bulkBanner)
        
        scrollView.addSubview(bulkCollectionView)
        
        priceCollectionView = self.generateCollectionView()
        priceCollectionView.x = kCommonDeviceWidth * 3
        priceCollectionView.tag = 3
        priceCollectionView.register(HomeCollectionCell.self, forCellWithReuseIdentifier:"\(String(describing: HomeCollectionCell.self))\(priceCollectionView.tag)")
        priceCollectionView.register(CollectionLoadMoreCell.self, forCellWithReuseIdentifier: "\(String(describing: CollectionLoadMoreCell.self))\(priceCollectionView.tag)")
        
        priceEmptyView = EmptyDataView()
        priceEmptyView.delegate = self
        priceEmptyView.isHidden = true
        priceCollectionView.addSubview(priceEmptyView)
        priceEmptyView.adjustEmptyView()
        
        let priceBanner = FeatureBookView()
        priceBanner.delegate = self
        priceCollectionView.addSubview(priceBanner)

        scrollView.addSubview(priceCollectionView)
        
        scrollView.isHidden = true
        
        bannerViews.append(allBanner)
        bannerViews.append(publishBanner)
        bannerViews.append(bulkBanner)
        bannerViews.append(priceBanner)
        
        searchView = UIView()
        let y = NavigationHeightCalculator.navigationHeight() - BukumaSearchBar.searchHeightAdjuster
        searchView.frame = CGRect(x: 0, y: y, width: kCommonDeviceWidth, height: BukumaSearchBar.searchBarHeight)
        navigationBarView!.addSubview(searchView)
        
        serchBar = BukumaSearchBar(frame: CGRect(x: 0 , y: 0, width: kCommonDeviceWidth, height: BukumaSearchBar.searchBarHeight))
        serchBar.delegate = self
        searchView.addSubview(serchBar)
        
        serchBarTextField = serchBar.textField!

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapView(_:)))
        tapGesture.cancelsTouchesInView = false
        serchBar.addGestureRecognizer(tapGesture)
        
        tableView = BaseTableView()
        tableView.frame = self.view.bounds
        tableView.tableViewDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = kBorderColor
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.bounces = true
        tableView.isFixTableScrollWhenChangeContentsSize = true
        tableView.separatorStyle = .none
        tableView.tag = searchTableTag
        
        isNeedKeyboardNotification = true
        self.view.insertSubview(tableView, belowSubview: navigationBarView!)
        
        tableView.y = self.searchNavigationHeight
        tableView.isHidden = true
        
        blarView = UIView()
        blarView.frame = CGRect(x: 0, y: NavigationHeightCalculator.navigationHeight(), width: kCommonDeviceWidth, height: kCommonDeviceHeight)
        blarView.backgroundColor = kBackGroundColor
        blarView.isHidden = true
        self.view.insertSubview(blarView, belowSubview: tableView)
        blarView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeTableView), name: NSNotification.Name(rawValue: KYDrawerControllerAfterDidButtonTapped), object: nil)
        
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.gesuture(_:)))
        gesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gesture)

        self.refreshAllCollection()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.toggeleUpdateActivity(AppDelegate.shouldUpdateActivity)
        self.toggeleUpdateTransaction(AppDelegate.shouldUpdateTransaction)

        self.reloadCollectionView()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        searchDataSource?.searchText = nil

        SearchHistoryCache.shared.isMoreShowNext = false
    }

    /**
     カテゴリTabのanimationが終わったら呼ばれる
     */
    
    fileprivate func didFinishAnimation() {
        if Utility.isEmpty(categories) {
            return
        }

        let parameter: [String: AnyObject] = ["category_id": categories[currentPageIndex].id as AnyObject,
                                              "category_name": categories[currentPageIndex].categoryName as AnyObject]
        AnaliticsManager.sendAction("timeline",
                                    actionName: "poplar_category",
                                    label: "",
                                    value: 1,
                                    dic: parameter)
    }

    override func keyboardDidShow(_ notification: Foundation.Notification) {
        let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as!NSValue).cgRectValue
        tableView.viewSize = CGSize(width: kCommonDeviceWidth, height: kCommonDeviceHeight - keyboardFrame.height)
    }
    
    override func keyboardDidHide(_ notification: Foundation.Notification) {
        super.keyboardDidHide(notification)
        tableView.viewSize = CGSize(width: kCommonDeviceWidth, height: kCommonDeviceHeight)
        tableView.contentInsetBottom = kAppDelegate.tabBarController.tabBar.height
    }
}

/**
  PagerHeaderView参考
  Tabをselectしたときに呼ばれる
 */
extension HomePagerViewController2: PagerHeaderViewDelegate {
    
    func pagerHeaderView(didSelectHeaderMenu type: PagerHeaderViewType) {
        currentPageIndex = type.rawValue
        var frame: CGRect = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(currentPageIndex)
        frame.origin.y = 0
        UIView.animate(withDuration:0.25, animations: {
            self.scrollView.contentOffsetX = frame.origin.x
            let startScrollPoint: CGFloat = -147.0
            let stopScrollPoint: CGFloat = startScrollPoint - self.pullToRefreshScrollHeight()
            
            if (self.collectionView(page: self.currentPageIndex).contentOffsetY <= startScrollPoint &&
                self.collectionView(page: self.currentPageIndex).contentOffsetY > stopScrollPoint) {
                self.initialSearchBarPosition()
            }
        }) { (finish) in
            self.didFinishAnimation()
            self.lastScrollY = self.collectionView(page: self.currentPageIndex).contentOffsetY
        }
    }
}

/**
  横にScrollしてPagerHeaderViewTypeを適切なLayoutにしている
  collectionView, TableViewなど、ScrollViewが多いので、競合しないように、
 */
extension HomePagerViewController2 {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView {
            self.scrollSearchBar(scrollView)
            return
        }
    
        let offset: CGPoint = scrollView.contentOffset
        let page: Int = (offset.x.int() + kCommonDeviceWidth.int() / 2) / kCommonDeviceWidth.int()
        
        if currentPageIndex != page {
            currentPageIndex = page
            let type = PagerHeaderViewType(rawValue: currentPageIndex) ?? PagerHeaderViewType.all
            pagerHeaderView.move(selectType: type)
            lastScrollY = self.collectionView(page: currentPageIndex).contentOffsetY
            
            let startScrollPoint: CGFloat = -147.0
            let stopScrollPoint: CGFloat = startScrollPoint - self.pullToRefreshScrollHeight()
            
            if (self.collectionView(page: currentPageIndex).contentOffsetY <= startScrollPoint &&
                self.collectionView(page: currentPageIndex).contentOffsetY > stopScrollPoint) {
                UIView.animate(withDuration: 0.25, animations: {
                    self.initialSearchBarPosition()
                })
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView {
            return
        }
        self.didFinishAnimation()
    }
    
    /**
     縦にscrollした時、検索Barがanimationして隠れたり出たり処理
     */
    
    func scrollSearchBar(_ scrollView: UIScrollView) {
        
        guard let view = navigationBarView else { return }
    
        let gap: CGFloat = lastScrollY - scrollView.contentOffsetY
        if scrollView.isDragging {
            lastScrollY = scrollView.contentOffsetY
        }
        
        let minHeight: CGFloat = NavigationHeightCalculator.navigationHeight()
        let maxHeight: CGFloat = self.searchNavigationHeight
        
        let startScrollPoint: CGFloat = -147.0
        
        if lastScrollY <= startScrollPoint {
            view.height = maxHeight
            pagerHeaderView.y = self.searchNavigationHeight
            return
        }
        
        if  gap < 0 {
            if scrollView.isDragging == false {
                return
            }
            UIView.animate(withDuration: 0.25, animations: {
                view.height = minHeight
                self.pagerHeaderView.y = NavigationHeightCalculator.navigationHeight()
            })
        } else {
            if scrollView.isDragging == false {
                return
            }
            UIView.animate(withDuration: 0.25, animations: {
                view.height = maxHeight
                self.pagerHeaderView.y = self.searchNavigationHeight
            })
        }
    }

    func initialSearchBarPosition() {
        self.navigationBarView?.height = self.searchNavigationHeight
        self.pagerHeaderView.y = self.searchNavigationHeight
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        if let barView = self.navigationBarView {
            var frame = barView.frame
            frame.size.height = self.searchNavigationHeight

            UIView.animate(withDuration: 0.25) {
                barView.frame = frame
                self.pagerHeaderView.y = self.searchNavigationHeight
            }
        }
    }
}

// ================================================================================
// MARK:- collectionView layout

extension HomePagerViewController2 {
     fileprivate func generateCollectionView() ->UICollectionView {
        let layout = CollectionViewWaterfallLayout()
        layout.columnCount = 2
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10)
        
        let collectionView = UICollectionView(frame: CGRect(x:0, y:0 , width:kCommonDeviceWidth, height:kCommonDeviceHeight), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = kBackGroundColor
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset.top = self.pullToRefreshInsetTop()
        collectionView.contentInsetBottom  = self.collectionScrollBottom()
        collectionView.scrollsToTop = true

        collectionView.addPull(toRefreshScrollHeight: self.pullToRefreshScrollHeight(),
                               contentInsetTop: self.pullToRefreshInsetTop()) {[weak self] () in
                                self?.refreshCollectionDataSource()
        }
        
        return collectionView
    }

    fileprivate func pullToRefreshInsetTop() ->CGFloat {
        return self.searchNavigationHeight + PagerHeaderView.headerMenuHeight()
    }
    
    fileprivate func pullToRefreshScrollHeight() ->CGFloat {
        return 50.0
    }

    fileprivate func collectionScrollBottom() ->CGFloat {
        return 50.0 + 10.0
    }
}

extension HomePagerViewController2: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        activeTag = collectionView.tag
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        activeTag = collectionView.tag
        return self.count(at: activeTag)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        activeTag = collectionView.tag
        
        var cellIdentifier = ""
        var cell: UICollectionViewCell?
        let book: Book? = self.data(at: indexPath.row, page: activeTag, isAllowUpdate: true)
        
        if book == nil {
            cellIdentifier = "\(String(describing: CollectionLoadMoreCell.self))\(activeTag)"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CollectionLoadMoreCell
            if cell == nil {
                cell = CollectionLoadMoreCell()
            }
        } else {
            cellIdentifier = "\(String(describing: HomeCollectionCell.self))\(activeTag)"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? HomeCollectionCell
            if cell == nil {
                cell = HomeCollectionCell(frame: CGRect.zero)
            }
            (cell as? HomeCollectionCell)?.delegate = self
            (cell as? HomeCollectionCell)?.cellModelObject = book
        }
        
        return cell!
    }

}

extension HomePagerViewController2: CollectionViewWaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        activeTag = collectionView.tag
        let book = self.data(at: indexPath.row, page: activeTag, isAllowUpdate: false)
        if book == nil {
            return CollectionLoadMoreCell.loadMoreCellSize()
        }
        return HomeCollectionCell.cellHeightForObject(book)
    }
}

extension HomePagerViewController2: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        activeTag = collectionView.tag
        let book = self.data(at: indexPath.row, page: activeTag, isAllowUpdate: false)
        
        guard let b = book else { return }
        self.goDetailBook(b)
    }
}

extension HomePagerViewController2: HomeCollectionCellDelegate {
    func homeCellLikeButtonTapped(_ cell: HomeCollectionCell, completion:@escaping (_ isLiked:Bool?, _ numLike: Int) ->Void) {
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


extension HomePagerViewController2: EmptyDataViewDelegate {
    func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "表示するコンテンツがありません"
    }
    
    func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return "表示するコンテンツがありません"
    }
    
    func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "img_ph_00")
    }
    
    func emptyViewCenterPositionY() -> CGFloat {
        let contentHeight: CGFloat = self.view.height - NavigationHeightCalculator.navigationHeight() - 36.0 - kAppDelegate.tabBarController.tabBar.height
        return (contentHeight - self.pullToRefreshInsetTop()) / 2
    }
}

// ================================================================================
// MARK: - UISearchBarDelegate
extension HomePagerViewController2: UISearchBarDelegate {
    
    func searchBarDidTapped(_ isResignFirstResponder: Bool) {
        if isResignFirstResponder == true {
            self.closeTableView()
            serchBar?.setShowsCancelButton(false, animated: true)
            return
        }
        
        self.showTableView()
    }
    
    open func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        serchBar?.setShowsCancelButton(true, animated: true)
        self.showTableView()
        return true
    }
    
    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        
        isSearching = self.searchText?.length != 0
        
        searchDataSource.setNewSearchText(searchText, completion: {
            self.searchDataSource.getFromOurServer()
        })
    }
    
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchText = searchBar.text

        if Utility.isEmpty(searchText) {
            return
        }
        
        SearchHistoryCache.shared.addHistory(searchText)
        SVProgressHUD.show()

        if TempEhonSearch.isEhon(searchWord: self.searchText!) {
            TempEhonSearch.showEhonCategory(on: self)
        } else {
            AnaliticsManager.sendAction("search",
                                        actionName: "search_book",
                                        label: searchText!,
                                        value: 1,
                                        dic: ["searchText": searchText as AnyObject])

            let controller: SearchMerchandiseBookGridViewController = SearchMerchandiseBookGridViewController(text: searchText!)
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        serchBar?.setShowsCancelButton(false, animated: true)
        serchBar?.resignFirstResponder()
        isSearching = false
        
        self.closeTableView()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonTapped(_ sender: UIButton) {
        serchBar?.setShowsCancelButton(false, animated: true)
        serchBar?.resignFirstResponder()
        isSearching = false
        
        self.closeTableView()
        tableView.reloadData()
    }
    
    open func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
}


// ================================================================================
// MARK: -  TableView DataSource

extension HomePagerViewController2: UITableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return  2
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isSearching == true ?  searchDataSource.count() ?? 0 : SearchHistoryCache.shared.count()
        }
        if SearchHistoryCache.shared.count() == 0 {
            return 0
        }
        return isSearching == true ? 0 : 1
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? SearchTextHistoryCell.cellHeightForObject(nil) : SearchDeleteHistroyCell.cellHeightForObject(nil)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch self.tableViewShowableRow(indexPath) {
        case .searchHistoryContents:
            cellIdentifier = NSStringFromClass(SearchTextHistoryCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?SearchTextHistoryCell
            if cell == nil {
                cell = SearchTextHistoryCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            if SearchHistoryCache.shared.count() >= indexPath.row {
                (cell as? SearchTextHistoryCell)?.title = SearchHistoryCache.shared.historyName(indexPath.row)
            }
            break
        case .searchBooks:
            cellIdentifier = NSStringFromClass(SearchTextHistoryCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?SearchTextHistoryCell
            if cell == nil {
                cell = SearchTextHistoryCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            
            let book: Book? = searchDataSource.dataAtIndex(indexPath.row, isAllowUpdate: true) as? Book
            if Utility.isEmpty(book?.identifier) {
                assert(true)
            }
            (cell as? SearchTextHistoryCell)?.cellModelObject = book
            break
        case .deleteHistoryCacshe:
            cellIdentifier = NSStringFromClass(SearchDeleteHistroyCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?SearchDeleteHistroyCell
            if cell == nil {
                cell = SearchDeleteHistroyCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            break
        case .unexpect:
            break
        }
        return cell ?? UITableViewCell()
    }
}

// ================================================================================
// MARK: -  TableView Delegate

extension HomePagerViewController2: UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch self.tableViewShowableRow(indexPath) {
            
        case .searchBooks:
            
            let book: Book = searchDataSource.dataAtIndex(indexPath.row, isAllowUpdate: false) as! Book
            searchText = book.titleText()
            
            AnaliticsManager.sendAction("search",
                                        actionName: "search_book",
                                        label: searchText ?? "",
                                        value: 1,
                                        dic: ["searchText": searchText as AnyObject])
            
            SearchHistoryCache.shared.addHistory(searchText)
            
            self.goDetailBook(book)
            
            break
        case .searchHistoryContents:
            
            serchBarTextField.text = SearchHistoryCache.shared.histories?[indexPath.row]
            self.goSearchGridViewController(serchBarTextField.text)
            
            break
        case .deleteHistoryCacshe:
            self.showDeleteHistoryAlert()
            break
        default:
            break
        }
    }
}

extension HomePagerViewController2: BaseTableViewDelegate {
    open func footerHeight() -> CGFloat {
        if tableView.height == kCommonDeviceHeight {
            return kAppDelegate.tabBarController.tabBar.height * 3
        }
        return kAppDelegate.tabBarController.tabBar.height * 2 + 14.0
    }
    
    open func scrollIndicatorInsetBottom() ->CGFloat {
        if tableView.height == kCommonDeviceHeight {
            return kAppDelegate.tabBarController.tabBar.height * 2 + 14.0
        }
        return kAppDelegate.tabBarController.tabBar.height  + 14.0
    }
}

extension HomePagerViewController2: BaseTableViewCellDelegate { }

// ================================================================================
// MARK:- DataSource Delegate & Data Source Medhod
extension HomePagerViewController2: BaseDataSourceDelegate {
    func completeRequest() {}
    
    func completeRequest(_ dataSource: BaseDataSource) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
            self.collectionView(page: self.currentPageIndex).pullToRefreshView.stopAnimating()
            SVProgressHUD.dismiss()
            
            if let page = (dataSource as? HomeDataSource)?.tabIndex {
                if page == 0 {
                    self.scrollView.isHidden = false
                }
                self.collectionView(page: page).reloadData()
            }

            self.emptyDataView(page: self.currentPageIndex).isHidden = self.count(at: self.currentPageIndex) > 0
            self.collectionView(page: self.currentPageIndex).scrollIndicatorInsets =  self.collectionView(page: self.currentPageIndex).contentInset
            self.collectionView(page: self.currentPageIndex).scrollIndicatorInsets.bottom = self.collectionScrollBottom()

            self.lastScrollY = self.collectionView(page: self.currentPageIndex).contentOffsetY
        }
    }
    
    func failedRequest(_ error: Error) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
            self.collectionView(page: self.currentPageIndex).pullToRefreshView.stopAnimating()
            SVProgressHUD.dismiss()

            self.reloadCollectionView()

            self.emptyDataView(page: self.currentPageIndex).isHidden = self.count(at: self.currentPageIndex) > 0
            self.collectionView(page: self.currentPageIndex).scrollIndicatorInsets =  self.collectionView(page: self.currentPageIndex).contentInset
            self.collectionView(page: self.currentPageIndex).scrollIndicatorInsets.bottom = self.collectionScrollBottom()
        }
    }

    func refreshSearchDataSource() {
        searchDataSource.refreshDataSource()
    }
    
    func refreshCollectionDataSource() {
        DispatchQueue.main.async {
            if self.shouldShowProgressHUDWhenDataSourceRefresh(at: self.currentPageIndex) == true {
                SVProgressHUD.show()
            }
            self.refreshCollectionDataSource(with: self.currentPageIndex)
        }
    }
    
    fileprivate func refreshCollectionDataSource(with category: Category) {
        
    }
    
    fileprivate func refreshCollectionDataSource(with page: Int) {
        self.collectionDataSource(page: page).refreshDataSource()
    }
    
    fileprivate func refreshAllCollection() {
        for i in 0..<4 {
            self.collectionDataSource(page: i).refreshDataSource()
        }
    }
    
    fileprivate func reloadCollectionView() {
        if self.shouldReloadMainView(at: currentPageIndex) {
            self.collectionView(page: currentPageIndex).reloadData()
        }
        if self.shouldRefreshDataSource(at: currentPageIndex) == true {
            self.refreshCollectionDataSource()
        }
    }
    
    fileprivate func data(at row: Int, page: Int, isAllowUpdate: Bool) ->Book? {
       return self.collectionDataSource(page: page).dataAtIndex(row, isAllowUpdate: isAllowUpdate) as? Book
    }
    
    fileprivate func count(at page: Int) ->Int {
        return self.collectionDataSource(page: page).count() ?? 0
    }
    
    fileprivate func page(at page: Int) ->Int {
        return self.collectionDataSource(page: page).page
    }
    
    fileprivate func shouldReloadMainView(at page: Int) ->Bool {
        let dataSource = self.collectionDataSource(page: page)
        return !(dataSource.count() == 0 && dataSource.isFinishFirstRefresh == false)
    }
    
    fileprivate func shouldRefreshDataSource(at page: Int) ->Bool {
        let dataSource = self.collectionDataSource(page: page)
        return (dataSource.count() == 0 || dataSource.isFinishFirstRefresh == false)
    }
    
    fileprivate func shouldShowProgressHUDWhenDataSourceRefresh(at page: Int) ->Bool {
        let dataSource = self.collectionDataSource(page: page)
        return dataSource.count() == 0
    }
}

// ================================================================================
// MARK: - UITapGestureRecognizer
extension HomePagerViewController2 {
    
    func tapView(_ sender: UITapGestureRecognizer) {
        if serchBar.isFirstResponder == true {
            serchBar.resignFirstResponder()
            self.searchBarDidTapped(true)
            return
        }
        serchBar.becomeFirstResponder()
        self.searchBarDidTapped(false)
    }
    
    func gesuture(_ sender: UITapGestureRecognizer) {
        let contentHeight: CGFloat = tableView.contentSizeHeight
        let visibleBluerViewRect: CGRect = CGRect(x: 0,
                                                  y: self.searchNavigationHeight + tableView.contentSizeHeight,
                                                  width: kCommonDeviceWidth,
                                                  height: tableView.height - contentHeight)
        
        if contentHeight < tableView.height {
            let location = sender.location(ofTouch: 0, in: self.view)
            if location.y > visibleBluerViewRect.origin.y {
                self.closeTableView()
            }
        }
    }
}

extension HomePagerViewController2 {
    
    fileprivate func showTableView() {
        pagerHeaderView.isHidden = true
        self.collectionView(page: currentPageIndex).pullToRefreshView.isHidden = true
        
        blarView.alpha = 0.0
        blarView.isHidden = false
        blarView.isUserInteractionEnabled = true
        tableView.isHidden = false
        isSearching = false
        searchDataSource.cancelTimer()
        searchDataSource.searchText = nil
        tableView.isHidden = false
        tableView.isUserInteractionEnabled = true
        tableView.reloadData()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.blarView.alpha = 1.0
        }) { (isFinish) in
            self.serchBar.becomeFirstResponder()
        }
    }
    
    @objc fileprivate func closeTableView() {
        SearchBookDataSource.retryCount = 0
        searchDataSource.cancelTimer()
        searchDataSource.searchText = nil
        self.collectionView(page: currentPageIndex).pullToRefreshView.isHidden = false
        
        serchBar.resignFirstResponder()
        serchBar.setShowsCancelButton(false, animated: true)
        blarView.isHidden = true
        blarView.isUserInteractionEnabled = false
        SearchHistoryCache.shared.addHistory(searchText.flatMap{$0})
        
        tableView.isHidden = true
        tableView.isUserInteractionEnabled = false
        tableView?.reloadData()
        pagerHeaderView.isHidden = false
        
    }
    
    fileprivate func tableViewShowableRow(_ indexPath:IndexPath) ->TableViewRow {
        if indexPath.section == 0 && isSearching == true {
            return TableViewRow.searchBooks
            
        } else if indexPath.section == 0 && isSearching == false {
            return TableViewRow.searchHistoryContents
        }
        if indexPath.section == 1 {
            return TableViewRow.deleteHistoryCacshe
        }
        
        return TableViewRow.unexpect
    }
    
}

// ================================================================================
// MARK: -
extension HomePagerViewController2 {
    fileprivate func showDeleteHistoryAlert() {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "検索履歴を消しますか?",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["消去する"],
                              tap: { [weak self](aleart, buttonIndex) in
                                if buttonIndex == aleart.firstOtherButtonIndex {
                                    SearchHistoryCache.shared.deleteHistoryCache()
                                    self?.tableView.reloadData()
                                }
        })
    }

    fileprivate func goSearchGridViewController(_ text: String?) {
        if text == nil {
            return
        }
        
        serchBar.resignFirstResponder()
        serchBar?.setShowsCancelButton(false, animated: true)

        if TempEhonSearch.isEhon(searchWord: text!) {
            TempEhonSearch.showEhonCategory(on: self)
        } else {
            let controller: SearchMerchandiseBookGridViewController = SearchMerchandiseBookGridViewController(text: text!)
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    fileprivate func goDetailBook(_ book: Book) {
        serchBar.resignFirstResponder()
        SVProgressHUD.show()
        let mers: Merchandises = Merchandises()
        self.view.isUserInteractionEnabled = false
        mers.getMerchandises(book) { [weak self] (error) in
            guard error == nil else {
                return
            }

            DispatchQueue.main.async {
                self?.view.isUserInteractionEnabled = true
                let controller: DetailPageTableViewController = DetailPageTableViewController(book: book, merchandises: mers, type: .normal)
                controller.view.clipsToBounds = true
                SVProgressHUD.dismiss()
                self?.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

// ================================================================================
// MARK: - Banner Medhod

extension HomePagerViewController2 {
    func setBanners (_ banners: [Banner]?) {
        for bannerView in self.bannerViews {
            bannerView.banner = nil
        }

        guard let banners = banners else { return }
        guard banners.count > 0 else { return }
        
        for (index, bannerView) in self.bannerViews.enumerated() {
            let banner = banners[index % banners.count]
            bannerView.banner = banner
        }
    }
}

// MARK: - FeatureBookViewProtocol

extension HomePagerViewController2: FeatureBookViewProtocol {
    func bannerTapped(with bannerView: FeatureBookView, completion: @escaping ()-> Void) {
        guard let banner = bannerView.banner else {
            completion()
            return
        }
        guard let url = banner.contentUrl else {
            completion()
            return
        }

        let controller: BaseWebViewController = BaseWebViewController(url: url)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
        completion()
    }
}
