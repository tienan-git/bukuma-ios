//
//  EmailLoginViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD

public enum EmailLoginViewControllerType: Int {
    case register
    case login
}

open class EmailLoginViewController: BaseTableViewController,
BaseTextFieldDelegate,
RegisterKeyBoardInputViewDelegate,
EmailLoginFooterViewDelegate {
    
    fileprivate var tmpUser: User = User()
    fileprivate var headerView: ProfileSettingViewHeaderView?
    var type: EmailLoginViewControllerType?
    var footerView: RegisterKeyBoardInputView?
    var emailFooterView: EmailLoginFooterView?
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate var sections = [Section]()
    
    fileprivate enum EmailLoginViewControllerSectionType: Int {
        case registerWithEmail
    }
    
    fileprivate enum EmailLoginViewControllerRowType {
        case nickName
        case gender
        case email
        case password
        case passwordConfirm
        case invitationCode
    }
    
    fileprivate struct Section {
        var sectionType: EmailLoginViewControllerSectionType
        var rowItems: [EmailLoginViewControllerRowType]
    }
    
    // ================================================================================
    // MARK: setting
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    override func initializeTableViewStruct() {
        if self.type == .register {
            self.sections = ExternalServiceManager.isOnBati ?
                [Section(sectionType: .registerWithEmail, rowItems: [.nickName, .email, .gender, .password, .passwordConfirm])] :
                [Section(sectionType: .registerWithEmail, rowItems: [.nickName, .email, .gender, .password, .passwordConfirm, .invitationCode])]
        } else {
            self.sections = [Section(sectionType: .registerWithEmail, rowItems: [.email, .password])]
        }
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = self.type == .register ? "会員登録" : "ログイン"
    }
    
    // ================================================================================
    // MARK: init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(type: EmailLoginViewControllerType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    deinit {
        DBLog("------------ deinit RegisterWithEmailViewController ----------------")
    }
    
    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        tableView!.showsPullToRefresh = false
        tableView?.isFixTableScrollWhenChangeContentsSize = true
        isNeedKeyboardNotification = true
        
        headerView = ProfileSettingViewHeaderView(delegate: self)
        headerView!.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 150)
        
        footerView = RegisterKeyBoardInputView(delegate: self)
        footerView!.text = self.type == .register ? "会員登録" : "このアカウントでログインする"
        footerView!.bottom = self.view.bottom
        self.view.addSubview(footerView!)
        
        emailFooterView = EmailLoginFooterView(delegate: self)
        tableView?.tableFooterView = self.type == .register ? nil : emailFooterView
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStruct), name: NSNotification.Name(rawValue: ServiceManagerIsOnBatiNotification), object: nil)

    }
    
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView!.tableHeaderView = self.type == .register ? headerView : nil
        
        headerView!.user = tmpUser
    }
    
    func updateStruct() {
        self.initializeTableViewStruct()
        self.tableView?.reloadData()
    }
    
    open func registerKeyBoardInputViewTapped(_ view: RegisterKeyBoardInputView) {
        if self.type == .register {
            self.registerAction()
            return
        }
        self.loginAction()
    }
    
    func registerAction() {
        if Utility.isEmpty(tmpUser.nickName) == true {
            self.simpleAlert(nil, message: "ニックネームが空です", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpUser.email?.currentEmail) == true  {
            self.simpleAlert(nil, message: "メールアドレスが空です", cancelTitle: "OK", completion: nil)
            return
        }
        
        if tmpUser.email?.currentEmail?.isValidEmail == false {
            self.simpleAlert(nil, message: "メールアドレスが正しくありません", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpUser.gender) == true  {
            tmpUser.gender = Gender.other.int()
        }
        
        if Utility.isEmpty(tmpUser.password?.currentPassword) == true  {
            self.simpleAlert(nil, message: "passwordが空です", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpUser.password?.confirmPassword) == true  {
            self.simpleAlert(nil, message: "パスワード確認を入力して下さい", cancelTitle: "OK", completion: nil)
            return
        }
        
        if tmpUser.password?.isConfirmedPassword() == false {
            self.simpleAlert(nil, message: "passwordが違います", cancelTitle: "OK", completion: nil)
            return
        }
        
        self.endEditting()
        self.view.isUserInteractionEnabled = false
        
        SVProgressHUD.show()
        if Me.sharedMe.isRegisterd == true && Utility.isEmpty(tmpUser.invitationCode) == false {
            Invite.updateInviter(tmpUser.invitationCode!, completion: {[weak self] (error) in
                DispatchQueue.main.async {
                    self?.view.isUserInteractionEnabled = true
                    if error != nil {
                        if error!.errorCodeType == .notFound {
                            self?.simpleAlert(nil, message: "招待コードが見つかりません。もう一度確認してお試しください。", cancelTitle: "OK", completion: nil)
                        } else {
                            self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                        }
                        return
                    }
                    SVProgressHUD.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                        self?.goRegisterPhoneViewController()
                    })
                }
                })
            return
        }
        
        if Me.sharedMe.isRegisterd == true {
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                self.goRegisterPhoneViewController()
            })
            return
        }
        
        SVProgressHUD.show()
        Me.sharedMe.registerTimeStamp { [weak self](timeStamp, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.view.isUserInteractionEnabled = true
                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                Me.sharedMe.registerUser( self!.tmpUser, timeStamp:timeStamp, completion: { (error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            self?.view.isUserInteractionEnabled = true
                            self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                            return
                        }
                        
                        if Utility.isEmpty(self!.tmpUser.invitationCode) == false  {
                            Invite.updateInviter(self!.tmpUser.invitationCode!, completion: { (error) in
                                DispatchQueue.main.async {
                                    self?.view.isUserInteractionEnabled = true
                                    if error != nil {
                                        if error!.errorCodeType == .notFound {
                                            self?.simpleAlert(nil, message: "招待コードが見つかりません。もう一度確認してお試しください。", cancelTitle: "OK", completion: nil)
                                        } else {
                                            self?.simpleAlert(nil, message: error!.errorDespription, cancelTitle: "OK", completion: nil)
                                        }
                                        return
                                    }
                                    SVProgressHUD.dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                                        self?.goRegisterPhoneViewController()
                                    })
                                }
                            })
                        } else {
                            SVProgressHUD.dismiss()
                            self?.view.isUserInteractionEnabled = true
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                                self?.goRegisterPhoneViewController()
                            })
                        }
                    }
                })
            }
        }
    }
    
    func loginAction() {
        
        if Utility.isEmpty(tmpUser.email?.currentEmail) == true  {
            self.simpleAlert(nil, message: "メールアドレスが空です", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpUser.password?.currentPassword) == true  {
            self.simpleAlert(nil, message: "passwordが空です", cancelTitle: "OK", completion: nil)
            return
        }

        self.endEditting()
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        
        Me.sharedMe.registerTimeStamp {[weak self] (timeStamp, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.view.isUserInteractionEnabled = true
                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                Me.sharedMe.singInWithEmailAccount(timeStamp!, user: self!.tmpUser, completion: { (error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            self?.view.isUserInteractionEnabled = true
                            self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                            return
                        }
                        self?.view.isUserInteractionEnabled = true
                        SVProgressHUD.dismiss()
                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: AppDelegateRefreshAfterLoginKey), object: nil)

                        self?.simpleAlert(nil, message: "ログイン成功しました！", cancelTitle: "OK", completion: {
                            DispatchQueue.main.async {
                                self?.dismiss(animated: true, completion: nil)
                                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MeFirstRegisterkey), object: nil)
                            }
                        })
                    }
                })
            }
        }
    }
    
    open func emailLoginFooterViewForgetPassTapped(_ view: EmailLoginFooterView) {
        let controller: EmailPasswordSettingViewController = EmailPasswordSettingViewController(type: .resetPass)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func goRegisterPhoneViewController() {
        let controller: RegisterPhoneNumberViewController = RegisterPhoneNumberViewController(type: .input)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override open func keyboardDidShow(_ notification: Foundation.Notification) {
        super.keyboardDidShow(notification)
        let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration: Float = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        let animationCurve: UInt = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue
        
        UIView.animate(withDuration:TimeInterval(duration),
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.init(rawValue: animationCurve),
                                   animations: {
                                    self.footerView!.y = self.view.height -  (keyboardFrame.size.height + self.footerView!.height)
            }, completion: nil)
    }
    
    override open func keyboardDidHide(_ notification: Foundation.Notification) {
        super.keyboardDidHide(notification)
        let duration: Float = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        let animationCurve: UInt = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue
        
        UIView.animate(withDuration:TimeInterval(duration),
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.init(rawValue: animationCurve),
                                   animations: {
                                    self.footerView!.bottom = self.view.bottom
            }, completion: nil)
    }
    
    func endEditting() {
        self.view.endEditing(true)
    }
    
    // ================================================================================
    // MARK: RegisterTextCell delegate
    
    open func baseTextFieldDidBeginEditting(_ textField: UITextField) {
        var indexPath: IndexPath?
        
        if textField.tag == 3 {
            indexPath = IndexPath(row: 2, section: 0)
        }
        
        if textField.tag == 4 {
            indexPath = IndexPath(row: 3, section: 0)
        }
        
        if textField.tag == 5 {
            indexPath = IndexPath(row: 4, section: 0)
        }
        
        if indexPath != nil && self.type == .register {
            let rectOfCellInSuperview: CGRect = tableView!.convert(tableView!.bounds, to: tableView!.cellForRow(at: indexPath!))
            self.moveContentOffsetWithTargetCellRect(rectOfCellInSuperview, index: 1)
        }
    }
    
    open func edittingText<T : SignedNumber>(_ string: String?, type: T?) {
        switch type {
        case .some(0):
            tmpUser.nickName = string
            break
        case .some(1):
            tmpUser.email?.currentEmail = string
            break
        case .some(3):
            tmpUser.password?.currentPassword = string
            break
        case .some(4):
            tmpUser.password?.confirmPassword = string
            break
        case .some(5):
            tmpUser.invitationCode = string
            break
        default:
            break
        }
    }
    
    open func didSelectTextFieldShouldReturn() {}
    
    open func baseTextFieldReturnKeyTapped(_ textField: UITextField) {
        let nextKeyBoradCellTag: Int = self.type == .register ? textField.tag + 1 : textField.tag
        let nextKeyBoradCellIndexPass = IndexPath(item: nextKeyBoradCellTag, section: 0)
        let targetCell: BaseTextFieldCell? = tableView?.cellForRow(at: nextKeyBoradCellIndexPass) as? BaseTextFieldCell
        targetCell?.textField?.becomeFirstResponder()
        return
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return  sections.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowItems.count
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BaseTextFieldCell.cellHeightForObject(nil)
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTextFieldCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .nickName:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "EmailLoginViewController" + "NickName"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            cell?.titleText = "ニックネーム"
            cell?.textFieldMaxLength = 25
            cell?.placeholderText = "未入力"
            cell?.textFieldType = 0
            cell?.textField?.returnKeyType = .next
            cell?.textField?.textAlignment = .right
            break
        case .gender:
            cellIdentifier = NSStringFromClass(BaseTextFieldPickerCell.self) + "EmailLoginViewController" + "Gender"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldPickerCell
            if cell == nil {
                cell = BaseTextFieldPickerCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldPickerCell).selectionStyle = .none
            (cell as! BaseTextFieldPickerCell).titleText = "性別"
            (cell as! BaseTextFieldPickerCell).placeholderText = Gender.placeholderString
            (cell as! BaseTextFieldPickerCell).textFieldType = 2
            (cell as! BaseTextFieldPickerCell).pickerContents = Gender.strings
            (cell as! BaseTextFieldPickerCell).textField?.returnKeyType = .next
            (cell as! BaseTextFieldPickerCell).keyboardToolbarButtonText = "次へ"
            (cell as! BaseTextFieldPickerCell).textField?.textAlignment = .right
            break
        case .email:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "EmailLoginViewController" + "Email"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }

            cell?.titleText = "メールアドレス"
            cell?.placeholderText = "未入力"
            cell?.textFieldType = 1
            cell?.textFieldMaxLength = 50
            cell?.textField?.keyboardType = .asciiCapable
            cell?.textField?.returnKeyType = .next

            cell?.textField?.textAlignment = .right
            break
        case .password:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "EmailLoginViewController" + "Password"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }

            cell?.titleText = "パスワード"
            cell?.placeholderText = "未入力"
            cell?.textFieldType = 3
            cell?.textFieldMaxLength = 25
            cell?.textField!.keyboardType = .asciiCapable
            cell?.textField?.isSecureTextEntry = true
            cell?.textField?.returnKeyType = .next
            cell?.textField?.textAlignment = .right

            break
        case .passwordConfirm:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "EmailLoginViewController" + "PasswordConfirm"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell(reuseIdentifier: cellIdentifier, delegate: self)
            }

            cell?.titleText = "パスワード確認"
            cell?.placeholderText = "未入力"
            cell?.textFieldType = 4
            cell?.textFieldMaxLength = 25
            cell?.textField!.keyboardType = .asciiCapable
            cell?.textField?.isSecureTextEntry = true
            cell?.textField?.returnKeyType = .next
            cell?.textField?.textAlignment = .right
            break
        case .invitationCode:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "EmailLoginViewController" + "InvitationCode"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            cell?.titleText = "招待コード"
            cell?.placeholderText = "未入力(任意)"
            cell?.textFieldType = 5
            cell?.textFieldMaxLength = 25
            cell?.textField!.keyboardType = .asciiCapable
            cell?.textField!.returnKeyType = .done
            cell?.textField?.textAlignment = .right
            break
        }
        
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let cell: BaseTextFieldCell? = tableView.cellForRow(at: indexPath) as? BaseTextFieldCell
        cell?.becomeFirstResponder()
    }

    override  open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let img: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        tmpUser.photo = Photo(image: img)
        headerView?.user = tmpUser
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EmailLoginViewController: ProfileSettingViewHeaderViewDelegate {
    public func headerViewIconButtonTapped(_ view: ProfileSettingViewHeaderView) {
        self.showPhotoActionSheet()
    }
}

extension EmailLoginViewController: BaseTextFieldPickerCellDelegate {
    public func baseTextFieldPickerCellFinishEditPicker(_ text: String, cell: BaseTextFieldPickerCell) {
        let nextKeyBoradCellTag: Int = self.type == .register ? cell.textField!.tag + 1 : cell.textField!.tag
        let nextKeyBoradCellIndexPass = IndexPath(item: nextKeyBoradCellTag, section: 0)
        let targetCell: BaseTextFieldCell? = tableView?.cellForRow(at: nextKeyBoradCellIndexPass) as? BaseTextFieldCell
        targetCell?.textField?.becomeFirstResponder()
    }
    
    public func baseTextFieldPickerCellEditingPicker(_ row: Int, cell: BaseTextFieldPickerCell) {
        tmpUser.gender = tmpUser.gender(fromRow: row)
    }
}
