//
//  HomeTabPageViewController.swift
//  Bukuma_ios_swift
//
//  Created by admin on 2017/05/20.
//  Copyright © 2017年 Labit Inc. All rights reserved.
//

import CollectionViewWaterfallLayout
import SVProgressHUD

protocol HomeTabPageViewControllerDelegate: class, FeatureBookViewProtocol {
    func pageViewController(_ viewController: HomeTabPageViewController, bookDidSelect book: Book)
    func pageViewControllerDidCompleteRequerst(_ viewController: HomeTabPageViewController)
    
    func pageCollectionViewDidScroll(_ collectionView: UICollectionView)
    func pageBanners() -> [Banner]
}

class HomeTabPageViewController: BaseViewController {
    var index: Int
    var tab: Tab
    var dataSource: HomeDataSource
    weak var delegate: HomeTabPageViewControllerDelegate?
    
    var collectionView: UICollectionView?
    var emptyView: EmptyDataView?
    var bannerView: FeatureBookView?
    
    init(index: Int, tab: Tab) {
        self.index = index
        self.tab = tab
        
        let dataSource = HomeDataSource()
        dataSource.url = tab.url
        dataSource.tabIndex = index
        self.dataSource = dataSource
        
        super.init(nibName: nil, bundle: nil)
        
        dataSource.delegate = self
        dataSource.refreshDataSource()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        let collectionView = generateCollectionView()
        collectionView.x = 0
        collectionView.tag = index
        collectionView.register(HomeCollectionCell.self, forCellWithReuseIdentifier:"\(String(describing: HomeCollectionCell.self))\(index)")
        collectionView.register(CollectionLoadMoreCell.self, forCellWithReuseIdentifier: "\(String(describing: CollectionLoadMoreCell.self))\(index)")
        self.collectionView = collectionView
        
        let emptyView = EmptyDataView()
        emptyView.delegate = self
        emptyView.isHidden = true
        collectionView.addSubview(emptyView)
        emptyView.adjustEmptyView()
        self.emptyView = emptyView
        
        let banner = FeatureBookView()
        banner.delegate = delegate
        collectionView.addSubview(banner)
        bannerView = banner
        updateBannerView()
        
        view.addSubview(collectionView)
    }
    
    override var shouldShowRightNavigationButton: Bool {
        get {
            return true
        }
    }
    
    func refreshDataSource() {
        DispatchQueue.main.async { [weak self] in
            if self?.dataSource.count() == 0 {
                SVProgressHUD.show()
            }
            self?.dataSource.refreshDataSource()
        }
    }
    
    func updateBannerView() {
        guard let bannerView = bannerView else { return }
        
        let banners = delegate?.pageBanners() ?? []
        
        if banners.isEmpty {
            bannerView.banner = nil
            bannerView.isHidden = true
            bannerView.isUserInteractionEnabled = false
        } else {
            let banner = banners[index % banners.count]
            bannerView.banner = banner
            bannerView.isHidden = false
            bannerView.isUserInteractionEnabled = true
        }
        
        if let collectionView = collectionView,
            let layout = collectionView.collectionViewLayout as? CollectionViewWaterfallLayout {
            
            let topInset = banners.isEmpty ? 10 : FeatureBookView.bannerViewHeight
            layout.sectionInset =  UIEdgeInsets(top: topInset, left: 10, bottom: 0, right: 10)
            collectionView.collectionViewLayout = layout
        }
    }
}

// ================================================================================
// MARK:- collectionView layout

extension HomeTabPageViewController {
    fileprivate func generateCollectionView() -> UICollectionView {
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
        collectionView.contentInset.top = HomePagerViewController.pullToRefreshInsetTop
        collectionView.contentInsetBottom  = HomePagerViewController.collectionScrollBottom
        collectionView.scrollsToTop = true
        
        collectionView.addPull(toRefreshScrollHeight: HomePagerViewController.pullToRefreshScrollHeight,
                               contentInsetTop: HomePagerViewController.pullToRefreshInsetTop) {[weak self] () in
            self?.refreshDataSource()
        }
        
        return collectionView
    }
}

// ================================================================================
// MARK:- CollectionView data source

extension HomeTabPageViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cellIdentifier = ""
        var cell: UICollectionViewCell?
        let book = dataAt(index: indexPath.row, isAllowUpdate: true)
        
        if book == nil {
            cellIdentifier = "\(String(describing: CollectionLoadMoreCell.self))\(index)"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CollectionLoadMoreCell
            if cell == nil {
                cell = CollectionLoadMoreCell()
            }
        } else {
            cellIdentifier = "\(String(describing: HomeCollectionCell.self))\(index)"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? HomeCollectionCell
            if cell == nil {
                cell = HomeCollectionCell(frame: CGRect.zero)
            }
            (cell as? HomeCollectionCell)?.delegate = self
            (cell as? HomeCollectionCell)?.cellModelObject = book
        }
        
        return cell!
    }
    
    func reloadCollectionView() {
        if shouldReloadMainView {
            collectionView?.reloadData()
        }
        if shouldRefreshDataSource {
            refreshDataSource()
        }
    }
    
    fileprivate var dataCount: Int {
        let count = dataSource.count()
        return count ?? 0
    }
    
    fileprivate var shouldReloadMainView: Bool {
        return dataCount == 0 && !dataSource.isFinishFirstRefresh
    }
    
    fileprivate var shouldRefreshDataSource: Bool {
        return dataCount == 0 || !dataSource.isFinishFirstRefresh
    }
    
    fileprivate func dataAt(index: Int, isAllowUpdate: Bool) -> Book? {
        return dataSource.dataAtIndex(index, isAllowUpdate: isAllowUpdate) as? Book
    }
    
    
}

// ================================================================================
// MARK:- CollectionViewWaterfallLayout delegate

extension HomeTabPageViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {

        let book = dataAt(index: indexPath.row, isAllowUpdate: false)
        if book == nil {
            return CollectionLoadMoreCell.loadMoreCellSize()
        }
        return HomeCollectionCell.cellHeightForObject(book)
    }
}

// ================================================================================
// MARK:- CollectionView delegate

extension HomeTabPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let book = dataAt(index: indexPath.row, isAllowUpdate: false)
        
        guard let b = book else { return }
        delegate?.pageViewController(self, bookDidSelect: b)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            delegate?.pageCollectionViewDidScroll(collectionView)
        }
    }
}

// ================================================================================
// MARK:- HomeCollectionCell delegate

extension HomeTabPageViewController: HomeCollectionCellDelegate {
    func homeCellLikeButtonTapped(_ cell: HomeCollectionCell, completion:@escaping (_ isLiked:Bool?, _ numLike: Int) ->Void) {
        
        if Me.sharedMe.isRegisterd == false {
            showUnRegisterAlert()
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

// ================================================================================
// MARK:- EmptyDataView delegate

extension HomeTabPageViewController: EmptyDataViewDelegate {
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
        return (contentHeight - HomePagerViewController.pullToRefreshInsetTop) / 2
    }
}

// ================================================================================
// MARK:- DataSource Delegate & Data Source Medhod
extension HomeTabPageViewController: BaseDataSourceDelegate {
    func completeRequest() {}
    func failedRequest(_ error: Error) {}
    
    func completeRequest(_ dataSource: BaseDataSource) {
        DispatchQueue.main.async { [weak self] in
            SVProgressHUD.dismiss()
            self?.onCompleteRequest()
        }
    }
    
    func failedRequest(_ dataSource: BaseDataSource, error: Error) {
        DispatchQueue.main.async { [weak self] in
            SVProgressHUD.dismiss()
            self?.onCompleteRequest()
        }
    }
    
    fileprivate func onCompleteRequest() {
        emptyView?.isHidden = dataCount > 0
        
        if let collectionView = collectionView {
            collectionView.pullToRefreshView.stopAnimating()
            collectionView.reloadData()
            collectionView.scrollIndicatorInsets = collectionView.contentInset
            collectionView.scrollIndicatorInsets.bottom = HomePagerViewController.collectionScrollBottom
        }
        
        delegate?.pageViewControllerDidCompleteRequerst(self)
    }
}


