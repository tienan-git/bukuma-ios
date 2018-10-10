//
//  ChatListViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/13.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

open class ChatListViewController: BaseTableViewController {
    
    // ================================================================================
    // MARK: setting
    
    var rightButton: UIButton?
    
    override open func registerDataSourceClass() -> AnyClass? {
        return ChatListDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return ChatListCell.self
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "まだチャットはありません"
    }
    
    override var shouldRefreshDataSource: Bool {
        get {
            return true
        }
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "やりとり"
        let rightButton: BarButtonItem = BarButtonItem.barButtonItemWithText("編集",
                                                                             s_text: "完了",
                                                                             isBold: true,
                                                                             isLeft: false,
                                                                             target: self,
                                                                             action: #selector(self.rightButtonTapped(_:)))
        self.setNavigationBarButton(rightButton, isLeft: false)
    }

    override open func footerHeight() -> CGFloat {
        return kAppDelegate.tabBarController.tabBar.height
    }

    // ================================================================================
    // MARK: init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.refreshDataSource()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ChatRoom.sumUnReadCount = 0
        TabManager.sharedManager.setActivityBadgeCount(0, tabIndex: 3)
        self.reloadTableView()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ChatRoom.sumUnReadCount = 0
        TabManager.sharedManager.setActivityBadgeCount(0, tabIndex: 3)
        tableView!.setEditing(false, animated: false)
    }
    
    func rightButtonTapped(_ sender: UIButton) {
        rightButton = sender
        if dataSource?.count() == 0 {
            if tableView?.isEditing == true {
                tableView!.setEditing(false, animated: true)
            }
            return
        }
        sender.isSelected =  !sender.isSelected
        tableView!.setEditing(!tableView!.isEditing, animated: true)
    }
    
    // ================================================================================
    // MARK:- tableView
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let room: ChatRoom? = dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? ChatRoom
        room?.numberOfUnreadCount = 0
        let cell: ChatListCell? = self.tableView?.cellForRow(at: indexPath) as?  ChatListCell
        cell?.unReadCountLabel?.isHidden = true
        
        if room != nil {            
            let controller: ChatRoomViewController = ChatRoomViewController(room: room!)
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let cell: BaseTableViewCell? = self.tableView(tableView, cellForRowAt: indexPath) as? BaseTableViewCell
        if cell is ChatListCell {
            return tableView.isEditing ? .delete : .none
        }
        return .none
    }
    
    open func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]? {
        let title: String = "削除"
        let cell: BaseTableViewCell = self.tableView(tableView, cellForRowAt: indexPath) as! BaseTableViewCell
        
        return [UITableViewRowAction(style: .default,
        title: title) {[weak self] (action, indexPass) in
            if cell is ChatListCell {
                self?.deleteChatRoom(cell.cellModelObject as! ChatRoom)
            }
            }]
    }

    func deleteChatRoom(_ chatRoom: ChatRoom) {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "やりとりを削除すると相手からも削除されます。よろしいでしょうか?", cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: "削除",
                              otherButtonTitles: nil) { [weak self] (al, index) in
                                DispatchQueue.main.async {
                                    if index == al.destructiveButtonIndex {
                                        SVProgressHUD.show()
                                        chatRoom.deleteChatRoom { [weak self] (error) in
                                            DispatchQueue.main.async {
                                                if error != nil {
                                                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                                                    return
                                                }
                                                SVProgressHUD.dismiss()

                                                if self?.dataSource?.count() == 0 {
                                                    self?.rightButton?.isSelected = false
                                                }

                                                self?.simpleAlert(nil, message: "削除しました", cancelTitle: "OK", completion: nil)
                                            }
                                        }
                                    } else {
                                        self?.tableView?.setEditing(false, animated: true)
                                        self?.rightButton?.isSelected = false
                                    }
                                }
        }
    }

    func enterTheRoom(_ chatRoom: ChatRoom) {
        let controller: ChatRoomViewController = ChatRoomViewController(room: chatRoom)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
