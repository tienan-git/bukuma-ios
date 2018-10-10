//
//  BlockingListViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

open class BlockingListViewController: BaseTableViewController {
    
    var rightButton: UIButton?
    
    // MARK: setting
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }
    
    override open func scrollIndicatorInsetBottom() ->CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return BlockingDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return BlockingUserCell.self
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "ブロックしているユーザーはいません"
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return "ブロックしているユーザーを解除することができます。"
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "img_ph_00")
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "ブロックリスト"
        let rightButton: BarButtonItem = BarButtonItem.barButtonItemWithText("編集",
                                                                             s_text: "完了",
                                                                             isBold: true,
                                                                             isLeft: false,
                                                                             target: self,
                                                                             action: #selector(self.rightButtonTapped(_:)))
        self.setNavigationBarButton(rightButton, isLeft: false)
    }

    // ================================================================================
    // MARK: init
    
    deinit {
        DBLog("-----------deinit BlockingListViewController --------")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ================================================================================
    // MARK:- viewC
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTableView()
    }
    
    func rightButtonTapped(_ sender: UIButton) {
        rightButton = sender
        if dataSource?.count() == 0 {
//            if tableView?.dismiss(animated: true, completion: nil) == true {
//                tableView!.setEditing(false, animated: true)
//            }
            return
        }
        sender.isSelected =  !sender.isSelected
        
        tableView!.setEditing(!tableView!.isEditing, animated: true)
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return tableView.isEditing ? .delete : .none
    }
    
    open func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]? {
        let title: String = "解除"
        let cell: BlockingUserCell = self.tableView(tableView, cellForRowAt: indexPath) as! BlockingUserCell
        
        return [UITableViewRowAction(style: .default,
        title: title) {[weak self] (action, indexPass) in
            self?.unblock(cell.cellModelObject as! User)
            }]
    }
    
    func unblock(_ user: User) {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "ブロック解除しますか?",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["解除"]) {[weak self] (al, index) in
                                DispatchQueue.main.async {
                                    if index == al.firstOtherButtonIndex {
                                        SVProgressHUD.show()
                                        user.unblockUser { (error) in
                                            SVProgressHUD.dismiss()
                                            if error != nil {
                                                self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                                                return
                                            }
                                            self?.refreshDataSource()
                                            self?.simpleAlert(nil, message: "解除しました", cancelTitle: "OK", completion: nil)
                                        }
                                    } else {
                                        self?.tableView?.setEditing(false, animated: true)
                                        self?.rightButton?.isSelected = false
                                    }
                                }
        }
    }

    override open func didUserIconTapped(_ user: User?) {}

}
