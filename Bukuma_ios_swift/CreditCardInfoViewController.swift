//
//  CreditCardRegisterViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

open class CreditCardInfoViewController: BaseTableViewController {
    
    // ================================================================================
    // MARK: setting
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }

    override open func scrollIndicatorInsetBottom() ->CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return CreditDataSource.self
    }
    
    override open func initializeNavigationLayout() {
        let rightButton =  BarButtonItem.barButtonItemWithText("編集",
                                                               s_text: "完了",
                                                               isBold: true,
                                                               isLeft: false,
                                                               target: self,
                                                               action: #selector(self.rightButtonTapped(_:)))
        self.setNavigationBarButton(rightButton, isLeft: false)
        self.navigationBarTitle = "クレジットカード情報"
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
        
        self.refreshDataSource()
        
        tableView!.showsPullToRefresh = false
        self.automaticallyAdjustsScrollViewInsets = false
        tableView!.showsVerticalScrollIndicator = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh(_:)), name: NSNotification.Name(rawValue: CreditCardViewControllerShouldRefreshKey), object: nil)
    }
    
    func refresh(_ sender: NSNotification) {
        self.refreshDataSource()
    }
    
    func rightButtonTapped(_ sender: UIButton) {
        sender.isSelected =  !sender.isSelected
        if Utility.isEmpty(CreditCard.defaultCard()) {
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
            return 50
        } else if (self.dataSource?.count() ?? 0) > 0 && indexPath.row <= (self.dataSource?.count() ?? 0) && indexPath.row > 0 {
            let card: CreditCard? = self.dataSource?.dataAtIndex(indexPath.row - 1, isAllowUpdate: false) as? CreditCard
            return  CreditCardInfoCell.cellHeightForObject(card)
        } else if (self.dataSource?.count() ?? 0) > 0 && indexPath.row > (self.dataSource?.count() ?? 0) {
            return 50.0
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
            (cell as! BaseTitleCell).title = "クレジットカード"
            
        } else if self.dataSource!.count() == 0 && indexPath.row == 1 {
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "クレジットカードを追加する"
            (cell as! BaseIconTextTableViewCell).titleLabel!.textColor = kMainGreenColor
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_add")
            (cell as! BaseIconTextTableViewCell).rightImage = UIImage(named: "ic_to")
            
        } else if (self.dataSource?.count() ?? 0) > 0 && indexPath.row <= (self.dataSource?.count() ?? 0) && indexPath.row > 0 {
            cellIdentifier = NSStringFromClass(CreditCardInfoCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?CreditCardInfoCell
            if cell == nil {
                cell = CreditCardInfoCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            let card: CreditCard? = self.dataSource?.dataAtIndex(indexPath.row - 1, isAllowUpdate: false) as? CreditCard
            (cell as! CreditCardInfoCell).cellModelObject = card
            
        } else if (self.dataSource?.count() ?? 0) > 0 && indexPath.row > (self.dataSource?.count() ?? 0) {
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "クレジットカードを追加する"
            (cell as! BaseIconTextTableViewCell).titleLabel!.textColor = kMainGreenColor
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_add")
            (cell as! BaseIconTextTableViewCell).rightImage = UIImage(named: "ic_to")
        }
        
        return cell!
    }
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let cell: BaseTableViewCell? = self.tableView(tableView, cellForRowAt: indexPath) as? BaseTableViewCell
        if cell is CreditCardInfoCell {
            return tableView.isEditing ? .delete : .none
        }
        return .none
    }
    
    open func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]? {
        let title: String = "削除"
        let cell: BaseTableViewCell = self.tableView(tableView, cellForRowAt: indexPath) as! BaseTableViewCell
        
        return [UITableViewRowAction(style: .default,
        title: title) {[weak self] (action, indexPass) in
            if cell is CreditCardInfoCell {
                self?.deleteCard(cell.cellModelObject as! CreditCard)
            }
            }]
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        let cell :CreditCardInfoCell? = tableView.cellForRow(at: indexPath) as? CreditCardInfoCell
        if cell != nil {
            return true
        }
        return false
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if indexPath.row == 0 {
            return
        } else if indexPath.row == (self.dataSource?.count() ?? 0) + 1 {
            let controller: CreditCardRegisterViewController = CreditCardRegisterViewController(card: nil)
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
        } else  {
            RMUniversalAlert.show(in: self,
                                  withTitle: "クレジットカードを変更しますか?",
                                  message: "現在取引中のクレジットカード情報は変更できません",
                                  cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: ["変更"]) { (al, index) in
                                    DispatchQueue.main.async {
                                        if index == al.firstOtherButtonIndex {
                                            let object: CreditCard = self.dataSource!.dataAtIndex(indexPath.row - 1, isAllowUpdate: false) as! CreditCard
                                            if indexPath.row == self.dataSource!.dataSource!.indexOfObject(object)! + 1 {
                                                object.isDefault = true
                                                SVProgressHUD.show()
                                                object.changeDefaultCard({ (error) in
                                                    DispatchQueue.main.async {
                                                        if error != nil {
                                                            self.simpleAlert(nil, message: error!.errorDespription, cancelTitle: "OK", completion: nil)

                                                            return
                                                        }
                                                        self.refreshDataSource()
                                                    }
                                                })
                                            }
                                        }
                                    }
            }
        }
    }

    func deleteCard(_ card: CreditCard) {
        self.view.isUserInteractionEnabled = false

        // もしsecurityCodeが間違っていた場合決済できないので、その場合は削除して登録し直してもらう
        if card.validsecurityCode == "false" {
            card.deleteCards(true) {[weak self] (error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.view.isUserInteractionEnabled = true
                        self?.tableView?.setEditing(false, animated: true)
                        (self?.navigationItem.rightBarButtonItem?.customView as? UIButton)?.isSelected = false
                        self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                        return
                    }
                    self?.tableView?.reloadData()
                    self?.simpleAlert(nil, message: "削除しました！", cancelTitle: "OK", completion: { [weak self] in
                        DispatchQueue.main.async {
                            self?.view.isUserInteractionEnabled = true
                        }
                        })
                }
            }
            return
        }
        
        // can not delete default Card
        if CreditCard.defaultCard()?.id ?? "0" == card.id {
            self.simpleAlert(nil,
                                  message: "このクレジットカードは現在選択されています。削除したい場合は新しくクレジットカードを追加するか他のクレジットカードを選択してから再度お試しください",
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
        
        card.deleteCards(false) {[weak self] (error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.view.isUserInteractionEnabled = true
                    self?.simpleAlert(nil, message: error!.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                self?.tableView?.reloadData()
                self?.simpleAlert(nil, message: "削除しました！", cancelTitle: "OK", completion: { [weak self] in
                    DispatchQueue.main.async {
                        self?.view.isUserInteractionEnabled = true
                    }
                })
            }
        }
    }
}
