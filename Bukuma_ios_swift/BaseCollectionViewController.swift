//
//  BKMBaseCollectionViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import CollectionViewWaterfallLayout
import SVProgressHUD

/**
 CollectionViewを作りたいときにこのはBaseCollectionViewControllerを継承して作られている
 LikeListViewControllerや、BoughtBookListViewControllerのように、cellClass,dataSourceClassを設定するだけで
 簡単にDataを扱うCollectionViewを作ることができる。
*/

open class BaseCollectionViewController: BaseDataSourceViewController,
    CollectionViewWaterfallLayoutDelegate,
    BaseCollectionCellDelegate,
    UICollectionViewDelegate,
UICollectionViewDataSource {
    
    var collectionView: UICollectionView?
    var loadMoreView: CollectionLoadMoreView?
    var viewUpdatedAt: Date?
    var viewReloadOnlyDataUpdated = false
    
    // ================================================================================
    // MARK: - setting
    
    deinit {
        collectionView?.delegate = nil
        collectionView = nil
    }
    
    var shouldReloadSection: Bool {
        return self.dataSource?.page == 1
    }
    
    // ================================================================================
    // MARK: - emptyData delegate
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "表示するコンテンツがありません"
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return "表示するコンテンツがありません"
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "img_ph_00")
    }
    
    override open func emptyViewCenterPositionY() -> CGFloat {
        let contentHeight: CGFloat = self.view.height - NavigationHeightCalculator.navigationHeight() - 36.0 - kAppDelegate.tabBarController.tabBar.height
        return (contentHeight - self.collectionView!.contentInsetTop) / 2
    }
    
    func collectionScrollBottom() ->CGFloat {
        return NavigationHeightCalculator.isTethering() ? kAppDelegate.tabBarController.tabBar.height -
            +NavigationHeightCalculator.gapStatusBarHeightWithDefault() :  kAppDelegate.tabBarController.tabBar.height
    }
    
    // ================================================================================
    // MARK: - viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = kBackGroundColor
        collectionView = self.generateCollectionView()
        
        collectionView!.addSubview(emptyDataView!)
        
        let collectionCellClass = self.registerCellClass() as! BaseCollectionCell.Type
        collectionView!.register(collectionCellClass, forCellWithReuseIdentifier:NSStringFromClass(collectionCellClass))
        collectionView!.register(CollectionLoadMoreCell.self, forCellWithReuseIdentifier: NSStringFromClass(CollectionLoadMoreCell.self))
        collectionView!.register(CollectionLoadMoreView.self, forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionFooter, withReuseIdentifier: NSStringFromClass(CollectionLoadMoreView.self))
        self.view.insertSubview(collectionView!, belowSubview: navigationBarView!)
        
        emptyDataView?.adjustEmptyView()
        
    }
    
    
    // ================================================================================
    // MARK: -collectionViewGenerate
    
    open func generateCollectionView() ->UICollectionView {
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
        collectionView.contentInsetBottom  = 10.0
        collectionView.scrollsToTop = true
        
        collectionView.addPull(toRefreshScrollHeight: self.pullToRefreshScrollHeight(),
                               contentInsetTop: self.pullToRefreshInsetTop()) {[weak self] () in
                                self?.refreshDataSource()
        }
        
        return collectionView
    }
    
    // ================================================================================
    // MARK: - dataSourceDelegate
    open override func completeRequest() {
        DispatchQueue.main.async {
            self.collectionView?.pullToRefreshView.stopAnimating()
            SVProgressHUD.dismiss()

            self.relaodCollectionViewIfNeed()

            self.emptyDataView?.isHidden = (self.dataSource?.count() ?? 0) > 0
            self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
            self.collectionView?.scrollIndicatorInsets.bottom = self.collectionScrollBottom()
        }
    }
    
    open override func failedRequest(_ error: Error) {
        DispatchQueue.main.async {
            self.collectionView?.pullToRefreshView.stopAnimating()
            SVProgressHUD.dismiss()

            self.relaodCollectionViewIfNeed()

            self.emptyDataView?.isHidden = (self.dataSource?.count() ?? 0) > 0
            self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
            self.collectionView?.scrollIndicatorInsets.bottom = self.collectionScrollBottom()
        }
    }
    
    
    // ================================================================================
    // MARK: - other
    
    open override func scrollToTop() {
        collectionView!.setContentOffset(collectionView!.contentOffset, animated: true)
        UIView.animate(withDuration:0.25) { () -> Void in
            self.collectionView!.contentInsetTop = self.pullToRefreshInsetTop()
            self.collectionView!.contentOffsetY = -self.collectionView!.contentInsetTop
        }
    }
    
    open func reloadCollectionView() {
        if self.shouldReloadMainView == true {
            self.dataSource?.update()
            self.relaodCollectionViewIfNeed()
        }
        
        if self.shouldRefreshDataSource == true {
            self.refreshDataSource()
        }
    }
    
    private func relaodCollectionViewIfNeed() {
        guard let dataSource = dataSource, let collectionView = collectionView else {
            return
        }
        
        if !viewReloadOnlyDataUpdated {
            collectionView.reloadData()
            return
        }
        
        if let viewUpdatedAt = viewUpdatedAt ,viewUpdatedAt > dataSource.updatedAt {
            return
        }
        
        collectionView.reloadData()
        viewUpdatedAt = Date()
    }
    
    // ================================================================================
    // MARK: -collectionViewDelegate, DataSouece
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.count() ?? 0
    }
    
    open func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let object = dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false)
        
        if object == nil {
            return CollectionLoadMoreCell.loadMoreCellSize() // CollectionLoadMoreView.size()
        }
        ///ここライブラリの仕様でwidthとheightの比率を指定するような形になっている。なので、比率だけ指定すれば、端末にあったレイアウトになる
        ///基本的はsize。継承先で色々その画面に応じて変えている
        return CGSize(width: 1, height: 1.65)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let object: BaseModelObject? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate:true) as? BaseModelObject
        var cell: UICollectionViewCell! = UICollectionViewCell(frame: CGRect.zero)
        var cellIdentifier: String! = ""
        let collectionCellClass = self.registerCellClass() as! BaseCollectionCell.Type
        
        if object == nil {
            
            cellIdentifier = NSStringFromClass(CollectionLoadMoreCell.self)
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            if cell == nil {
                cell = CollectionLoadMoreCell()
            }
            
            //(cell as? CollectionLoadMoreCell)?.startAnimationg()
            loadMoreView?.startLoading()
            DBLog(loadMoreView)
            
        } else {
            cellIdentifier = NSStringFromClass(collectionCellClass)
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            if cell == nil {
                cell = collectionCellClass.init(frame: CGRect.zero)
            }
            (cell as? BaseCollectionCell)?.delegate = self
            self.setModelObject(object, toCell: cell as? BaseCollectionCell)
            
        }
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == CollectionViewWaterfallElementKindSectionFooter) {
            
            loadMoreView = collectionView.dequeueReusableSupplementaryView(ofKind: CollectionViewWaterfallElementKindSectionFooter, withReuseIdentifier: NSStringFromClass(CollectionLoadMoreView.self), for: indexPath) as? CollectionLoadMoreView
            
            if loadMoreView == nil {
                loadMoreView = CollectionLoadMoreView()
            }
            
            return loadMoreView!
        }
        return UICollectionReusableView(frame: CGRect.zero)
    }
    
    func setModelObject(_ object: BaseModelObject?, toCell: BaseCollectionCell?) {
        toCell?.cellModelObject = object
    }
    
    func startAnimationFooterView() {
        loadMoreView?.startLoading()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is CollectionLoadMoreCell {
            (cell as? CollectionLoadMoreCell)?.stopAnimationg()
            loadMoreView?.stopLoading()
        }
    }
}
