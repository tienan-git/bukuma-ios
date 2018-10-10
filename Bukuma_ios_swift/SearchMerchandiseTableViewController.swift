//
//  SearchTableTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

open class SearchMerchandiseTableViewController: BaseSearchTableViewController {
    
    let blarView: UIView = UIView()
    let serachTextHistoryTableView: BaseTableView! = BaseTableView()
    var shouldShowMoreHistory: Bool = false
    
    enum SearchTableViewControllerTableViewType: Int {
        case category = 0
        case searchBook = 1
    }
    
    fileprivate enum CategoryTableViewRowType: Int {
        case categories
        case searchHistoryTitle
        case searchHistoryContents
        case searchHistoryLoadMore
        case unexpect
    }
    
    fileprivate enum SearchBooksTableViewRowType: Int {
        case searchHistoryContents
        case searchBooks
        case deleteHistoryCacshe
        case unexpect
    }
    
    // ================================================================================
    // MARK: init
    
    override var isSearching: Bool {
        didSet {
            if isSearching == false {
                (dataSource as? SearchBookDataSource)?.cancelTimer()
                (dataSource as? SearchBookDataSource)?.searchText = nil
            }
        }
    }
    
    override var shouldRefreshDataSource: Bool {
        get {
            return isSearching
        }
    }
    
    override var shouldReloadMainView: Bool {
        get {
            return isSearching
        }
    }
    
    override var shouldShowProgressHUDWhenDataSourceRefresh: Bool {
        get {
            return false
        }
    }
    
    open func footerHeightUsingTag(_ tableViewTag: Int) -> CGFloat {
        if tableViewTag == 1 {
            if serachTextHistoryTableView.height == kCommonDeviceHeight {
                return kAppDelegate.tabBarController.tabBar.height * 3
            }
            return kAppDelegate.tabBarController.tabBar.height * 2 + 14.0
        }
        return kAppDelegate.tabBarController.tabBar.height +  50.0
    }
    
    open func scrollIndicatorInsetBottomUsingTag(_ tableViewTag: Int) ->CGFloat {
        if tableViewTag == 1 {
            if serachTextHistoryTableView.height == kCommonDeviceHeight {
                return kAppDelegate.tabBarController.tabBar.height * 2 + 14.0
            }
            return kAppDelegate.tabBarController.tabBar.height  + 14.0
        }
        return kAppDelegate.tabBarController.tabBar.height
    }
    
    override open func emptyViewCenterPositionY() -> CGFloat {
        return super.emptyViewCenterPositionY() - 100.0
    }
 
    override open func completeRequest() {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
            self.tableView?.pullToRefreshView?.stopAnimating()
            self.tableView?.scrollIndicatorInsets = self.tableView!.contentInset
            self.serachTextHistoryTableView.reloadData()
        }
    }
    
    override open func registerDataSourceClass() ->AnyClass? {
        return SearchBookDataSource.self
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.edgesForExtendedLayout = .none
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView?.usingTag = true
        
        serachTextHistoryTableView.usingTag = true
        serachTextHistoryTableView.frame = self.view.bounds
        serachTextHistoryTableView.tableViewDelegate = self
        serachTextHistoryTableView.delegate = self
        serachTextHistoryTableView.dataSource = self
        serachTextHistoryTableView.backgroundColor = UIColor.clear
        serachTextHistoryTableView.separatorInset = UIEdgeInsets.zero
        serachTextHistoryTableView.separatorColor = kBorderColor
        serachTextHistoryTableView.layoutMargins = UIEdgeInsets.zero
        serachTextHistoryTableView.tag = SearchTableViewControllerTableViewType.searchBook.rawValue
        serachTextHistoryTableView.bounces = true
        serachTextHistoryTableView.isFixTableScrollWhenChangeContentsSize = true
        serachTextHistoryTableView.separatorStyle = .none
        
        isNeedKeyboardNotification = true
        
        self.view.insertSubview(serachTextHistoryTableView, aboveSubview: tableView!)
        serachTextHistoryTableView.y = -serachTextHistoryTableView.contentSizeHeight
        serachTextHistoryTableView.isHidden = true
        
        blarView.frame = CGRect(x: 0, y: NavigationHeightCalculator.navigationHeight(), width: kCommonDeviceWidth, height: kCommonDeviceHeight)
        blarView.backgroundColor = kBackGroundColor
        blarView.isHidden = true
        self.view.insertSubview(blarView, belowSubview: serachTextHistoryTableView)
        blarView.addGestureRecognizer(tapGesture!)
        
        emptyDataView?.removeFromSuperview()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeSerachTextTableView), name: NSNotification.Name(rawValue: KYDrawerControllerAfterDidButtonTapped), object: nil)
        
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.gesuture(_:)))
        gesture.cancelsTouchesInView = false
        serachTextHistoryTableView.addGestureRecognizer(gesture)
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView?.reloadData()
        serachTextHistoryTableView?.reloadData()

        kRootViewControllerController.navigationItem.titleView = UIView.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: NavigationHeightCalculator.navigationHeight()))
        kRootViewControllerController.navigationItem.titleView?.addSubview(serchBar!)

    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topInset = topLayoutGuide.length
        tableView?.contentInset.top = topInset
//        tableView?.contentOffset.y = -topInset
        tableView?.scrollIndicatorInsets.top = topInset
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        kRootViewControllerController.navigationItem.titleView = nil
        (dataSource as? SearchBookDataSource)?.searchText = nil
        
        SearchHistoryCache.shared.isMoreShowNext = false
    }
    
    override func keyboardDidShow(_ notification: Foundation.Notification) {
        let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as!NSValue).cgRectValue
        serachTextHistoryTableView?.viewSize = CGSize(width: kCommonDeviceWidth, height: kCommonDeviceHeight - keyboardFrame.height)
    }
    
    override func keyboardDidHide(_ notification: Foundation.Notification) {
        super.keyboardDidHide(notification)
        serachTextHistoryTableView.viewSize = CGSize(width: kCommonDeviceWidth, height: kCommonDeviceHeight)
        serachTextHistoryTableView.contentInsetBottom = kAppDelegate.tabBarController.tabBar.height
    }
    
    override func searchBarDidTapped(_ isResignFirstResponder: Bool) {
        if isResignFirstResponder == true {
            self.closeSerachTextTableView()
            serchBar!.showsCancelButton = false
            return
        }
        self.showSerachTextTableView()
    }
    
    func gesuture(_ sender: UITapGestureRecognizer) {
        let contentHeight: CGFloat = serachTextHistoryTableView.contentSizeHeight
        let visibleBluerViewRect: CGRect = CGRect(x: 0,
                                                  y: NavigationHeightCalculator.navigationHeight() + serachTextHistoryTableView.contentSizeHeight,
                                                  width: kCommonDeviceWidth,
                                                  height: serachTextHistoryTableView.height - contentHeight)
        
        if contentHeight < serachTextHistoryTableView.height {
            let location = sender.location(ofTouch: 0, in: self.view)
            if location.y > visibleBluerViewRect.origin.y {
                self.closeSerachTextTableView()
            }
        }
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        activeTableViewtag = tableView.tag
        return  2
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activeTableViewtag = tableView.tag

        if activeTableViewtag == SearchTableViewControllerTableViewType.searchBook.rawValue {
            if section == 0 {
                return isSearching == true ?  self.dataSource?.count() ?? 0 : SearchHistoryCache.shared.count()
            }
            return isSearching == true ? 0 : 1
        } else {
            if section == SearchTableViewControllerTableViewType.category.rawValue {
                return Category.cachedCategory(false)?.count ?? 0
            }
            if SearchHistoryCache.shared.count() > 0 {
                if SearchHistoryCache.shared.shouldShowLoadMore {
                    return  SearchHistoryCache.shared.showableCount() + 2
                } else {
                     return  SearchHistoryCache.shared.showableCount() + 1
                }
            }
            return  SearchHistoryCache.shared.showableCount()
        }
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        activeTableViewtag = tableView.tag
        if activeTableViewtag == SearchTableViewControllerTableViewType.searchBook.rawValue {
            return indexPath.section == 0 ? SearchTextHistoryCell.cellHeightForObject(nil) : SearchDeleteHistroyCell.cellHeightForObject(nil)
        }
        return SearchCategoryCell.cellHeightForObject(nil)
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        activeTableViewtag = tableView.tag
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        if activeTableViewtag == SearchTableViewControllerTableViewType.searchBook.rawValue {
            switch self.searchBooksTableViewShowableRowType(indexPath) {
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
                
                let book: Book? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: true) as? Book
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
        } else {
            
            switch self.categorytTableViewShowableRowType(indexPath) {
            case .categories:
                cellIdentifier = NSStringFromClass(SearchCategoryCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?SearchCategoryCell
                if cell == nil {
                    cell = SearchCategoryCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                
                let object = Category.cachedCategory(false)![indexPath.row]
                (cell as! SearchCategoryCell).title = object.categoryName.flatMap{$0}
                (cell as! SearchCategoryCell).setColors(indexPath.row)
                if indexPath.row == Category.cachedCategory(false)!.count - 1 {
                    (cell as! SearchCategoryCell).isShortBottomLine = false
                } else {
                    (cell as! SearchCategoryCell).isShortBottomLine = true
                }

                break
            case .searchHistoryContents:
                cellIdentifier = NSStringFromClass(BaseTextFieldCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
                
                if cell == nil {
                    cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                (cell as? BaseTextFieldCell)?.titleText = SearchHistoryCache.shared.historyName(indexPath.row - 1)
                (cell as? BaseTextFieldCell)?.rightImage = UIImage(named: "ic_to")
                (cell as? BaseTextFieldCell)?.titleLabel?.x = 20.0
                (cell as? BaseTextFieldCell)?.titleLabel?.width = kCommonDeviceWidth - 20.0 - 30.0
                (cell as? BaseTextFieldCell)?.textField?.isUserInteractionEnabled = false
                (cell as? BaseTextFieldCell)?.titleLabel?.textAlignment = .left
                break
            case .searchHistoryLoadMore:
                cellIdentifier = NSStringFromClass(DetailLoadMoreCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?DetailLoadMoreCell
                
                if cell == nil {
                    cell = DetailLoadMoreCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                
                (cell as? DetailLoadMoreCell)?.titleLabel?.textColor = kDarkGray03Color
                break
            case .searchHistoryTitle:
                cellIdentifier = NSStringFromClass(BaseTitleCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
                if cell == nil {
                    cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                (cell as! BaseTitleCell).title = "検索履歴"
                break
            case .unexpect:
                break
            }
        }
       return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if activeTableViewtag == SearchTableViewControllerTableViewType.category.rawValue {
            switch self.categorytTableViewShowableRowType(indexPath) {
            case .categories:
                
                let object =  Category.cachedCategory(false)![indexPath.row]
                let color: UIColor = SearchCategoryColor.searchCategoryColor(by: indexPath.row)
                let controller: SearchMerchandiseCategoryTableViewController = SearchMerchandiseCategoryTableViewController(color: color)
                controller.category = object
                controller.view.clipsToBounds = true
                self.navigationController?.pushViewController(controller, animated: true)
                
                break
            case .searchHistoryContents:
                
                searchText = SearchHistoryCache.shared.historyName(indexPath.row - 1)
                self.goSearchGridViewController(searchText)
                
                break
            case .searchHistoryLoadMore:
                SearchHistoryCache.shared.isMoreShowNext = true                
                tableView.reloadData()
                break
            default:
                break
            }
            
        } else {
            switch self.searchBooksTableViewShowableRowType(indexPath) {
            case .searchBooks:
                
                let book: Book = self.dataSource!.dataAtIndex(indexPath.row, isAllowUpdate: false) as! Book
                serchBarTextField!.text = book.titleText()
                searchText = book.titleText()
                
                AnaliticsManager.sendAction("search",
                                            actionName: "search_book",
                                            label: searchText ?? "",
                                            value: 1,
                                            dic: ["searchText": searchText as AnyObject])
                
                SearchHistoryCache.shared.addHistory(searchText)
                
                self.goDetailBook(book, completion: nil)
            
                break
            case .searchHistoryContents:
                
                serchBarTextField!.text = SearchHistoryCache.shared.histories?[indexPath.row]
                self.goSearchGridViewController(serchBarTextField!.text)

                break
            case .deleteHistoryCacshe:
                self.showDeleteHistoryAlert()
                break
            default:
                break
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCellEditingStyle {
        activeTableViewtag = tableView.tag
        if activeTableViewtag == SearchTableViewControllerTableViewType.category.rawValue {
            if self.categorytTableViewShowableRowType(indexPath) == .searchHistoryContents {
                return .delete
            }
        }
        return .none
    }
    
    open func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]? {
        activeTableViewtag = tableView.tag
        let title: String = "削除"
        
        if activeTableViewtag == SearchTableViewControllerTableViewType.category.rawValue {
            if self.categorytTableViewShowableRowType(indexPath) == .searchHistoryContents {
                return [UITableViewRowAction(style: .default,
                title: title) {[weak self] (action, indexPass) in
                    SearchHistoryCache.shared.deleteHistoryAtRow(indexPath.row)
                    self?.tableView?.reloadData()
                }]
            }
        }
        return nil
    }
    
    fileprivate func categorytTableViewShowableRowType(_ indexPath:IndexPath) ->CategoryTableViewRowType {
        if indexPath.section == 0 {
            return CategoryTableViewRowType.categories
        }
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                return CategoryTableViewRowType.searchHistoryTitle
            } else if indexPath.row == SearchHistoryCache.shared.showableCount() + 1 && SearchHistoryCache.shared.count() > 0 {
                return CategoryTableViewRowType.searchHistoryLoadMore
            } else if indexPath.row != 0 {
                return CategoryTableViewRowType.searchHistoryContents
            }
        }
        
        return CategoryTableViewRowType.unexpect
    }
    
    fileprivate func searchBooksTableViewShowableRowType(_ indexPath:IndexPath) ->SearchBooksTableViewRowType {
        if indexPath.section == 0 && isSearching == true {
            return SearchBooksTableViewRowType.searchBooks
           
        } else if indexPath.section == 0 && isSearching == false {
            return SearchBooksTableViewRowType.searchHistoryContents
        }
        if indexPath.section == 1 {
            return SearchBooksTableViewRowType.deleteHistoryCacshe
        }

        return SearchBooksTableViewRowType.unexpect
    }
    
    fileprivate func goSearchGridViewController(_ text: String?) {
        if text == nil {
            return
        }
        let controller: SearchMerchandiseTitleTableViewController = SearchMerchandiseTitleTableViewController(text: text!)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
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
                                    self?.tableView?.reloadData()
                                    self?.serachTextHistoryTableView?.reloadData()
                                }
        })
    }

    // ================================================================================
    // MARK: - UISearchBarDelegate
    override open func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        _ = super.searchBarShouldBeginEditing(searchBar)
        self.showSerachTextTableView()
        return true
    }
    
    override open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        super.searchBar(searchBar, textDidChange: searchText)
        
        (dataSource as? SearchBookDataSource)?.setNewSearchText(searchText, completion: { 
            (self.dataSource as? SearchBookDataSource)?.getFromOurServer()
        })
    }
    
    override open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        super.searchBarSearchButtonClicked(searchBar)
        
        if Utility.isEmpty(searchText) {
            return
        }
        
        SearchHistoryCache.shared.addHistory(searchText)
        SVProgressHUD.show()
        AnaliticsManager.sendAction("search",
                                    actionName: "search_book",
                                    label: searchText ?? "",
                                    value: 1,
                                    dic: ["searchText": searchText as AnyObject])

        let controller: SearchMerchandiseTitleTableViewController = SearchMerchandiseTitleTableViewController(text: searchText!)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        super.searchBarCancelButtonClicked(searchBar)
        self.closeSerachTextTableView()
        tableView?.reloadData()
        serachTextHistoryTableView.reloadData()
    }
    
    func showSerachTextTableView() {
        blarView.alpha = 0.0
        blarView.isHidden = false
        blarView.isUserInteractionEnabled = true
        serachTextHistoryTableView.isHidden = false
        isSearching = false
        (dataSource as? SearchBookDataSource)?.cancelTimer()
        (dataSource as? SearchBookDataSource)?.searchText = nil
        self.serachTextHistoryTableView.reloadData()
        UIView.animate(withDuration: 0.25, animations: {
            self.blarView.alpha = 1.0
            self.serachTextHistoryTableView.y = NavigationHeightCalculator.navigationHeight()
        }) { (isFinish) in
        }
    }
    
    func closeSerachTextTableView() {
        SearchBookDataSource.retryCount = 0
        (dataSource as? SearchBookDataSource)?.cancelTimer()
        (dataSource as? SearchBookDataSource)?.searchText = nil
        serchBar?.resignFirstResponder()
        serchBar?.showsCancelButton = false
        blarView.isHidden = true
        blarView.isUserInteractionEnabled = false
        SearchHistoryCache.shared.addHistory(searchText.flatMap{$0})
        
        tableView?.reloadData()
        serachTextHistoryTableView.reloadData()
        UIView.animate(withDuration: 0.25, animations: {
            self.serachTextHistoryTableView.y = -self.serachTextHistoryTableView.contentSizeHeight
            self.serchBarTextField?.text = nil
        }) { (isFinish) in
            self.isSearching = false
            self.serachTextHistoryTableView.isHidden = true
        }
    }
    
    var lastScroll: CGFloat = 0
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UITableView && scrollView.tag == 0 {
            DispatchQueue.main.async {
                if self.lastScroll - scrollView.contentOffsetY == self.pullToRefreshInsetTop() && scrollView.contentOffsetY != -self.pullToRefreshInsetTop() {
                    self.tableView?.setContentOffset(CGPoint(x: self.tableView!.contentOffsetX, y: self.lastScroll), animated: false)
                    self.tableView?.contentInsetTop = self.pullToRefreshInsetTop()
                    self.tableView?.scrollIndicatorInsets = self.tableView!.contentInset
                    return
                }
                self.lastScroll = scrollView.contentOffsetY
                self.tableView!.updateFooterInset()
            }
        }
    }
}
