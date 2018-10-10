//
//  EmailPasswoardViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

public enum EmailPasswordSettingViewControllerType {
    case email
    case password
    case resetPass
}

open class EmailPasswordSettingViewController: BaseTableViewController,
ProfileSettingSaveButtonCellDelegate,
BaseTextFieldDelegate{
    
    fileprivate var sections = [Section]()
    let tmpUser: User = Me.sharedMe
    var type: EmailPasswordSettingViewControllerType?

    // ================================================================================
    // MARK: tableView struct
    fileprivate enum EmailPasswordSettingTableViewSectionType: Int {
        case emailPasswordSetting
    }
    
    fileprivate enum EmailPasswordSettingTableViewRowType: Int {
        case emailPasswordSettingCurrentPassword
        case emailPasswordSettingNew
        case emailPasswordSettingConform
        case emailPasswordSettingSaveButton
    }
    
    fileprivate struct Section {
        var sectionType: EmailPasswordSettingTableViewSectionType
        var rowItems: [EmailPasswordSettingTableViewRowType]
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
        if type == .resetPass {
            sections = [Section(sectionType: .emailPasswordSetting, rowItems: [.emailPasswordSettingCurrentPassword, .emailPasswordSettingSaveButton])]
            return
        }
        sections = [Section(sectionType: .emailPasswordSetting, rowItems: [.emailPasswordSettingCurrentPassword, .emailPasswordSettingNew, .emailPasswordSettingConform, .emailPasswordSettingSaveButton])]
        
    }
    
    override open func initializeNavigationLayout() {
        switch self.type! {
        case .email:
            self.navigationBarTitle = "メールの編集"
            break
        case .password:
            self.navigationBarTitle = "パスワードの編集"
            break
        case .resetPass:
            self.navigationBarTitle = "パスワードのリセット"
            break
        }
    }
    
    // ================================================================================
    // MARK: init
    
    required public init(type: EmailPasswordSettingViewControllerType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView!.showsPullToRefresh = false
        self.automaticallyAdjustsScrollViewInsets = false
        tableView!.showsVerticalScrollIndicator = false
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())
        
    }
    
    // ================================================================================
    // MARK: saveButton delegate
    
    open func saveButtonCellSaveButtonTapped(_ cell: ProfileSettingSaveButtonCell) {
        switch self.type! {
        case .email:
    
            if Utility.isEmpty(tmpUser.email?.newEmail) {
                self.simpleAlert(nil, message: "新しいメールアドレスを入力してください", cancelTitle: "OK", completion: nil)
                return
            }
            
            if Utility.isEmpty(tmpUser.email?.confirmEmail) {
                self.simpleAlert(nil, message: "確認メールアドレスを入力してください", cancelTitle: "OK", completion: nil)
                return
            }
            
            if tmpUser.email?.newEmail?.isValidEmail == false {
                self.simpleAlert(nil, message: "不正なメールアドレスです", cancelTitle: "OK", completion: nil)
                return
            }
            
            if tmpUser.email?.newEmail != tmpUser.email?.confirmEmail {
                self.simpleAlert(nil, message: "確認メールアドレスが違います", cancelTitle: "OK", completion: nil)
                return
            }
            
            Me.sharedMe.updateUserInfo(tmpUser, completion: {[weak self] (error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.simpleAlert(nil, message: error!.errorDespription, cancelTitle: "OK", completion: nil)
                        return
                    }
                    SVProgressHUD.dismiss()
                    self?.simpleAlert(nil, message: "メールアドレスを変更しました！", cancelTitle: "OK", completion: { [weak self] in
                        DispatchQueue.main.async {
                            self?.popViewController()
                        }
                    })
                }
            })
            break
          
        case .password:
            if Utility.isEmpty(tmpUser.password?.currentPassword) {
                self.simpleAlert(nil, message: "現在のパスワードを入力してください", cancelTitle: "OK", completion: nil)
                return
            }
            
            if Utility.isEmpty(tmpUser.password?.newPassword) {
                self.simpleAlert(nil, message: "新しいパスワードを入力してください", cancelTitle: "OK", completion: nil)
                return
            }
            
            if tmpUser.password?.newPassword != tmpUser.password?.confirmPassword {
                self.simpleAlert(nil, message: "確認パスワードが違います", cancelTitle: "OK", completion: nil)
                return
            }
            Me.sharedMe.changePassword(tmpUser.password!) {[weak self] (error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.simpleAlert(nil, message: error!.errorDespription, cancelTitle: "OK", completion: nil)
                        return
                    }
                    SVProgressHUD.dismiss()
                    self?.simpleAlert(nil, message: "パスワードを変更しました！", cancelTitle: "OK", completion: { [weak self] in
                        DispatchQueue.main.async {
                            self?.popViewController()
                        }
                    })
                }
            }
            break
        case .resetPass:
            
            if Utility.isEmpty(tmpUser.email?.currentEmail) {
                self.simpleAlert(nil, message: "メールアドレスを入力してください", cancelTitle: "OK", completion: nil)
                return
            }
            
            if tmpUser.email?.currentEmail?.isValidEmail == false {
                self.simpleAlert(nil, message: "不正なメールアドレスです", cancelTitle: "OK", completion: nil)
                return
            }
            
            RMUniversalAlert.show(in: self,
                                  withTitle: nil,
                                  message: "パスワードをリセットし、再設定用のメールを送信しますか?",
                                  cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: ["リセット"],
                                  tap: { [weak self] (al, index) in
                                    DispatchQueue.main.async {
                                        if index == al.firstOtherButtonIndex {
                                            SVProgressHUD.show()
                                            self?.resetPass({ (error) in
                                                if error != nil {
                                                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)

                                                    return
                                                }
                                                SVProgressHUD.dismiss()
                                                self?.simpleAlert("パスワードをリセットしました。",
                                                                  message: "再設定用のメールを送信しましたので、ご確認ください",
                                                                  cancelTitle: "OK",
                                                                  completion: nil)
                                            })
                                        }
                                    }
            })
            break
        }
    }

    func resetPass(_ completion: @escaping (_ error: Error?) ->Void) {
        Me.sharedMe.resetPass(tmpUser.email!.currentEmail!, completion: completion)
    }

    // ================================================================================
    // MARK: textField cell delegate
    
    open func baseTextFieldDidBeginEditting(_ textField: UITextField) {}
    
    open func edittingText<T : SignedNumber>(_ string: String?, type: T?) {
        if type == .some(0) {
            if self.type! == .password {
                tmpUser.password?.currentPassword = string
            } else {
                tmpUser.email?.currentEmail = string
            }
            
        } else if type == .some(1) {
            if self.type! == .password {
                tmpUser.password?.newPassword = string
            } else {
                tmpUser.email?.newEmail = string
            }
        } else {
            if self.type! == .password {
                tmpUser.password?.confirmPassword = string
            } else {
                tmpUser.email?.confirmEmail = string
            }
        }
    }
    
    open func didSelectTextFieldShouldReturn() {
        
    }
    
    open func baseTextFieldReturnKeyTapped(_ textField: UITextField) {
        
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
        case .emailPasswordSettingSaveButton:
            return ProfileSettingSaveButtonCell.cellHeightForObject(nil)
        default:
            return EmailSettingCell.cellHeightForObject(nil)
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .emailPasswordSettingCurrentPassword:
            cellIdentifier = "EmailPasswordSettingCurrentPassword" + NSStringFromClass(EmailSettingCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?EmailSettingCell
            if cell == nil {
                cell = EmailSettingCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
        
            (cell as! EmailSettingCell).placeholderText = self.type! == .password ? "現在のパスワード" : "現在のメールアドレス"
            (cell as! EmailSettingCell).textFieldText = self.type! == .password ? nil : tmpUser.email?.currentEmail
            (cell as! EmailSettingCell).textFieldType = 0
            (cell as! EmailSettingCell).textField?.isSecureTextEntry = self.type! == .password
            (cell as! EmailSettingCell).textField?.textAlignment = .left
            if self.type == .email {
                (cell as! EmailSettingCell).textField?.isUserInteractionEnabled = false
            } else {
                (cell as! EmailSettingCell).textField?.isUserInteractionEnabled = true
            }
            
            break
        case .emailPasswordSettingNew:
            cellIdentifier = "EmailPasswordSettingNew" + NSStringFromClass(EmailSettingCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?EmailSettingCell
            if cell == nil {
                cell = EmailSettingCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! EmailSettingCell).placeholderText = self.type! == .password ? "新しいパスワード" : "新しいメールアドレス"
            (cell as! EmailSettingCell).textFieldType = 1
            (cell as! EmailSettingCell).textField?.isSecureTextEntry = self.type! == .password
            (cell as! EmailSettingCell).textField?.textAlignment = .left
            (cell as! EmailSettingCell).textField?.isUserInteractionEnabled = true



            break
        case .emailPasswordSettingConform:
            cellIdentifier = "EmailPasswordSettingConform" + NSStringFromClass(EmailSettingCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?EmailSettingCell
            if cell == nil {
                cell = EmailSettingCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! EmailSettingCell).placeholderText = self.type! == .password ? "新しいパスワード(確認)" : "新しいメールアドレス(確認)"
            (cell as! EmailSettingCell).textFieldType = 2
            (cell as! EmailSettingCell).textField?.isSecureTextEntry = self.type! == .password
            (cell as! EmailSettingCell).textField?.textAlignment = .left
            (cell as! EmailSettingCell).textField?.isUserInteractionEnabled = true
            

            break
        case .emailPasswordSettingSaveButton:
            cellIdentifier = NSStringFromClass(ProfileSettingSaveButtonCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ProfileSettingSaveButtonCell
            if cell == nil {
                cell = ProfileSettingSaveButtonCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            if type == .resetPass {
                (cell as? ProfileSettingSaveButtonCell)?.saveButton?.setTitle("リセットする", for: .normal)
            } else {
                (cell as? ProfileSettingSaveButtonCell)?.saveButton?.setTitle("変更する", for: .normal)
            }
            
            break
        }
        
        if sections[indexPath.section].rowItems[indexPath.row] == .emailPasswordSettingSaveButton {
            tableView.separatorColor = UIColor.clear
        }
        
        return cell!
    }
}
