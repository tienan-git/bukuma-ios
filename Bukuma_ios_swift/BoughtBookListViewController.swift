//
//  BoughtBookListTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/04.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD

open class BoughtBookListViewController: BaseCollectionViewController, HomeCollectionCellDelegate {
    
    // ================================================================================
    // MARK:- setting
    
    override open func registerDataSourceClass() -> AnyClass? {
        return BoughtBookListDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return HomeCollectionCell.self
    }
    
    override func collectionScrollBottom() ->CGFloat {
        return 0
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "まだ本を購入していません"
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return "ブクマで買った本の一覧がここで見られますあなたが素敵な１冊に出会えますように"
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "img_ph_03")
    }

    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "購入した商品"
         self.title = "購入した商品"
    }
    
    // ================================================================================
    // MARK: init
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ================================================================================
    // MARK: segmentedButtonsViewDelegate
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.reloadCollectionView()
    }
    
    override func setModelObject(_ object: BaseModelObject?, toCell: BaseCollectionCell?) {
        toCell?.cellModelObject = (object as? Transaction)?.book
    }

    override open func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let object: Transaction? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate:false) as? Transaction
        
        if object == nil {
            return CollectionLoadMoreCell.loadMoreCellSize() // CollectionLoadMoreView.size()
        }
        return HomeCollectionCell.cellHeightForObject(object?.book)
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let object: Transaction? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate:false) as? Transaction
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false

        if object != nil {
            object?.getItemTransactionInfo({ (error) in
                let controller: ShippingProgressTableViewController = ShippingProgressTableViewController(transaction: object!)
                controller.view.clipsToBounds = true
                self.navigationController?.pushViewController(controller, animated: true)
                self.view.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
            })
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
