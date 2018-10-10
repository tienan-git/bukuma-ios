//
//  LikeListViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/14.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class LikeListViewController: BaseCollectionViewController, HomeCollectionCellDelegate {
    
    override open func registerDataSourceClass() -> AnyClass? {
        return LikeListDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return HomeCollectionCell.self
    }
    
    override open func pullToRefreshInsetTop() -> CGFloat {
        return NavigationHeightCalculator.navigationHeight()
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "いいねした商品"
        self.title = "いいねした商品"
    }
    
    override open  func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "いいねした本がまだありません"
    }
    
    override open  func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return "いいねしておくと、より安い値段の本が出品された時にお知らせが受け取れます"
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "img_ph_02")
    }

    override func collectionScrollBottom() ->CGFloat {
        return 0
    }
    
    // ================================================================================
    // MARK: -init
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadCollectionView()
    }
    
    override open func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let object = dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Book
        
        if object == nil {
            return CollectionLoadMoreCell.loadMoreCellSize() // CollectionLoadMoreView.size()
        }
        return HomeCollectionCell.cellHeightForObject(object)
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let object: Book? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate:false) as? Book
        if object != nil {
            self.goDetailBook(object!, completion: nil)
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
