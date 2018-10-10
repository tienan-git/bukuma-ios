//
//  AdressRegisterViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

open class AdressInfoViewController: BaseTableViewController {
    
    // ================================================================================
    // MARK: setting
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }
    
    override open func scrollIndicatorInsetBottom() ->CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return AdressDataSource.self
    }
    
    override open func initializeNavigationLayout() {
        let rightButton =  BarButtonItem.barButtonItemWithText("編集",
                                                               s_text: "完了",
                                                               isBold: true,
                                                               isLeft: false,
                                                               target: self,
                                                               action: #selector(self.rightButtonTapped(_:)))
        self.setNavigationBarButton(rightButton, isLeft: false)
        self.navigationBarTitle = "お届け先住所"
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return ""
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return ""
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "")
    }
    
    // ================================================================================
    // MARK: init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        let addressCellNib = UINib(nibName: AddressAndNameWithDefaultCheckCell.nibName, bundle: nil)
        self.tableView?.register(addressCellNib, forCellReuseIdentifier: AddressAndNameWithDefaultCheckCell.reuseID)

        self.refreshDataSource()
        
        tableView!.showsPullToRefresh = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView!.showsVerticalScrollIndicator = false
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh(_:)), name: NSNotification.Name(rawValue: AdressRegisterViewControllerShouldRefreshKey), object: nil)
    }
    
    func refresh(_ sender: NSNotification) {
        self.refreshDataSource()
    }
    
    func rightButtonTapped(_ sender: UIButton) {
        sender.isSelected =  !sender.isSelected
        if Utility.isEmpty(Adress.defaultAdress()) {
            return
        }
        tableView!.setEditing(!tableView!.isEditing, animated: true)
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.dataSource?.count() ?? 0) + 2
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return BaseTitleCell.cellHeightForObject(nil)
        } else if (self.dataSource?.count() ?? 0) == 0 && indexPath.row == 1 {
            return AdressInfoRegisterNewAdressCell.cellHeightForObject(nil)
        } else if (self.dataSource?.count() ?? 0) > 0 && indexPath.row <= (self.dataSource?.count() ?? 0) && indexPath.row > 0 {
            let adress: Adress? = self.dataSource?.dataAtIndex(indexPath.row - 1, isAllowUpdate: false) as? Adress
            return AddressAndNameWithDefaultCheckCell.cellHeightForObject(adress)
        } else if (self.dataSource?.count() ?? 0) > 0 && indexPath.row > (self.dataSource?.count() ?? 0) {
            return AdressInfoRegisterNewAdressCell.cellHeightForObject(nil)
        } else {
            return 0
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        if indexPath.row == 0 {
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "お届け先情報"
        } else if (self.dataSource?.count() ?? 0) == 0 && indexPath.row == 1 {
            cellIdentifier = NSStringFromClass(AdressInfoRegisterNewAdressCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?AdressInfoRegisterNewAdressCell
            if cell == nil {
                cell = AdressInfoRegisterNewAdressCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
        } else if (self.dataSource?.count() ?? 0) > 0 && indexPath.row <= (self.dataSource?.count() ?? 0) && indexPath.row > 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: AddressAndNameWithDefaultCheckCell.reuseID) as? AddressAndNameWithDefaultCheckCell
            let address: Adress? = self.dataSource?.dataAtIndex(indexPath.row - 1, isAllowUpdate: false) as? Adress
            cell?.cellModelObject = address
        } else if (self.dataSource?.count() ?? 0) > 0 && indexPath.row > (self.dataSource?.count() ?? 0) {
            cellIdentifier = NSStringFromClass(AdressInfoRegisterNewAdressCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?AdressInfoRegisterNewAdressCell
            if cell == nil {
                cell = AdressInfoRegisterNewAdressCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            cell?.accessoryView = UIImageView(image: UIImage(named: "ic_to"))
        }
        return cell!
    }
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.cellForRow(at: indexPath) is AddressAndNameWithDefaultCheckCell {
            return tableView.isEditing ? .delete : .none
        } else {
            return .none
        }
    }
    
    open func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]? {
        let title: String = "削除"
        let cell = tableView.cellForRow(at: indexPath) as? BaseTableViewCell
        return [UITableViewRowAction(style: .default,
                                     title: title) { [weak self] (action, indexPass) in
                                        if cell is AddressAndNameWithDefaultCheckCell {
                                            self?.deleteAdress(cell?.cellModelObject as! Adress)
                                        }
            }]
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return tableView.cellForRow(at: indexPath) is AddressAndNameWithDefaultCheckCell
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if indexPath.row == 0 {
            return
        } else if indexPath.row == (self.dataSource?.count() ?? 0) + 1 {
            let controller: AdressRegisterViewController = AdressRegisterViewController(adress: nil)
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
        } else  {
            RMUniversalAlert.show(in: self,
                                  withTitle: "お届け先住所を変更しますか?",
                                  message: "現在取引中のお届け先住所は変更できません",
                                  cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: ["変更"]) { (al, index) in
                                    DispatchQueue.main.async {
                                        if index == al.firstOtherButtonIndex {
                                            let object: Adress = self.dataSource!.dataAtIndex(indexPath.row - 1, isAllowUpdate: false) as! Adress

                                            if indexPath.row == self.dataSource!.dataSource!.indexOfObject(object)! + 1 {
                                                if object.isDefaultAdress == true {
                                                    return
                                                }

                                                object.isDefaultAdress = true

                                                SVProgressHUD.show()
                                                Adress.editAdress(object, completion: {[weak self] (error) in
                                                    DispatchQueue.main.async {
                                                        if error != nil {
                                                            return
                                                        }
                                                        self?.refreshDataSource()
                                                    }
                                                })
                                            }
                                        }
                                    }
            }
        }
    }


    func deleteAdress(_ adress: Adress) {
        self.view.isUserInteractionEnabled = false
        if Adress.defaultAdress()!.id == adress.id {
            self.simpleAlert(nil,
                             message: "この配送先は現在選択されています。削除したい場合は新しく配送先を追加するか他の配送先を選択してから再度お試しください",
                             cancelTitle: "OK",
                             completion: { [weak self] in
                                DispatchQueue.main.async {
                                    self?.tableView?.setEditing(false, animated: true)
                                    (self?.navigationItem.rightBarButtonItem?.customView as? UIButton)?.isSelected = false
                                    self?.view.isUserInteractionEnabled = true
                                }
                })
            return
        }
        adress.deleteAdress {[weak self] (error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.view.isUserInteractionEnabled = true
                    if error?.errorCodeType == .badRequest {
                        self?.simpleAlert(nil, message: "この住所は現在取引中の配送先として使用されているため削除できません", cancelTitle: "OK", completion: nil)
                        return
                    }
                    self?.simpleAlert(nil, message: error!.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                self?.refreshDataSource()
                SVProgressHUD.dismiss()
                self?.simpleAlert(nil, message: "削除しました！", cancelTitle: "OK", completion: { [weak self] in
                    DispatchQueue.main.async {
                        self?.view.isUserInteractionEnabled = true
                    }
                    })
            }
        }
    }
}
