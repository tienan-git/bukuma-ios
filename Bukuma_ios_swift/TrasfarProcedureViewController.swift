//
//  MoneyReqestTrasfarProcedureViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class TrasfarProcedureViewController: BaseTableViewController,
BaseTextFieldDelegate,
BaseTextFieldPickerCellDelegate {
    
    fileprivate var sections = [Section]()
    fileprivate var tmpBank: Bank? = Bank.cachedBankList()?[0] ?? Bank()
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate enum TrasfarProcedureTableViewSectionType: Int {
        case trasfarProcedure
    }
    
    fileprivate enum TrasfarProcedureTableViewRowType: Int {
        case trasfarProcedureTitle
        case trasfarProcedureBankName
        case trasfarProcedureAccountType
        case trasfarProcedureBranchCode
        case trasfarProcedureAccountCode
        case trasfarProcedureAccountHolderFirstName
        case trasfarProcedureAccountHolderLastName
    }
    
    fileprivate struct Section {
        var sectionType: TrasfarProcedureTableViewSectionType
        var rowItems: [TrasfarProcedureTableViewRowType]
    }
    
    // ================================================================================
    // MARK: setting
    
    override var shouldShowRightNavigationButton: Bool {
        get {
            return true
        }
    }
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return BankDataSource.self
    }
    
    override func initializeTableViewStruct() {
        sections = [Section(sectionType: .trasfarProcedure, rowItems: [.trasfarProcedureTitle, .trasfarProcedureBankName, .trasfarProcedureAccountType, .trasfarProcedureBranchCode, .trasfarProcedureAccountCode, .trasfarProcedureAccountHolderFirstName, .trasfarProcedureAccountHolderLastName])]
    }
    
    override open func initializeNavigationLayout() {
        let rightButton = BarButtonItem.barButtonItemWithText("次へ",
                                                              isBold: true,
                                                              isLeft: false,
                                                              target: self,
                                                              action: #selector(self.rightButtonTapped(_:)))
        self.setNavigationBarButton(rightButton, isLeft: false)
        self.navigationBarTitle = "口座指定"
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
        
        tableView!.showsPullToRefresh = false
        tableView!.showsVerticalScrollIndicator = false
        tableView!.isFixTableScrollWhenChangeContentsSize = true
        isNeedKeyboardNotification = true
        
        emptyDataView?.removeFromSuperview()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tmpBank?.id == nil {
             self.refreshDataSource()
        }
        tmpBank = Bank.cachedBankList()?[0] ?? Bank()
    }
    
    override open func completeRequest() {
        super.completeRequest()
        
        tmpBank = Bank.cachedBankList()?[0] ?? Bank()
    }
    
    func rightButtonTapped(_ sender: BarButtonItem) {
        
        if Utility.isEmpty(tmpBank?.bankName) {
            self.simpleAlert(nil, message: "銀行名を入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpBank?.accountType) {
            self.simpleAlert(nil, message: "口座種別を入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpBank?.branch) {
            self.simpleAlert(nil, message: "支店コードを入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpBank?.branch?.characters.count != 3) {
            self.simpleAlert(nil, message: "支店コードは3文字の番号を入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpBank?.number) {
            self.simpleAlert(nil, message: "口座番号を入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        if Utility.isEmpty(tmpBank?.number?.characters.count != 7) {
            self.simpleAlert(nil, message: "口座番号は7文字の番号を入力してください。口座番号が7桁に満たない場合は、先頭部分に「0」を入力して、全部で7桁となるようにご入力ください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpBank?.firstNameKana) {
            self.simpleAlert(nil, message: "口座名義(セイ)を入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if tmpBank?.firstNameKana?.isKatakana() == false {
            self.simpleAlert(nil, message: "口座名義(セイ)はカタカナで入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if tmpBank?.lastNameKana?.isKatakana() == false {
            self.simpleAlert(nil, message: "口座名義(メイ)はカタカナで入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpBank?.lastNameKana) {
            self.simpleAlert(nil, message: "口座名義(メイ)を入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Bank.cachedBankList() != nil {
            if tmpBank?.isInfomationChanged(Bank.cachedBankList()![0]) == true {
                Bank.editBankAccount(tmpBank!, completion: { (error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            self.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                            return
                        }
                        let controller: TrasfarProcedureConformViewController = TrasfarProcedureConformViewController(bank: self.tmpBank!)
                        controller.view.clipsToBounds = true
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                })
            } else {
                let controller: TrasfarProcedureConformViewController = TrasfarProcedureConformViewController(bank: self.tmpBank!)
                controller.view.clipsToBounds = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            Bank.registerBankAccount(tmpBank!, completion: { (bank, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                        return
                    }
                    let controller: TrasfarProcedureConformViewController = TrasfarProcedureConformViewController(bank: bank!)
                    controller.view.clipsToBounds = true
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            })
        }
    }
    
    // ================================================================================
    // MARK: - textField delegate
    
    open func baseTextFieldDidBeginEditting(_ textField: UITextField) {
        var indexPath: IndexPath?
        
        if textField.tag == 1 {
            indexPath = IndexPath(row: 2, section: 0)
            let cell: BaseTextFieldPickerCell? = tableView?.cellForRow(at: indexPath!) as? BaseTextFieldPickerCell

            cell?.textFieldText = cell?.pickerContents?[0]
            tmpBank?.accountType = cell?.textFieldText
        }
    }
    
    open func edittingText<T : SignedNumber>(_ string: String?, type: T?) {
        switch type {
        case .some(0):
            tmpBank?.bankName = string
            break
        case .some(2):
            tmpBank?.branch = string
            break
        case .some(3):
            tmpBank?.number = string
            break
        case .some(4):
            tmpBank?.firstNameKana = string
            break
        case .some(5):
            tmpBank?.lastNameKana = string
            break
        default:
            break
        }
    }
    
    open func didSelectTextFieldShouldReturn() {}
    
    open func baseTextFieldReturnKeyTapped(_ textField: UITextField) {
        let nextKeyBoradCellTag: Int = textField.tag + 1
        let nextKeyBoradCellIndexPass = IndexPath(item: nextKeyBoradCellTag + 1, section: 0)
        let targetCell: BaseTextFieldCell? = tableView?.cellForRow(at: nextKeyBoradCellIndexPass) as? BaseTextFieldCell
        targetCell?.textField?.becomeFirstResponder()
    }

    open func baseTextFieldPickerCellFinishEditPicker(_ text: String, cell: BaseTextFieldPickerCell) {
        let nextKeyBoradCellTag: Int = cell.textField!.tag + 1
        let nextKeyBoradCellIndexPass = IndexPath(item: nextKeyBoradCellTag + 1, section: 0)
        let targetCell: BaseTextFieldCell? = tableView?.cellForRow(at: nextKeyBoradCellIndexPass) as? BaseTextFieldCell
        targetCell?.textField?.becomeFirstResponder()
    }
    
    open func baseTextFieldPickerCellEditingPicker(_ row: Int, cell: BaseTextFieldPickerCell) {
        if cell.textFieldType == 1 {
            tmpBank?.accountType = cell.textField?.text
        }
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return  sections.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowItems.count
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .trasfarProcedureTitle:
            return BaseTitleCell.cellHeightForObject(nil)
        default:
            return 50.0
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .trasfarProcedureTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "振込先口座の設定"
            break
            
        case .trasfarProcedureBankName:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "TrasfarProcedureBankName"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).titleText = "銀行"
            (cell as! BaseTextFieldCell).placeholderText = "(例)三井住友銀行"
            (cell as! BaseTextFieldCell).textFieldText = tmpBank?.bankName.map{$0}
            (cell as! BaseTextFieldCell).textFieldType = 0
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
            (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
            
        case .trasfarProcedureAccountType:
            cellIdentifier = NSStringFromClass(BaseTextFieldPickerCell.self) + "TrasfarProcedureAccountType"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldPickerCell
            if cell == nil {
                cell = BaseTextFieldPickerCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldPickerCell).selectionStyle = .none
            (cell as! BaseTextFieldPickerCell).titleText = "口座種別"
            (cell as! BaseTextFieldPickerCell).placeholderText = "(例)普通"
            (cell as! BaseTextFieldPickerCell).textFieldText = tmpBank?.accountType.map{$0}
            (cell as! BaseTextFieldPickerCell).textFieldType = 1
            (cell as! BaseTextFieldPickerCell).pickerContents = ["普通","当座","貯蓄"]
            (cell as! BaseTextFieldPickerCell).textField?.returnKeyType = .next
            (cell as! BaseTextFieldCell).keyboardToolbarButtonText = "次へ"
            (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
            
        case .trasfarProcedureBranchCode:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "TrasfarProcedureBranchCode"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).titleText = "支店コード"
            (cell as! BaseTextFieldCell).placeholderText = "(例)432"
            (cell as! BaseTextFieldCell).textFieldText = tmpBank?.branch.map{$0}
            (cell as! BaseTextFieldCell).textFieldType = 2
            (cell as! BaseTextFieldCell).textField!.keyboardType = .numberPad
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
            (cell as! BaseTextFieldCell).textFieldMaxLength = 3
            (cell as! BaseTextFieldCell).keyboardToolbarButtonText = "次へ"
            (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
            
        case .trasfarProcedureAccountCode:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "TrasfarProcedureAccountCode"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).titleText = "口座番号"
            (cell as! BaseTextFieldCell).placeholderText = "(例)2134567"
            (cell as! BaseTextFieldCell).textFieldText = tmpBank?.number.map{$0}
            (cell as! BaseTextFieldCell).textFieldType = 3
            (cell as! BaseTextFieldCell).textFieldMaxLength = 7
            (cell as! BaseTextFieldCell).textField!.keyboardType = .numberPad
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
            (cell as! BaseTextFieldCell).keyboardToolbarButtonText = "次へ"
            (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
            
        case .trasfarProcedureAccountHolderFirstName:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "TrasfarProcedureAccountHolderFirstName"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).isUserInteractionEnabled = true
            (cell as! BaseTextFieldCell).titleText = "口座名義 (セイ)"
            (cell as! BaseTextFieldCell).placeholderText = "(例)ヤマモト"
            (cell as! BaseTextFieldCell).textFieldType = 4
            (cell as! BaseTextFieldCell).textFieldText = tmpBank?.firstNameKana
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
            (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
            
        case .trasfarProcedureAccountHolderLastName:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "TrasfarProcedureAccountHolderLastName"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).titleText = "口座名義 (メイ)"
            (cell as! BaseTextFieldCell).placeholderText = "(例)サブロウ"
            (cell as! BaseTextFieldCell).textFieldType = 5
            (cell as! BaseTextFieldCell).textFieldText = tmpBank?.lastNameKana
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .done
            (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
        }
        return cell!
    }
}
