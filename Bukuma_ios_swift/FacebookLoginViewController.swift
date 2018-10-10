//
//  FacebookLoginViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

open class FacebookLoginViewController: BaseTableViewController,
BaseTextFieldDelegate,
ProfileSettingViewHeaderViewDelegate,
RegisterKeyBoardInputViewDelegate {
    
    fileprivate var tmpUser: User?
    fileprivate var headerView: ProfileSettingViewHeaderView?
    var footerView: RegisterKeyBoardInputView?
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate var sections = [Section]()
    
    fileprivate enum FacebookLoginViewControllerSectionType: Int {
        case registerFacebookUserInfo
    }
    
    fileprivate enum FacebookLoginViewControllerRowType {
        case nickName
        case email
        case gender
        case password
        case passwordConfirm
        case invitationCode
    }
    
    fileprivate struct Section {
        var sectionType: FacebookLoginViewControllerSectionType
        var rowItems: [FacebookLoginViewControllerRowType]
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
        self.sections = ExternalServiceManager.isOnBati ?
            [Section(sectionType: .registerFacebookUserInfo, rowItems: [.nickName, .email, .gender,  .password, .passwordConfirm])] :
            [Section(sectionType: .registerFacebookUserInfo, rowItems: [.nickName, .email, .gender, .password, .passwordConfirm, .invitationCode])]
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "プロフィール登録"
    }
    
    // ================================================================================
    // MARK: init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.tmpUser = user
    }
    
    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        tableView!.showsPullToRefresh = false
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())
        
        headerView = ProfileSettingViewHeaderView(delegate: self)
        headerView!.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 150)
        
        footerView = RegisterKeyBoardInputView(delegate: self)
        footerView!.text = "会員登録"
        footerView!.bottom = self.view.bottom
        self.view.addSubview(footerView!)
        
        tableView?.isFixTableScrollWhenChangeContentsSize = true
        isNeedKeyboardNotification = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStruct), name: NSNotification.Name(rawValue: ServiceManagerIsOnBatiNotification), object: nil)

    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView!.tableHeaderView = headerView
        
        headerView!.user = tmpUser!
    }
    
    func updateStruct() {
        self.initializeTableViewStruct()
        self.tableView?.reloadData()
    }
    
    // ================================================================================
    // MARK: action
    
    func registerAction()  {
        if Utility.isEmpty(tmpUser?.facebook?.nickname) == true {
            self.simpleAlert(nil, message: "ニックネームが空です", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpUser?.facebook?.email) == true  {
            self.simpleAlert(nil, message: "メールアドレスが空です", cancelTitle: "OK", completion: nil)
            return
        }
        
        if tmpUser?.facebook?.email?.isValidEmail == false {
            self.simpleAlert(nil, message: "メールアドレスが正しくありません", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpUser?.gender) == true  {
            tmpUser?.gender = Gender.other.int()
        }

        if Utility.isEmpty(tmpUser?.password?.currentPassword) == true  {
            self.simpleAlert(nil, message: "パスワードが空です", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpUser?.password?.confirmPassword) == true  {
            self.simpleAlert(nil, message: "パスワード(確認)が空です", cancelTitle: "OK", completion: nil)
            return
        }
        
        if tmpUser?.password?.isConfirmedPassword() == false {
            self.simpleAlert(nil, message: "パスワードとパスワード(確認)が違います", cancelTitle: "OK", completion: nil)
            return
        }
        
        self.endEditting()
        
        if Me.sharedMe.isRegisterd == true && Utility.isEmpty(tmpUser!.invitationCode) == false {
            Invite.updateInviter(tmpUser!.invitationCode!, completion: {[weak self] (error) in
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
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute:  {
                        self?.goRegisterPhoneViewController()
                    })
                }
                })
            return
        }
        
        if Me.sharedMe.isRegisterd == true {
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute:  {
                self.goRegisterPhoneViewController()
            })
            return
        }

        SVProgressHUD.show()
        
        self.view.isUserInteractionEnabled = false
        Me.sharedMe.registerTimeStamp { [weak self](timeStamp, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.view.isUserInteractionEnabled = true
                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                Me.sharedMe.registerUserWithFacebook(self!.tmpUser!, facebook: self!.tmpUser!.facebook!, timeStamp: timeStamp, completion: { (error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            self?.view.isUserInteractionEnabled = true
                            self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                            return
                        }
                        
                        if Utility.isEmpty(self?.tmpUser?.invitationCode) == false  {
                            Invite.updateInviter(self!.tmpUser!.invitationCode!, completion: { (error) in
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
                                }
                                SVProgressHUD.dismiss()
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute:  {
                                    self?.goRegisterPhoneViewController()
                                })
                            })
                        } else {
                            self?.view.isUserInteractionEnabled = true
                            SVProgressHUD.dismiss()
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute:  {
                                self?.goRegisterPhoneViewController()
                            })
                        }
                    }
                })
            }
        }
    }
    
    func showSucsessAlert() {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "登録しました",
                              cancelButtonTitle: "OK",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: nil) {[weak self] (al, index) in
                                DispatchQueue.main.async {
                                    self?.popViewController()
                                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MeFirstRegisterkey), object: nil)

                                }
        }
    }

    func goRegisterPhoneViewController() {
        let controller: RegisterPhoneNumberViewController = RegisterPhoneNumberViewController(type: .input)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func endEditting() {
        self.view.endEditing(true)
    }
    
    open func headerViewIconButtonTapped(_ view: ProfileSettingViewHeaderView) {
        self.showPhotoActionSheet()
    }
    
    open func registerKeyBoardInputViewTapped(_ view: RegisterKeyBoardInputView) {
        self.registerAction()
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

       // ================================================================================
    // MARK: - image picker delegate
    
   
   override  open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let img: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        tmpUser?.photo = Photo(image: img)
        headerView?.user = tmpUser
        picker.dismiss(animated: true, completion: nil)
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
        
        if indexPath != nil {
            let rectOfCellInSuperview: CGRect = tableView!.convert(tableView!.bounds, to: tableView!.cellForRow(at: indexPath!))
            self.moveContentOffsetWithTargetCellRect(rectOfCellInSuperview, index: 1)
        }
    }
    
    open func edittingText<T : SignedNumber>(_ string: String?, type: T?) {
        switch type {
        case .some(0):
            tmpUser?.facebook?.nickname = string
            break
        case .some(1):
            tmpUser?.facebook?.email = string
            break
        case .some(3):
            tmpUser?.password?.currentPassword = string
            break
        case .some(4):
            tmpUser?.password?.confirmPassword = string
            break
        case .some(5):
            tmpUser?.invitationCode = string
            break
        default:
            break
        }
    }
    
    open func didSelectTextFieldShouldReturn() {}
    
    open func baseTextFieldReturnKeyTapped(_ textField: UITextField) {
        let nextKeyBoradCellTag: Int = textField.tag + 1
        let nextKeyBoradCellIndexPass = IndexPath(item: nextKeyBoradCellTag, section: 0)
        let targetCell: BaseTextFieldCell? = tableView?.cellForRow(at: nextKeyBoradCellIndexPass) as? BaseTextFieldCell
        targetCell?.textField?.becomeFirstResponder()
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
        return BaseTextFieldCell.cellHeightForObject(nil)
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTextFieldCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .nickName:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "FacebookLoginViewController" + "NickName"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            
            cell?.titleText = "ニックネーム"
            cell?.textFieldText = tmpUser?.facebook?.nickname
            cell?.placeholderText = "未設定"
            cell?.textFieldType = 0
            cell?.textField!.returnKeyType = .next
            cell?.textField?.textAlignment = .right
            break
        case .email:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "FacebookLoginViewController" + "Email"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            cell?.titleText = "メールアドレス"
            cell?.textFieldText = tmpUser?.facebook?.email
            cell?.placeholderText = "未設定"
            cell?.textFieldType = 1
            cell?.textFieldMaxLength = 50
            cell?.textField?.keyboardType = .asciiCapable
            cell?.textField!.returnKeyType = .next
            cell?.textField?.textAlignment = .right

            break
        case .gender:
            cellIdentifier = NSStringFromClass(BaseTextFieldPickerCell.self) + "FacebookLoginViewController" + "Gender"
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
        case .password:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "FacebookLoginViewController" + "Password"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            cell?.titleText = "パスワード"
            cell?.placeholderText = "未設定"
            cell?.textFieldType = 3
            cell?.textField?.keyboardType = .asciiCapable
            cell?.textField?.isSecureTextEntry = true
            cell?.textField!.returnKeyType = .next
            cell?.textField?.textAlignment = .right

            break
        case .passwordConfirm:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "FacebookLoginViewController" + "PasswordConfirm"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            cell?.titleText = "パスワード(確認)"
            cell?.placeholderText = "未設定"
            cell?.textFieldType = 4
            cell?.textField?.keyboardType = .asciiCapable
            cell?.textField?.isSecureTextEntry = true
            cell?.textField!.returnKeyType = .next
            cell?.textField?.textAlignment = .right

            break
        case .invitationCode:
            cellIdentifier = NSStringFromClass(BaseTextFieldCell.self) + "FacebookLoginViewController" + "InvitationCode"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }

            cell?.titleText = "招待コード"
            cell?.placeholderText = "未入力"
            cell?.textFieldType = 5
            cell?.textField?.keyboardType = .asciiCapable
            cell?.textField!.returnKeyType = .done
            cell?.textField?.textAlignment = .right

            break
        }
        
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let cell: BaseTextFieldCell? = tableView.cellForRow(at: indexPath) as? BaseTextFieldCell
        cell?.textField?.becomeFirstResponder()
    }
}

extension FacebookLoginViewController: BaseTextFieldPickerCellDelegate {
    public func baseTextFieldPickerCellFinishEditPicker(_ text: String, cell: BaseTextFieldPickerCell) {
        let nextKeyBoradCellTag: Int =  cell.textField!.tag + 1
        let nextKeyBoradCellIndexPass = IndexPath(item: nextKeyBoradCellTag, section: 0)
        let targetCell: BaseTextFieldCell? = tableView?.cellForRow(at: nextKeyBoradCellIndexPass) as? BaseTextFieldCell
        targetCell?.textField?.becomeFirstResponder()
    }
    
    public func baseTextFieldPickerCellEditingPicker(_ row: Int, cell: BaseTextFieldPickerCell) {
        tmpUser?.gender = tmpUser?.gender(fromRow: row) ?? -1
    }
}
