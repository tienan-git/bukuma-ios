//
//  SearchMerchandiseBookGridViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/19.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import CollectionViewWaterfallLayout
import SVProgressHUD

open class SearchMerchandiseBookGridViewController: BaseCollectionViewController,
HomeCollectionCellDelegate {
    
    var loadMoreFooterView: SearchLoadMoreView?
    var loadingView: LoadingImageView?
    
    deinit {
        (self.dataSource as? SearchBookDataSource)?.cancelTimer()
        SVProgressHUD.dismiss()
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return SearchBookDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return HomeCollectionCell.self
    }
    
    override var shouldReloadSection: Bool {
        return self.dataSource?.page == 0
    }
    
    override func collectionScrollBottom() ->CGFloat {
        return 0
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = (self.dataSource as? SearchBookDataSource)?.searchText
        self.title = (self.dataSource as? SearchBookDataSource)?.searchText
    }

    required public init(text: String) {
        super.init(nibName: nil, bundle: nil)
        (self.dataSource as? SearchBookDataSource)?.setNewSearchText(text, completion: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.show()
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        (self.dataSource as? SearchBookDataSource)?.getFromOurServerAndAmazonOrRakuten()
        
        collectionView?.contentInset.bottom = 20.0
        collectionView?.scrollIndicatorInsets.bottom = 0
        
        collectionView?.register(SearchLoadMoreView.self, forSupplementaryViewOfKind:CollectionViewWaterfallElementKindSectionFooter, withReuseIdentifier: NSStringFromClass(SearchLoadMoreView.self))
        (collectionView?.collectionViewLayout as? CollectionViewWaterfallLayout)?.footerHeight = Float(SearchLoadMoreView.size().height)
        (collectionView?.collectionViewLayout as? CollectionViewWaterfallLayout)?.headerHeight = 0
        
        loadingView = LoadingImageView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.appearLoadMoreView), name: NSNotification.Name(rawValue: SearchBookDataSourceShouldShowLoadMoreView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showLoadingView), name: NSNotification.Name(rawValue: SearchBookDataSourceStartCreatingSearchOrderKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopShowLoadingView), name: NSNotification.Name(rawValue: SearchBookDataSourceNoBooksFromSearchOrderKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopShowLoadingView), name: NSNotification.Name(rawValue: SearchBookDataSourceFinishCreatingSearchOrderKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.disappearLoadMoreView), name: NSNotification.Name(rawValue: SearchBookDataSourceNoBooksFromSearchOrderKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadMoreViewLoadMoreButtonTapped), name: NSNotification.Name(rawValue: SearchLoadMoreViewDidTappedNotification), object: nil)

    }
    
    override open func completeRequest() {
        super.completeRequest()
        
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.loadMoreFooterView?.isHidden = false
            if self.dataSource?.count() == 0 {
                self.loadMoreFooterView?.isHidden = true
            }
        }
    }
    
    func loadMoreViewLoadMoreButtonTapped() {
        loadMoreFooterView?.startLoading()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        (self.dataSource as? SearchBookDataSource)?.getFromOurServerAndAmazonOrRakuten()
    }
    
    func showLoadingView() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = false
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.loadingView?.appearOnViewController(self.navigationController ?? self)
            self.loadingView?.startAnimation()
        }
    }
    
    func stopShowLoadingView() {
        DispatchQueue.main.async {
            self.loadingView?.disappear(nil)
            self.loadingView?.stopAnimation()
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
    
    func appearLoadMoreView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration:0.35) {
                (self.collectionView?.collectionViewLayout as? CollectionViewWaterfallLayout)?.footerHeight = Float(SearchLoadMoreView.size().height)
                self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
            }
        }
    }
    
    func disappearLoadMoreView(_ notification: Foundation.Notification) {
        DispatchQueue.main.async {
            self.loadMoreFooterView?.stopLoading()
            
            UIView.animate(withDuration:0.35) {
                (self.collectionView?.collectionViewLayout as? CollectionViewWaterfallLayout)?.footerHeight = 0
                self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
            }
        }
    }
    
    override open func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let object = dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Book
        
        if object == nil {
            return CollectionLoadMoreCell.loadMoreCellSize() // CollectionLoadMoreView.size()
        }
        return HomeCollectionCell.cellHeightForObject(object)
    }

    override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == CollectionViewWaterfallElementKindSectionFooter) {
            
            loadMoreFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: CollectionViewWaterfallElementKindSectionFooter, withReuseIdentifier: NSStringFromClass(SearchLoadMoreView.self), for: indexPath) as? SearchLoadMoreView
            
            if loadMoreFooterView == nil {
                loadMoreFooterView = SearchLoadMoreView()
            }
            
            loadMoreFooterView?.isHidden = false
            if self.dataSource?.count() == 0 {
                loadMoreFooterView?.isHidden = true
            }
            
            return loadMoreFooterView!
        }
        return UICollectionReusableView(frame: CGRect.zero)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loadMoreFooterView?.stopLoading()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let book: Book? = self.dataSource!.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Book
        
        if book != nil {
            self.goDetailBook(book!, completion: nil)
        }
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

}
