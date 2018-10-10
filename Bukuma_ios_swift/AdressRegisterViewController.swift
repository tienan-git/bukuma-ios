//
//  AdressRegisterViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

public let AdressRegisterViewControllerShouldRefreshKey = "AdressRegisterViewControllerShouldRefreshKey"

@objc public protocol AdressRegisterViewControllerDelegate: NSObjectProtocol {
     func adressRegisterViewControllerDidFinishRegister(_ controller: AdressRegisterViewController, completion: (() ->Void)?)
}

open class AdressRegisterViewController: BaseTableViewController,
BaseTextFieldDelegate,
BaseTextFieldPickerCellDelegate {
    
    fileprivate var sections = [Section]()
    fileprivate var tmpAdress: Adress?
    weak var delegate: AdressRegisterViewControllerDelegate?
    
    fileprivate var postalInfo: PostalInfo? {
        didSet {
            if postalInfo != nil {
                let indexPassPre: IndexPath = IndexPath(row: 2, section: 1)
                let indexPassCity: IndexPath = IndexPath(row: 3, section: 1)
                let indexPassHouseNumber: IndexPath = IndexPath(row: 4, section: 1)

                let cellPre: UITableViewCell?  = tableView?.cellForRow(at: indexPassPre)
                let cellCity: UITableViewCell?  = tableView?.cellForRow(at: indexPassCity)
                let cellHouse: UITableViewCell?  = tableView?.cellForRow(at: indexPassHouseNumber)
                
                (cellPre as? BaseTextFieldCell)?.textFieldText = self.postalInfo?.prefecture.map{$0}
                (cellCity as? BaseTextFieldCell)?.textFieldText = self.postalInfo?.city.map{$0}
                (cellHouse as? BaseTextFieldCell)?.textFieldText = self.postalInfo?.area.map{$0}
                tmpAdress?.prefecture = postalInfo?.adress?.prefecture
                tmpAdress?.city = postalInfo?.adress?.city
                tmpAdress?.houseNumberAdressLine = postalInfo?.adress?.houseNumberAdressLine
            }
        }
    }
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate enum AdressRegisterTableViewSectionType: Int {
        case userName
        case userAdress
        case userPhoneNumber
    }
    
    fileprivate enum AdressRegisterTableViewRowType: Int {
        case userNameTitle
        case userNameFirstName
        case userNameLastName
        case userNameFirstPhonetic
        case userNameLastPhonetic
        case userAdressTitle
        case userAdressPostalNumber
        case userAdressPrefecture
        case userAdressCity
        case userAdressHouseNumber
        case userAdressHouseName
        case userPhoneNumberTitle
        case userPhoneNumberDetail
    }
    
    fileprivate struct Section {
        var sectionType: AdressRegisterTableViewSectionType
        var rowItems: [AdressRegisterTableViewRowType]
    }
    
    // ================================================================================
    // MARK: setting
    
    func isAdressEmpty() -> Bool {
        return Utility.isEmpty(tmpAdress!.id)
    }
    
    override var shouldShowRightNavigationButton: Bool {
        get {
            return true
        }
    }
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }
    
    override open func scrollIndicatorInsetBottom() ->CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    override func initializeTableViewStruct() {
        sections = [Section(sectionType: .userName, rowItems: [.userNameTitle, .userNameFirstName, .userNameLastName, .userNameFirstPhonetic, .userNameLastPhonetic]),
        Section(sectionType: .userAdress, rowItems: [.userAdressTitle, .userAdressPostalNumber, .userAdressPrefecture, .userAdressCity, .userAdressHouseNumber, .userAdressHouseName]),
        Section(sectionType: .userPhoneNumber, rowItems: [.userPhoneNumberTitle, .userPhoneNumberDetail])]
    }
    
    override open func initializeNavigationLayout() {
        let rightButton = BarButtonItem.barButtonItemWithText("完了",
                                                              isBold: true,
                                                              isLeft: false,
                                                              target: self,
                                                              action: #selector(self.rightButtonTapped(_:)))
        self.setNavigationBarButton(rightButton, isLeft: false)
        self.navigationBarTitle = "お届け先情報"
    }
    
    // ================================================================================
    // MARK: init
    
    required public init(adress:  Adress?) {
        super.init(nibName: nil, bundle: nil)
        if adress != nil {
            tmpAdress = adress
        } else {
            tmpAdress = Adress()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        isNeedKeyboardNotification = true
        tableView!.showsPullToRefresh = false
        self.automaticallyAdjustsScrollViewInsets = false
        tableView!.showsVerticalScrollIndicator = false
        tableView!.isFixTableScrollWhenChangeContentsSize = true
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())
    }
    
    func rightButtonTapped(_ sender: BarButtonItem) {
        
        if Utility.isEmpty(tmpAdress?.personFirstName) {
            self.simpleAlert(nil, message: "姓を設定してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpAdress?.personLastName) {
            self.simpleAlert(nil, message: "名を設定してください", cancelTitle: "OK", completion: nil)
            return
        }

        if Utility.isEmpty(tmpAdress?.personFirstKana) {
            self.simpleAlert(nil, message: "セイを設定してください", cancelTitle: "OK", completion: nil)
            return
        }

        if tmpAdress!.personFirstKana?.isKatakana() == false {
            self.simpleAlert(nil, message: "セイはカタカナで設定してください", cancelTitle: "OK", completion: nil)
            return
        }

        if Utility.isEmpty(tmpAdress?.personLastKana) {
            self.simpleAlert(nil, message: "メイを設定してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if tmpAdress?.personLastKana?.isKatakana() == false {
            self.simpleAlert(nil, message: "メイはカタカナで設定してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpAdress?.postalCode) {
            self.simpleAlert(nil, message: "郵便番号を設定してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if tmpAdress?.postalCode?.length != 7 {
            self.simpleAlert(nil, message: "郵便番号は7桁にしてください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpAdress?.prefecture) {
            self.simpleAlert(nil, message: "都道府県を設定してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpAdress?.city) {
            self.simpleAlert(nil, message: "市町村区を設定してください", cancelTitle: "OK", completion: nil)
            return
        }

        if Utility.isEmpty(tmpAdress?.houseNumberAdressLine) {
            self.simpleAlert(nil, message: "番地を設定してください", cancelTitle: "OK", completion: nil)
            return
        }

        tmpAdress!.isDefaultAdress = true
        
        if Adress.isSameAdressInfo(tmpAdress!) == true {
            RMUniversalAlert.show(in: self,
                                  withTitle: nil,
                                  message: "すでに同じ情報の住所を登録しています。登録しますか?", cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: ["登録する"]) { [weak self] (al, index) in
                                    DispatchQueue.main.async {
                                        if index == al.firstOtherButtonIndex {
                                            if Utility.isEmpty(self!.tmpAdress!.id) == true {
                                                self?.registerAdress(self!.tmpAdress!)
                                            } else {
                                                self?.editAdress(self!.tmpAdress!)
                                            }
                                        }
                                    }
            }
            return
        }

        if Utility.isEmpty(tmpAdress!.id) == true {
            self.registerAdress(tmpAdress!)
        } else {
            self.editAdress(tmpAdress!)
        }
    }
    
    func registerAdress(_ adress: Adress) {
        SVProgressHUD.show()

        Adress.registerAdress(adress) { [weak self] (error) in
            DispatchQueue.main.async {
                if (error != nil) {
                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: AdressRegisterViewControllerShouldRefreshKey), object: nil)
                
                SVProgressHUD.dismiss()
                
                if Me.sharedMe.defaultCards == nil {
                    for controller in (self?.navigationController?.viewControllers)! {
                        if controller is CreditCardRegisterViewController {
                            self?.simpleAlert(nil, message: "住所を登録しました！", cancelTitle: "OK") { () in
                                DispatchQueue.main.async {
                                    _ = self?.navigationController?.popToViewController(controller, animated: true)
                                }
                            }
                            return
                        }
                    }
                    
                    if Me.sharedMe.point?.usablePoint == "0" {
                        self?.showRegisterCardAlert()
                        return
                    }
                    
                    for controller in (self?.navigationController?.viewControllers)! {
                        if controller is PurchaseViewController {
                            self?.simpleAlert(nil, message: "住所を登録しました！", cancelTitle: "OK") { () in
                                DispatchQueue.main.async {
                                    _ = self?.navigationController?.popToViewController(controller, animated: true)
                                }
                            }
                            return
                        }
                        
                        if controller is CreditCardRegisterViewController {
                            self?.simpleAlert(nil, message: "住所を登録しました！", cancelTitle: "OK") { () in
                                DispatchQueue.main.async {
                                    _ = self?.navigationController?.popToViewController(controller, animated: true)
                                }
                            }
                            return
                        }

                        self?.simpleAlert(nil, message: "住所を登録しました！", cancelTitle: "OK") { () in
                            DispatchQueue.main.async {
                                self?.popViewController()
                            }
                        }
                        return
                    }
                    
                    return
                }
                
                self?.simpleAlert(nil, message: "住所を登録しました！", cancelTitle: "OK") { () in
                    DispatchQueue.main.async {
                        self?.navigationController.map({ (navigationController)  in
                            for controller in navigationController.viewControllers {
                                if controller is PurchaseViewController {
                                    navigationController.popToViewController(controller, animated: true)
                                    return
                                }
                                if controller is CreditCardRegisterViewController {
                                    navigationController.popToViewController(controller, animated: true)
                                    return
                                }
                            }
                            navigationController.popViewController(animated: true)
                        })
                    }
                }
            }
        }
    }
    
    func editAdress(_ adress: Adress) {
        SVProgressHUD.show()

        Adress.editAdress(adress) { [weak self] (error) in
            DispatchQueue.main.async {
                if (error != nil) {
                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: AdressRegisterViewControllerShouldRefreshKey), object: nil)

                if Me.sharedMe.defaultCards == nil {
                    self?.showRegisterCardAlert()
                    return
                }

                SVProgressHUD.dismiss()

                RMUniversalAlert.show(in: self!,
                                      withTitle: nil,
                                      message: "住所を登録しました！",
                                      cancelButtonTitle: "OK",
                                      destructiveButtonTitle: nil,
                                      otherButtonTitles: nil) { (al, buttonIndex) in
                                        DispatchQueue.main.async {
                                            self?.popViewController()
                                        }
                }
            }
        }
    }
    
    func showRegisterCardAlert() {
        RMUniversalAlert.show(in: self,
                              withTitle: "住所を保存しました",
                              message: "クレジットカード情報も登録しますか?本を購入するためにはクレジットカードの登録が必要です",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["登録する"]) {[weak self] (al, index) in
                                DispatchQueue.main.async {
                                    if index == al.cancelButtonIndex {
                                        for controller in self!.navigationController!.viewControllers {
                                            if controller is PurchaseViewController {
                                                _ =    self?.navigationController?.popToViewController(controller, animated: true)
                                                return
                                            }
                                        }
                                        self?.popViewController()
                                    }
                                    if index != al.cancelButtonIndex {
                                        let controller: CreditCardRegisterViewController = CreditCardRegisterViewController(card: nil)
                                        controller.view.clipsToBounds = true
                                        self?.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
        }
    }

    // ================================================================================
    // MARK: -  baseText delegate

    open func baseTextFieldDidBeginEditting(_ textField: UITextField) {
        switch textField.tag {
        case 5:
            if tmpAdress?.prefecture == nil {
                let indexPass: IndexPath = IndexPath(row: 2, section: 1)
                let cell: BaseTextFieldPickerCell? = tableView?.cellForRow(at: indexPass) as? BaseTextFieldPickerCell
                cell?.textFieldText = cell?.pickerContents?[0]
                tmpAdress?.prefecture = textField.text
            }
            break
        default:
            break
        }
    }
    
    open func edittingText<T : SignedNumber>(_ string: String?, type: T?) {
        
        switch type {
        case .some(0):
            tmpAdress!.personFirstName = string
            break
        case .some(1):
            tmpAdress!.personLastName = string
            break
        case .some(2):
            tmpAdress!.personFirstKana = string
            break
        case .some(3):
            tmpAdress!.personLastKana = string
            break
        case .some(4):
            if string?.characters.count == 7 {
                Adress.searchAdressFromPostalCode(string, completion: {[weak self] (postalInfo, error) in
                    if error == nil {
                        self?.postalInfo = postalInfo
                    }
                })
            }
            tmpAdress!.postalCode = string
            break
        case .some(5):
            tmpAdress!.prefecture = string
            break
        case .some(6):
            tmpAdress!.city = string
            break
        case .some(7):
            tmpAdress!.houseNumberAdressLine = string
            break
        case .some(8):
            tmpAdress!.buildingNameAdressLine = string
            break
        case .some(9):
            tmpAdress!.personPhone?.currentPhoneNumber = string
        default:
            break
            
        }
    }
    
    open func didSelectTextFieldShouldReturn() {}
    
    open func baseTextFieldReturnKeyTapped(_ textField: UITextField) {
        self.startEditNextTextField(textField.tag)
    }

    open func baseTextFieldPickerCellEditingPicker(_ row: Int, cell: BaseTextFieldPickerCell) {
        tmpAdress?.prefecture = Adress.prefectures[row]
        DBLog(tmpAdress?.prefecture)
        
    }
    
    open func baseTextFieldPickerCellFinishEditPicker(_ text: String, cell: BaseTextFieldPickerCell) {
        self.startEditNextTextField(cell.textField!.tag)
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
        case .userNameTitle, .userAdressTitle, .userPhoneNumberTitle:
            return BaseTitleCell.cellHeightForObject(nil)
        default:
            return 50.0
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .userNameTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "お名前"

            break
        case .userNameFirstName:
            cellIdentifier = "UserNameFirstName" + NSStringFromClass(BaseTextFieldCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "姓 (全角)"
            (cell as! BaseTextFieldCell).textFieldText = tmpAdress?.personFirstName.map{$0}
            (cell as! BaseTextFieldCell).placeholderText = "(例)山本"
            (cell as! BaseTextFieldCell).textFieldType = .some(0)
            (cell as! BaseTextFieldCell).isShortBottomLine = true
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
            (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            
            break
        case .userNameLastName:
            cellIdentifier = "UserNameLastName" + NSStringFromClass(BaseTextFieldCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "名 (全角)"
            (cell as! BaseTextFieldCell).textFieldText = tmpAdress?.personLastName.map{$0}
            (cell as! BaseTextFieldCell).placeholderText = "(例)三郎"
            (cell as! BaseTextFieldCell).textFieldType = 1
            (cell as! BaseTextFieldCell).isShortBottomLine = true
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
             (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
        case .userNameFirstPhonetic:
            cellIdentifier = "UserNameFirstPhonetic" + NSStringFromClass(BaseTextFieldCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "姓 (カナ)"
            (cell as! BaseTextFieldCell).textFieldText = tmpAdress?.personFirstKana.map{$0}
            (cell as! BaseTextFieldCell).placeholderText = "(例)ヤマモト"
            (cell as! BaseTextFieldCell).textFieldType = 2
            (cell as! BaseTextFieldCell).isShortBottomLine = true
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
             (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
        case .userNameLastPhonetic:
            cellIdentifier = "UserNameLastPhonetic" +  NSStringFromClass(BaseTextFieldCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "名 (カナ)"
            (cell as! BaseTextFieldCell).textFieldText = tmpAdress?.personLastKana.map{$0}
            (cell as! BaseTextFieldCell).placeholderText = "(例)サブロウ"
            (cell as! BaseTextFieldCell).textFieldType = 3
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
             (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
        case .userAdressTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "お住まい"
            break
        case .userAdressPostalNumber:
            cellIdentifier = "UserAdressPostalNumber" + NSStringFromClass(BaseTextFieldCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "郵便番号"
            (cell as! BaseTextFieldCell).textFieldText = tmpAdress?.postalCode.map{$0}
            (cell as! BaseTextFieldCell).placeholderText = "(例)0000000"
            (cell as! BaseTextFieldCell).textFieldType = 4
            (cell as! BaseTextFieldCell).textField!.keyboardType = .numberPad
            (cell as! BaseTextFieldCell).isShortBottomLine = true
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textFieldMaxLength = 7
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
            (cell as! BaseTextFieldCell).keyboardToolbarButtonText = "次へ"
             (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
        case .userAdressPrefecture:
            cellIdentifier = "UserAdressPrefecture" + NSStringFromClass(BaseTextFieldPickerCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldPickerCell
            if cell == nil {
                cell = BaseTextFieldPickerCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            
            (cell as! BaseTextFieldPickerCell).pickerContents = Adress.prefectures
            (cell as! BaseTextFieldPickerCell).titleText = "都道府県"
            (cell as! BaseTextFieldPickerCell).placeholderText = "(例)東京都"
            (cell as! BaseTextFieldPickerCell).textFieldType = 5
            (cell as! BaseTextFieldPickerCell).isShortBottomLine = true
            (cell as! BaseTextFieldPickerCell).selectionStyle = .none
            (cell as! BaseTextFieldPickerCell).textField?.returnKeyType = .next
            (cell as! BaseTextFieldPickerCell).keyboardToolbarButtonText = "次へ"
             (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            
            break
        case .userAdressCity:
            cellIdentifier = "UserAdressCity" + NSStringFromClass(BaseTextFieldCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "市町村区"
            (cell as! BaseTextFieldCell).textFieldText = tmpAdress?.city.map{$0}
            (cell as! BaseTextFieldCell).placeholderText = "(例)渋谷区"
            (cell as! BaseTextFieldCell).textFieldType = 6
            (cell as! BaseTextFieldCell).isShortBottomLine = true
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
             (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
        case .userAdressHouseNumber:
            cellIdentifier = "UserAdressHouseNumber" + NSStringFromClass(BaseTextFieldCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "番地"
            (cell as! BaseTextFieldCell).placeholderText = "(例)渋谷99-99"
            (cell as! BaseTextFieldCell).textFieldText =  tmpAdress?.houseNumberAdressLine.map{$0}
            (cell as! BaseTextFieldCell).textFieldType = 7
            (cell as! BaseTextFieldCell).isShortBottomLine = true
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
             (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
        case .userAdressHouseName:
            cellIdentifier = "UserAdressHouseName" +  NSStringFromClass(BaseTextFieldCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "建物名"
            (cell as! BaseTextFieldCell).placeholderText = "(例)青山ビル 102(任意)"
            (cell as! BaseTextFieldCell).textFieldText = tmpAdress?.buildingNameAdressLine.map{$0}
            (cell as! BaseTextFieldCell).textFieldType = 8
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .next
             (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break

        case .userPhoneNumberTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "連絡先"
            break
        case .userPhoneNumberDetail:
            cellIdentifier = "UserPhoneNumberDetail" + NSStringFromClass(BaseTextFieldCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "電話番号"
            (cell as! BaseTextFieldCell).textFieldText = tmpAdress?.personPhone?.currentPhoneNumber.map{$0}
            (cell as! BaseTextFieldCell).placeholderText = "(例)09012345678(任意)"
            (cell as! BaseTextFieldCell).textField!.keyboardType = .numberPad
            (cell as! BaseTextFieldCell).textFieldType = 9
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textField?.returnKeyType = .done
             (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
        }
        return cell!
    }
}
