//
//  TrasfarProcedureConformViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

open class TrasfarProcedureConformViewController: BaseTableViewController,
ProfileSettingSaveButtonCellDelegate,
BaseTextFieldDelegate {
    
    fileprivate var sections = [Section]()
    var tmpBank: Bank?
    var amount: String = ""
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate enum TrasfarProcedureConformTableViewSectionType: Int {
        case trasfarProcedureConform
    }
    
    fileprivate enum TrasfarProcedureConformTableViewRowType: Int {
        case trasfarProcedureConformPriceTrasfard
        case trasfarProcedureConformCurrentSale
        case tranfarProcedureInfo
        case trasfarProcedureConformButton
    }
    
    fileprivate struct Section {
        var sectionType: TrasfarProcedureConformTableViewSectionType
        var rowItems: [TrasfarProcedureConformTableViewRowType]
    }
    
    // ================================================================================
    // MARK: setting
    
    override open func footerHeight() -> CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    override func initializeTableViewStruct() {
        sections = [Section(sectionType: .trasfarProcedureConform, rowItems: [.trasfarProcedureConformPriceTrasfard, .trasfarProcedureConformCurrentSale, .tranfarProcedureInfo, .trasfarProcedureConformButton])]
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "振込申請金額を入力"
    }
    
    // ================================================================================
    // MARK: init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init(bank: Bank) {
        super.init(nibName: nil, bundle: nil)
        tmpBank = bank
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView!.showsPullToRefresh = false
        self.automaticallyAdjustsScrollViewInsets = false
        tableView!.showsVerticalScrollIndicator = false
    }
    
    // ================================================================================
    // MARK: - ProfileSettingSaveButtonCellDelegate
    
    open func saveButtonCellSaveButtonTapped(_ cell: ProfileSettingSaveButtonCell) {
        if Utility.isEmpty(tmpBank) {
            return
        }
        
        if Me.sharedMe.point!.normalPoint! == 0 || Me.sharedMe.point!.normalPoint == nil {
            self.simpleAlert(nil, message: "申請できる金額がありません", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(amount) || amount == "¥" || amount == "¥0" {
            self.simpleAlert(nil, message: "申請金額を入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if amount.replaceYenSign().int() < ExternalServiceManager.minApplicableAmount {
            self.simpleAlert(nil, message: "申請できる金額は¥\(ExternalServiceManager.minApplicableAmount)からです", cancelTitle: "OK", completion: nil)
            return
        }

        if amount.replaceYenSign().int() > Me.sharedMe.point!.normalPoint! {
            self.simpleAlert(nil, message: "申請できる金額は¥\(Me.sharedMe.point!.normalPoint!.thousandsSeparator())までです", cancelTitle: "OK", completion: nil)
            return
        }
    
        if amount.replaceYenSign().int() > ExternalServiceManager.maxApplicableAmount {
            self.simpleAlert(nil, message: "一度に申請できる金額は¥\(ExternalServiceManager.maxApplicableAmount.thousandsSeparator())までです", cancelTitle: "OK", completion: nil)
            return
        }
        
        DBLog(tmpBank?.id)
        
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "¥\(amount.replaceYenSign().int().thousandsSeparator())申請しますか?",
            cancelButtonTitle: "キャンセル",
            destructiveButtonTitle: nil,
            otherButtonTitles: ["申請する"]) {[weak self] (al, index) in
                DispatchQueue.main.async {
                    if index == al.firstOtherButtonIndex {
                        self?.createWithdraw()
                    }
                }

        }
    }

    func createWithdraw() {
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        tmpBank?.createWithdraw(amount.replaceYenSign().int(), completion: {[weak self] (withdraw, error) in
            DispatchQueue.main.async {
                self?.view.isUserInteractionEnabled = true
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
                if error != nil {
                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                SVProgressHUD.dismiss()
                self?.simpleAlert(nil, message: "申請しました！", cancelTitle: "OK", completion: { [weak self] in
                    DispatchQueue.main.async {
                       _ = self?.navigationController?.popToRootViewController(animated: true)
                    }
                })
            }
        })
    }
    
    // ================================================================================
    // MARK: - textField delegate
    
    open func baseTextFieldDidBeginEditting(_ textField: UITextField) {}
    
    open func edittingText<T: SignedNumber>(_ string: String?, type:T?) {
        amount = string!
    }
    
    open func didSelectTextFieldShouldReturn() {}
    
    open func baseTextFieldReturnKeyTapped(_ textField: UITextField) {}
    
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
        case .tranfarProcedureInfo:
             return TransfarInfoCell.cellHeightForObject(nil)
        case .trasfarProcedureConformButton:
            return ProfileSettingSaveButtonCell.cellHeightForObject(nil)
        default:
            return 50.0
        }
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: UIView = UIView()
        sectionView.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonTableSectionHeight)
        sectionView.backgroundColor = UIColor.clear
        return sectionView
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kCommonTableSectionHeight
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
            case .trasfarProcedureConformPriceTrasfard:
            cellIdentifier = NSStringFromClass(TransfarTextFieldCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?TransfarTextFieldCell
            if cell == nil {
                cell = TransfarTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! TransfarTextFieldCell).titleText = "振込申請金額"
            (cell as! TransfarTextFieldCell).textField?.keyboardType = .numberPad
            (cell as! TransfarTextFieldCell).placeholderText = "未入力"
            (cell as! TransfarTextFieldCell).textField?.textAlignment = .right
            break
        case .trasfarProcedureConformCurrentSale:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "現在の売上"
            (cell as! BaseTextFieldCell).placeholderText = "なし"
            if Me.sharedMe.point?.normalPoint != nil {
                (cell as! BaseTextFieldCell).textFieldText = "¥\(Me.sharedMe.point!.normalPoint!.string())"
            }
            (cell as! BaseTextFieldCell).textField!.isUserInteractionEnabled = false
            (cell as! BaseTextFieldCell).textField?.textAlignment = .right

            break
        case .tranfarProcedureInfo:
            cellIdentifier = NSStringFromClass(TransfarInfoCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?TransfarInfoCell
            if cell == nil {
                cell = TransfarInfoCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            break
        case .trasfarProcedureConformButton:
            cellIdentifier = NSStringFromClass(ProfileSettingSaveButtonCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ProfileSettingSaveButtonCell
            if cell == nil {
                cell = ProfileSettingSaveButtonCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            
            (cell as! ProfileSettingSaveButtonCell).saveButton.setTitle("申請する", for: .normal)
           
            break
        }
        return cell!
    }
    
}
