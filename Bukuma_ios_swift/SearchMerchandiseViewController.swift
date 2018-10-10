//
//  SearchMerchandiseNewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2017/01/11.
//  Copyright © 2017年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class SearchMerchandiseViewController: BaseViewController, BukumaSearchBarAdjusterProtocol, SuggestControllerProtocol {
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

    fileprivate var collectionView: UICollectionView!

    fileprivate var categories: [Category] = []

    fileprivate var lastScroll: CGFloat = 0

    fileprivate var shouldRefreshDataSource: Bool {
        get {
            return isSearching
        }
    }
    
    fileprivate var shouldReloadMainView: Bool {
        get {
            return isSearching
        }
    }
    
    fileprivate var shouldShowProgressHUDWhenDataSourceRefresh: Bool {
        get {
            return false
        }
    }

    fileprivate func collectionViewContentTop() ->CGFloat {
        return (BukumaSearchBar.searchBarHeight + kCommonStatusBarHeight)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        
        dataSource = SearchBookDataSource()
        dataSource.delegate = self
        
        categories = Category.sortedCategory()
        var sCate: Category?
        
        _ = categories.map { (c) in
            if c.categoryName == "総合" {
                sCate = c
            }
        }
        
        _ = sCate.map { (s) in
            categories.removeObject(s)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = SearchMerchandiseCollectionCell.cellSize()
        layout.sectionInset = UIEdgeInsets(top: 17, left: 17, bottom: 17, right: 23)
        
        collectionView = UICollectionView(frame: CGRect(x:0, y:0 , width:kCommonDeviceWidth, height:kCommonDeviceHeight), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset.top = self.collectionViewContentTop()
        collectionView.contentInsetBottom  = 50.0
        collectionView.scrollsToTop = true
        collectionView.register(SearchMerchandiseCollectionCell.self, forCellWithReuseIdentifier:NSStringFromClass(SearchMerchandiseCollectionCell.self))
        self.view.insertSubview(collectionView, belowSubview: navigationBarView!)

        searchBar = BukumaSearchBar(frame: CGRect(x: -30.0, y: 0, width: kCommonDeviceWidth - 60, height: BukumaSearchBar.searchBarHeight))
        searchBar.delegate = self

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
        
        isNeedKeyboardNotification = true
        
        self.view.insertSubview(tableView, aboveSubview: collectionView)
        tableView.y = -tableView.contentSizeHeight
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

        self.adjustPosition(for: kRootViewControllerController.navigationController?.navigationBar)
        self.adjustHeight(for: self.navigationBarView)
        self.addItem(as: self.searchBar, on: kRootViewControllerController.navigationItem)

        self.reloadTableView()

        self.showSuggetsWhenAppear(withKeyword: self.searchBar.text)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        self.resetPosition(for: kRootViewControllerController.navigationController?.navigationBar)
        self.addItem(as: nil, on: kRootViewControllerController.navigationItem)

        dataSource?.searchText = nil
        
        SearchHistoryCache.shared.isMoreShowNext = false

        super.viewWillDisappear(animated)
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
    
    fileprivate func reloadTableView() {
        if self.shouldReloadMainView == true {
            dataSource.update()
            tableView.reloadData()
        }
        
        if self.shouldRefreshDataSource == true {
            self.refreshDataSource()
        }
    }
    
    fileprivate func refreshDataSource() {
        DispatchQueue.main.async {
            if self.shouldShowProgressHUDWhenDataSourceRefresh == true {
                SVProgressHUD.show()
            }
            self.dataSource?.refreshDataSource()
        }
    }
}

// ================================================================================
// MARK: - UICollectionViewDataSource
extension SearchMerchandiseViewController: UICollectionViewDataSource {
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = NSStringFromClass(SearchMerchandiseCollectionCell.self)
        var cell: SearchMerchandiseCollectionCell?
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? SearchMerchandiseCollectionCell
        
        if cell == nil {
            cell = SearchMerchandiseCollectionCell(frame: CGRect.zero)
        }
        
        cell?.category = categories[indexPath.row]
        cell?.title = categories[indexPath.row].categoryName
        
        return cell ?? UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}

// ================================================================================
// MARK: - UICollectionViewDelegate
extension SearchMerchandiseViewController: UICollectionViewDelegate {
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        let color = SearchCategoryColor.searchCategoryColor(by: indexPath.row)

        let controller: MerchandiseHomeCollectionViewController = MerchandiseHomeCollectionViewController(color: color)
        controller.category = category
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// ================================================================================
// MARK: - UISearchBarDelegate
extension SearchMerchandiseViewController: UISearchBarDelegate {
    
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

extension SearchMerchandiseViewController: UITableViewDataSource {
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
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SearchTextHistoryCell
            if cell == nil {
                cell = SearchTextHistoryCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            if SearchHistoryCache.shared.count() >= indexPath.row {
                (cell as? SearchTextHistoryCell)?.title = SearchHistoryCache.shared.historyName(indexPath.row)
            }
            break
        case .deleteHistoryCacshe:
            cellIdentifier = NSStringFromClass(SearchDeleteHistroyCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SearchDeleteHistroyCell
            if cell == nil {
                cell = SearchDeleteHistroyCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            break
        case .suggestWord:
            cellIdentifier = NSStringFromClass(SearchTextHistoryCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SearchTextHistoryCell
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

extension SearchMerchandiseViewController: UITableViewDelegate {
    
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

extension SearchMerchandiseViewController: BaseTableViewDelegate {
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

extension SearchMerchandiseViewController: BaseTableViewCellDelegate { }

extension SearchMerchandiseViewController {
    internal func showSearchResult(with searchWord: String) {
        if self.searchBar.isFirstResponder {
            self.searchBar.resignFirstResponder()
            self.searchBar.setShowsCancelButton(false, animated: true)
        }

        let controller = SearchMerchandiseBookGridViewController(text: searchWord)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }

    fileprivate func goDetailBook(_ book: Book) {
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
// MARK: - DataSource Delegate

extension SearchMerchandiseViewController: BaseDataSourceDelegate {
    
    open func completeRequest() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    open func failedRequest(_ error: Error) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// ================================================================================
// MARK: - UITapGestureRecognizer
extension SearchMerchandiseViewController {
    
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
                                                  y: NavigationHeightCalculator.navigationHeight() + tableView.contentSizeHeight,
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


extension SearchMerchandiseViewController {
    
    internal func showTableView() {
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
            self?.tableView.y = (BukumaSearchBar.searchBarHeight + kCommonStatusBarHeight)
        }) { (isFinish) in
        }
    }

    @objc internal func closeTableView() {
        SearchBookDataSource.retryCount = 0

        self.dataSource.cancelTimer()
        self.dataSource.searchText = nil
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)

        UIView.animate(withDuration: 0.25, animations: { [weak self] () in
            self?.blarView.alpha = 0.0
            self?.tableView.y = -(self?.tableView.contentSizeHeight ?? 1000)
        }) { [weak self] (isFinish) in
            self?.isSearching = false

            self?.tableView.isHidden = true
            self?.tableView.isUserInteractionEnabled = false

            self?.blarView.isHidden = true
            self?.blarView.isUserInteractionEnabled = false
        }
    }
}

extension SearchMerchandiseViewController {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView {
            DispatchQueue.main.async {
                if self.lastScroll - scrollView.contentOffsetY == self.collectionViewContentTop() && scrollView.contentOffsetY != -self.collectionViewContentTop() {
                    self.collectionView.setContentOffset(CGPoint(x: self.collectionView.contentOffsetX, y: self.lastScroll), animated: false)
                    self.collectionView.contentInsetTop = self.collectionViewContentTop()
                    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
                    return
                }
                self.lastScroll = scrollView.contentOffsetY
            }
        }
    }
}
