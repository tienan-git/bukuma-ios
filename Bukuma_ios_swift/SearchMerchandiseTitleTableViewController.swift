//
//  SearchMerchandiseTitleTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/11.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD

class SearchMerchandiseTitleTableViewController: BaseTableViewController {
    
    override open func registerDataSourceClass() -> AnyClass? {
        return SearchMerchandiseDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return SearchMerchandiseCell.self
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = (self.dataSource as? SearchBookDataSource)?.searchText
        self.title = (self.dataSource as? SearchMerchandiseDataSource)?.searchText
    }
    
    required public init(text: String) {
        super.init(nibName: nil, bundle: nil)
        (self.dataSource as? SearchMerchandiseDataSource)?.setNewSearchText(text)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
       
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTableView()
    }

    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let object: Book? = dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Book
        
        if object == nil {
            return
        }
        
        self.goDetailBook(object!, completion: nil)
        
    }
}

extension SearchMerchandiseTitleTableViewController: SearchMerchandiseCellDelegate {
    open func searchMerchandiseCellLikeButtonTapped(_ cell: SearchMerchandiseCell, completion:@escaping (_ isLiked:Bool?, _ numLike: Int) ->Void) {
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
