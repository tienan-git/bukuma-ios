//
//  HomePagerViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2017/01/18.
//  Copyright © 2017年 Hiroshi Chiba. All rights reserved.
//

import CollectionViewWaterfallLayout
import SVProgressHUD

/**
 やることリスト、activityのBarButtonの赤いBadge
 */
class NotificationBadge: UIImageView {
    
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

class HomePagerBarButtonItem: BarButtonItem {
    
    var badgeView: NotificationBadge?
    var contentAvailable: Bool? {
        didSet {
            _ = contentAvailable.map { badgeView?.isHidden = !$0}
        }
    }
    
    open class func barButtonItem(_ image: UIImage, target: AnyObject, action: Selector) ->HomePagerBarButtonItem {
        let dummyItem = BarButtonItem.barButtonItemWithImage(image, isLeft: false, target: target, action: action)
        let barButtonItem = HomePagerBarButtonItem.init(customView: dummyItem.customView!)
        
        barButtonItem.badgeView = NotificationBadge(frame: CGRect.zero)
        barButtonItem.badgeView?.isHidden = true
        barButtonItem.customView?.viewSize = CGSize(width: image.size.width, height: image.size.height)
        barButtonItem.customView?.addSubview(barButtonItem.badgeView!)
        
        return barButtonItem
    }
}

/**
 タイムライン
 */
class HomePagerViewController : BaseViewController, SuggestControllerProtocol {
    internal var viewController: UIViewController!
    internal var searchBar: BukumaSearchBar!
    internal var tableView: BaseTableView!
    internal var blarView: UIView!
    internal var dataSource: SearchBookDataSource!
    internal var isSearching: Bool = false {
        didSet {
            if isSearching == false {
                dataSource.cancelTimer()
                dataSource.searchText = nil
            }
        }
    }

    fileprivate var pagerHeaderView: PagerHeaderView!
    fileprivate var searchView: UIView!
    fileprivate var contentView: UIView!
    
    fileprivate let searchTableTag: Int = 1200
    
    fileprivate var lastScrollY: CGFloat = 0
    fileprivate var currentPageIndex: Int = 0
    
    fileprivate var tabs: [Tab] = []
    fileprivate var banners: [Banner] = []
    fileprivate var contents: [HomeTabPageViewController] = []
    fileprivate var bannerViews: [FeatureBookView] = []
    
    fileprivate var pageViewController: UIPageViewController?

    fileprivate var todoListButton: UIBarButtonItem?
    fileprivate var activityButton: UIBarButtonItem?

    fileprivate var isLoopScrolling: Bool {
        return pagerHeaderView.isLoopScrolling
    }

    static let searchNavigationHeight: CGFloat = NavigationHeightCalculator.navigationHeight() + BukumaSearchBar.searchBarHeight - BukumaSearchBar.searchHeightAdjuster
    
    static let pullToRefreshInsetTop: CGFloat = HomePagerViewController.searchNavigationHeight + PagerHeaderView.headerMenuHeight()
    
    static let pullToRefreshScrollHeight: CGFloat = 50.0
    static let collectionScrollBottom: CGFloat = 50.0 + 10.0
    
    override var shouldShowRightNavigationButton: Bool {
        get {
            return true
        }
    }
    
    override func setNavigationBarButton(_ barButton: UIBarButtonItem?, isLeft: Bool) {
        var buttonController: UIViewController = kAppDelegate.drawerViewController.mainViewController
        
        let todoListButton: UIBarButtonItem = HomePagerBarButtonItem.barButtonItem(UIImage(named: "ic_nav_check")!,
                                                                                    target: self,
                                                                                    action: #selector(self.todoListButtonTapped(_:)))
        (todoListButton as? HomePagerBarButtonItem)?.badgeView?.x = 7.0
        (todoListButton.customView as? UIButton)?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 7.0, bottom: 0, right: -7.0)
        
        let activityButton: UIBarButtonItem = HomePagerBarButtonItem.barButtonItem(UIImage(named: "ic_nav_bell")!,
                                                                                    target: self,
                                                                                    action: #selector(self.self.activityButtonTapped(_:)))
        (activityButton.customView as? UIButton)?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: -10.0)
        (activityButton as? HomePagerBarButtonItem)?.badgeView?.x = 10.0
        
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
        
        if (buttonController?.navigationItem.rightBarButtonItems as? [BarButtonItem]) is [HomePagerBarButtonItem] {
            let activity: HomePagerBarButtonItem? = buttonController?.navigationItem.rightBarButtonItems?[1] as? HomePagerBarButtonItem
            let todo: HomePagerBarButtonItem? = buttonController?.navigationItem.rightBarButtonItems?[0] as? HomePagerBarButtonItem
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
    
    required public init(tabs: [Tab]) {
        super.init(nibName: nil, bundle: nil)
        self.tabs = tabs
        
        dataSource = SearchBookDataSource()
        dataSource.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageViewController =  UIPageViewController(transitionStyle: .scroll,
                                                       navigationOrientation: .horizontal,
                                                       options: nil)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        addChildViewController(pageViewController)
        pageViewController.didMove(toParentViewController: self)
        self.pageViewController = pageViewController
        
        contentView = pageViewController.view
        contentView.bounds = UIScreen.main.bounds
        view.insertSubview(contentView, belowSubview: navigationBarView!)
        
        navigationBarView?.x = 0
        navigationBarView?.width = kCommonDeviceWidth
        navigationBarView?.height = HomePagerViewController.searchNavigationHeight
        navigationBarView?.clipsToBounds = true
        
        pagerHeaderView = PagerHeaderView(delegate: self, tabs: tabs)
        pagerHeaderView.y = HomePagerViewController.searchNavigationHeight
        self.view.addSubview(pagerHeaderView)
        
        for (i, tab) in tabs.enumerated() {
            let contentController = HomeTabPageViewController(index: i, tab: tab)
            contentController.delegate = self
            contents.append(contentController)
        }
        pageViewController.setViewControllers([contents[0]], direction: .forward, animated: false, completion: nil)
        
        searchView = UIView()
        let y = NavigationHeightCalculator.navigationHeight() - BukumaSearchBar.searchHeightAdjuster
        searchView.frame = CGRect(x: 0, y: y, width: kCommonDeviceWidth, height: BukumaSearchBar.searchBarHeight)
        navigationBarView!.addSubview(searchView)
        
        searchBar = BukumaSearchBar(frame: CGRect(x: 0 , y: 0, width: kCommonDeviceWidth, height: BukumaSearchBar.searchBarHeight))
        searchBar.delegate = self
        searchView.addSubview(searchBar)

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapView(_:)))
        tapGesture.cancelsTouchesInView = false
        searchBar.addGestureRecognizer(tapGesture)
        
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
        
        tableView.y = HomePagerViewController.searchNavigationHeight
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

        self.viewController = self
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.toggeleUpdateActivity(AppDelegate.shouldUpdateActivity)
        self.toggeleUpdateTransaction(AppDelegate.shouldUpdateTransaction)
        
        contents[currentPageIndex].reloadCollectionView()

        self.showSuggetsWhenAppear(withKeyword: self.searchBar.text)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dataSource.searchText = nil
        
        SearchHistoryCache.shared.isMoreShowNext = false
    }
    
    /**
     カテゴリTabのanimationが終わったら呼ばれる
     */
    
    fileprivate func didFinishAnimation() {
        if Utility.isEmpty(tabs) {
            return
        }
        
        let parameter: [String: AnyObject] = ["tab_id": tabs[currentPageIndex].id as AnyObject,
                                              "tab_url": tabs[currentPageIndex].url as AnyObject]
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
extension HomePagerViewController: PagerHeaderViewDelegate {
    
    func pagerHeaderView(didSelectHeaderMenu tab: Tab) {
        guard let index = tabs.index(of: tab) else {
            return
        }
        
        var preIndex = currentPageIndex
        currentPageIndex = index
        
        if preIndex < index {
            preIndex += tabs.count
        }
        
        let controller = viewControllerAtIndex(index)
        pageViewController?.setViewControllers(
                [controller],
                direction: preIndex - index < tabs.count / 2 ? .reverse : .forward,
                animated: true,
                completion: { [weak self] (_) in
                    self?.didFinishAnimation()
                })
        
        fitSearchBarPositionTo(page: controller)
    }
}

extension HomePagerViewController {
    
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
        let maxHeight: CGFloat = HomePagerViewController.searchNavigationHeight
        
        let startScrollPoint: CGFloat = -147.0
        
        if lastScrollY <= startScrollPoint {
            view.height = maxHeight
            pagerHeaderView.y = HomePagerViewController.searchNavigationHeight
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
                self.pagerHeaderView.y = HomePagerViewController.searchNavigationHeight
            })
        }
    }
    
    /// UIPageViewのページ遷移の時に、検索バーの表示状態を遷移先画面のスクロールに合わせて変化させる
    /// - parameter page: 遷移先画面のview controller
    fileprivate func fitSearchBarPositionTo(page: UIViewController) {
        guard let collectionView = (page as? HomeTabPageViewController)?.collectionView else {
            return
        }
        
        lastScrollY = collectionView.contentOffsetY
        
        let startScrollPoint: CGFloat = -147.0
        let stopScrollPoint: CGFloat = startScrollPoint - HomePagerViewController.pullToRefreshScrollHeight
        if collectionView.contentOffsetY <= startScrollPoint && collectionView.contentOffsetY > stopScrollPoint {
            UIView.animate(withDuration: 0.25, animations: {
                self.navigationBarView?.height = HomePagerViewController.searchNavigationHeight
                self.pagerHeaderView.y = HomePagerViewController.searchNavigationHeight
            })
        }
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        if let barView = self.navigationBarView {
            var frame = barView.frame
            frame.size.height = HomePagerViewController.searchNavigationHeight
            
            UIView.animate(withDuration: 0.25) {
                barView.frame = frame
                self.pagerHeaderView.y = HomePagerViewController.searchNavigationHeight
            }
        }
    }
}

// ================================================================================
// MARK: - UISearchBarDelegate
extension HomePagerViewController: UISearchBarDelegate {
    
    func searchBarDidTapped(_ isResignFirstResponder: Bool) {
        if isResignFirstResponder == true {
            self.closeTableView()
            self.searchBar.setShowsCancelButton(false, animated: true)
            return
        }
        self.showTableView()

        self.showSuggetsIfNeeded(withKeyword: self.searchBar.text)
    }
    
    open func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        self.showTableView()

        self.showSuggetsIfNeeded(withKeyword: searchBar.text)

        return true
    }

    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearching = searchText.length != 0

        if searchText.length > 0 {
            self.showSuggests(withKeyword: searchText)
        } else {
            self.hideSuggests()
        }
    }
    
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchWord = searchBar.text {
            if searchWord.length > 0 {
                self.showSearchResult(with: searchWord)
                SearchHistoryCache.shared.addHistory(searchWord)

                AnaliticsManager.sendAction("search",
                                            actionName: "search_book",
                                            label: searchWord,
                                            value: 1,
                                            dic: ["searchText": searchWord as AnyObject])
            }
        }
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.isSearching = false
        
        self.closeTableView()
        self.tableView.reloadData()
    }

    open func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.chaseTyping(withInputText: text, withTextPosition: range)
        return true
    }
}

// ================================================================================
// MARK: -  TableView DataSource

extension HomePagerViewController: UITableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return  2
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfCells(in: section)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? SearchTextHistoryCell.cellHeightForObject(nil) : SearchDeleteHistroyCell.cellHeightForObject(nil)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch self.typeOfCell(for: indexPath) {
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
        case .deleteHistoryCacshe:
            cellIdentifier = NSStringFromClass(SearchDeleteHistroyCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?SearchDeleteHistroyCell
            if cell == nil {
                cell = SearchDeleteHistroyCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            break
        case .suggestWord:
            cellIdentifier = NSStringFromClass(SearchTextHistoryCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?SearchTextHistoryCell
            if cell == nil {
                cell = SearchTextHistoryCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            if let suggestWord = self.dataSource.dataAtIndex(indexPath.row, isAllowUpdate: false) as? String {
                (cell as? SearchTextHistoryCell)?.title = suggestWord
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

extension HomePagerViewController: UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellType = self.typeOfCell(for: indexPath)
        switch cellType {
        case .searchHistoryContents, .suggestWord:
            if let cell = tableView.cellForRow(at: indexPath) as? SearchTextHistoryCell {
                if let searchWord = cell.title {
                    if searchWord.length > 0 {
                        self.searchBar.text = searchWord
                        self.showSearchResult(with: searchWord)
                        SearchHistoryCache.shared.addHistory(searchWord)

                        AnaliticsManager.sendAction("search",
                                                    actionName: cellType == .searchHistoryContents ? "search_book_by_history" : "search_book_by_suggest",
                                                    label: searchWord,
                                                    value: 1,
                                                    dic: ["searchText": searchWord as AnyObject])
                    }
                }
            }
            break
        case .deleteHistoryCacshe:
            self.showDeleteHistoryAlert()
            break
        default:
            break
        }
    }
}

// ================================================================================
// MARK: -  PageViewController DataSource

extension HomePagerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = indexForViewController(viewController)
        
        index += 1
        
        if index == contents.count {
            if !isLoopScrolling {
                return nil
            }
            index = 0
        }
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = indexForViewController(viewController)
        
        if index == 0 {
            if !isLoopScrolling {
                return nil
            }
            index = contents.count - 1
        } else {
            index -= 1
        }
        
        return viewControllerAtIndex(index)
    }
    
    func indexForViewController(_ viewController: UIViewController) ->Int {
        return contents.indexOfObject(viewController) ?? 0
    }
    
    func viewControllerAtIndex(_ index: Int) ->UIViewController {
        if index >= self.tabs.count {
            return UIViewController()
        }
        
        return contents[index]
    }
}

// ================================================================================
// MARK: -  PageViewController Delegate

extension HomePagerViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        if let viewController = pendingViewControllers.first {
            changePageIndex(of: viewController)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let viewController = pageViewController.viewControllers?.first {
            changePageIndex(of: viewController)
        }
        didFinishAnimation()
    }
    
    private func changePageIndex(of viewController: UIViewController) {
        let index = indexForViewController(viewController)
        if currentPageIndex != index {
            currentPageIndex = index
            if let tab = (viewController as? HomeTabPageViewController)?.tab {
                pagerHeaderView.move(selectTab: tab)
            }
            fitSearchBarPositionTo(page: viewController)
        }
    }
}

extension HomePagerViewController: BaseTableViewDelegate {
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

extension HomePagerViewController: BaseTableViewCellDelegate { }

// ================================================================================
// MARK:- DataSource Delegate & Data Source Medhod
extension HomePagerViewController: BaseDataSourceDelegate {
    func completeRequest() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func failedRequest(_ error: Error) {}
}

// ================================================================================
// MARK: - UITapGestureRecognizer
extension HomePagerViewController {
    
    func tapView(_ sender: UITapGestureRecognizer) {
        if searchBar.isFirstResponder == true {
            searchBar.resignFirstResponder()
            self.searchBarDidTapped(true)
            return
        }
        searchBar.becomeFirstResponder()
        self.searchBarDidTapped(false)
    }
    
    func gesuture(_ sender: UITapGestureRecognizer) {
        let contentHeight: CGFloat = tableView.contentSizeHeight
        let visibleBluerViewRect: CGRect = CGRect(x: 0,
                                                  y: HomePagerViewController.searchNavigationHeight + tableView.contentSizeHeight,
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

extension HomePagerViewController {
    
    internal func showTableView() {
        self.pagerHeaderView.isHidden = true
        self.contents[currentPageIndex].collectionView?.pullToRefreshView.isHidden = true

        self.isSearching = false
        self.dataSource.cancelTimer()
        self.dataSource.searchText = nil

        self.blarView.alpha = 0.0
        self.blarView.isHidden = false
        self.blarView.isUserInteractionEnabled = true
        self.tableView.isHidden = false
        self.tableView.isUserInteractionEnabled = true
        self.tableView.reloadData()
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] () in
            self?.blarView.alpha = 1.0
            self?.tableView.y = (kCommonStatusBarHeight + kCommonNavigationBarHeight + BukumaSearchBar.searchBarHeight - 4)
        }) { (isFinish) in
        }
    }
    
    @objc internal func closeTableView() {
        SearchBookDataSource.retryCount = 0
        
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)

        self.dataSource.cancelTimer()
        self.dataSource.searchText = nil
        self.contents[currentPageIndex].collectionView?.pullToRefreshView.isHidden = false

        self.pagerHeaderView.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] () in
            self?.blarView.alpha = 0.0
            self?.tableView.frame.origin.y = -(self?.tableView.frame.size.height ?? 1000)
        }, completion: { [weak self] (isFinish: Bool) in
            self?.tableView.isHidden = true
            self?.tableView.isUserInteractionEnabled = false

            self?.blarView.isHidden = true
            self?.blarView.isUserInteractionEnabled = false
        })
    }
}

// ================================================================================
// MARK: -
extension HomePagerViewController {
    internal func showSearchResult(with searchText: String) {
        if self.searchBar.isFirstResponder {
            self.searchBar.resignFirstResponder()
            self.searchBar.setShowsCancelButton(false, animated: true)
        }

        let controller = SearchMerchandiseBookGridViewController(text: searchText)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func goDetailBook(_ book: Book) {
        searchBar.resignFirstResponder()
        
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.show()

        DetailPageTableViewController.generate(for: book) { [weak self] (generatedViewController: DetailPageTableViewController?) in
            guard let viewController = generatedViewController else {
                SVProgressHUD.dismiss()
                self?.view.isUserInteractionEnabled = true
                return
            }
            self?.navigationController?.pushViewController(viewController, animated: true)

            SVProgressHUD.dismiss()
            self?.view.isUserInteractionEnabled = true
        }
    }
}

// ================================================================================
// MARK: - Banner Medhod

extension HomePagerViewController {
    func setBanners (_ banners: [Banner]?) {
        self.banners = banners ?? []
        
        for content in contents {
            content.updateBannerView()
        }
    }
}

// MARK: - FeatureBookViewProtocol

extension HomePagerViewController: FeatureBookViewProtocol {
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

// MARK: - HomeTabPageViewController Delegate

extension HomePagerViewController: HomeTabPageViewControllerDelegate {
    
    func pageViewController(_ viewController: HomeTabPageViewController, bookDidSelect book: Book) {
        goDetailBook(book)
    }
    
    func pageViewControllerDidCompleteRequerst(_ viewController: HomeTabPageViewController) {
        tableView.reloadData()
        
        if viewController.index == 0 {
            contentView.isHidden = false
        }
        
        if let collectionView = viewController.collectionView {
            lastScrollY = collectionView.contentOffsetY
        }
    }
    
    func pageCollectionViewDidScroll(_ collectionView: UICollectionView) {
        scrollSearchBar(collectionView)
    }
    
    func pageBanners() -> [Banner] {
        return banners
    }
}

