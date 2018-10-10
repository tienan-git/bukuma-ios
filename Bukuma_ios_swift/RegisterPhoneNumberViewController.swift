//
//  RegisterPhoneNumberViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

public enum RegisterPhoneNumberViewControllerType {
    case input
    case verify
}

open class RegisterPhoneNumberViewController: BaseTableViewController,
BaseTextFieldDelegate,
RegisterPhoneFooterViewDelegate,
RegisterKeyBoardInputViewDelegate {
    
    var tmpPhone: Phone? = Phone()
    var keyboardInputView: RegisterKeyBoardInputView?
    var type: RegisterPhoneNumberViewControllerType?
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate var sections = [Section]()
    
    fileprivate enum RegisterPhoneNumberTableViewSectionType: Int {
        case registerPhone
    }
    
    fileprivate enum RegisterPhoneNumberTableViewRowType {
        case registerPhoneNumber
    }
    
    fileprivate struct Section {
        var sectionType: RegisterPhoneNumberTableViewSectionType
        var rowItems: [RegisterPhoneNumberTableViewRowType]
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
        sections = [Section(sectionType: .registerPhone, rowItems: [.registerPhoneNumber])]
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "電話番号の確認"
        self.title = "電話番号の確認"
    }
    
    // ================================================================================
    // MARK: init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(type: RegisterPhoneNumberViewControllerType) {
       super.init(nibName: nil, bundle: nil)
        self.type = type
        
    }
    
    func rightButtonTapped(_ sender: BarButtonItem) {
        self.registerPhone()
    }
    
    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        tableView!.backgroundColor = UIColor.white
        tableView!.isScrollEnabled = false
        
        tableView!.showsPullToRefresh = false
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())
        
        let headerView: UIView = UIView(frame: CGRect(x: 0.0, y: 0, width: kCommonDeviceWidth, height: 69))
        headerView.backgroundColor = UIColor.white
        
        let headerLabel: UILabel! = UILabel(frame: CGRect(x: 10.0, y: 23.0, width: kCommonDeviceWidth - 10 * 2, height: 69))
        headerLabel.text = self.type! == .input ? "電話番号を入力してください" : "SMSで届いた認証番号を入力してください"
        headerLabel.textAlignment = .left
        headerLabel.numberOfLines = 0
        headerLabel.textColor = kDarkGray03Color
        headerLabel.font = UIFont.boldSystemFont(ofSize: 22)
        headerLabel.height = headerLabel.text!.getTextHeight(headerLabel.font, viewWidth: headerLabel.width)
        headerLabel.backgroundColor = UIColor.white
        
        headerView.height = headerLabel.height + 23 * 2
        
        headerView.addSubview(headerLabel)
        
        tableView!.tableHeaderView = headerView
        
        let footerView: RegisterPhoneFooterView = RegisterPhoneFooterView(delegate: self, type: self.type!)
        
        tableView!.tableFooterView = footerView
        
        keyboardInputView = RegisterKeyBoardInputView(delegate: self)
        keyboardInputView!.text = self.type! == .input ? "次へ" : "認証して終了"
        
    }
    
    func registerPhone() {
        self.view.endEditing(true)
        switch self.type! {
        case .input:
            if Utility.isEmpty(tmpPhone?.currentPhoneNumber) {
                 self.simpleAlert(nil, message: "電話番号を入力してください", cancelTitle: "OK", completion: nil)
                return
            }
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.view.isUserInteractionEnabled = false
            
            Me.sharedMe.veriftPhoneNumber(tmpPhone!) {[weak self] (error) in
               DispatchQueue.main.async {
                    self?.view.isUserInteractionEnabled = true
                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                    if error != nil {
                        self?.simpleAlert(nil, message: "認証失敗しました", cancelTitle: "OK", completion: nil)
                        return
                    }
                    
                    let controller: RegisterPhoneNumberViewController = RegisterPhoneNumberViewController(type: .verify)
                    controller.view.clipsToBounds = true
                    self?.navigationController?.pushViewController(controller, animated: true)
                }
            }
            
            break
            
        case .verify:
            self.view.isUserInteractionEnabled = false
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            if Utility.isEmpty(tmpPhone?.codeFromSMS) {
                self.view.isUserInteractionEnabled = true
                self.simpleAlert(nil, message: "認証番号を入力してください", cancelTitle: "OK", completion: nil)
                return
            }
            Me.sharedMe.smsVerifyPhoneNumber(tmpPhone?.codeFromSMS ?? "", completion: {[weak self] (error) in
                DispatchQueue.main.async {
                    self?.view.isUserInteractionEnabled = true
                    self?.navigationItem.leftBarButtonItem?.isEnabled = false
                    if error != nil {
                        self?.simpleAlert(nil, message: "認証失敗しました", cancelTitle: "OK", completion: nil)
                        return
                    }
                    SVProgressHUD.dismiss()
                    self?.simpleAlert(nil, message: "認証成功しました！", cancelTitle: "OK", completion: { [weak self] in
                       DispatchQueue.main.async {
                            if self?.isModal == true {
                                self?.dismiss(animated: true, completion: {
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MeFirstRegisterkey), object: nil)
                                    }
                                })
                                return
                            }
                            _ = self?.navigationController?.popToRootViewController(animated: true)
                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MeFirstRegisterkey), object: nil)
                        }
                    })
                }
            })
            break
        }
    }
    
    func reqestCallVerify(_ completion: @escaping (_ error: Error?) ->Void) {
        Me.sharedMe.requestPhoneCallVerification({[weak self] (error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.simpleAlert(nil, message: "認証失敗しました", cancelTitle: "OK", completion: nil)
                    completion(error)
                    return
                }
                completion(nil)
            }
            })
    }
    
    // ================================================================================
    // MARK: keyboard inputView delegate
    
    open func registerKeyBoardInputViewTapped(_ view: RegisterKeyBoardInputView) {
        self.registerPhone()
    }
    
    // ================================================================================
    // MARK: footerView delegate
    
    open func registerPhoneFooterViewTermLinkTapped(_ view: RegisterPhoneFooterView) {
        let controller: BaseWebViewController = BaseWebViewController(url: URL(string: kTermURL)!)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    open func registerPhoneFooterViewPrivacyLinkTapped(_ view: RegisterPhoneFooterView) {
        let controller: BaseWebViewController = BaseWebViewController(url: URL(string: kPrivacyURL)!)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    open func registerPhoneFooterViewPhoneTapped(_ view: RegisterPhoneFooterView) {
       _ = self.navigationController?.popViewController(animated: true)
    }
    
    open func registerPhoneFooterViewReqestPhoneTapped(_ view: RegisterPhoneFooterView) {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "音声電話認証を行いますか?",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["行う"]) {[weak self] (al, index) in
                                DispatchQueue.main.async {
                                    if index == al.firstOtherButtonIndex {
                                        self?.reqestCallVerify({ (error) in
                                            DispatchQueue.main.async {
                                                if error != nil {
                                                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                                                    return
                                                }
                                                self?.simpleAlert("音声電話リクエストを送信しました", message: "電話がかかってくるまで少々お待ちください", cancelTitle: "OK", completion: nil)
                                            }
                                        })
                                    }
                                }
        }

    }

    // ================================================================================
    // MARK: RegisterTextCell delegate

    open func baseTextFieldDidBeginEditting(_ textField: UITextField) {}

    open func edittingText<T : SignedNumber>(_ string: String?, type: T?) {
        if self.type == .input {
            tmpPhone?.currentPhoneNumber = string
        } else {
            tmpPhone?.codeFromSMS = string
        }
    }
    
    open func didSelectTextFieldShouldReturn() {}
    
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
        return RegisterPhoneNumberCell.cellHeightForObject(nil)
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: RegisterPhoneNumberCell?
        var cellIdentifier: String! = ""
        
        cellIdentifier = NSStringFromClass(RegisterPhoneNumberCell.self)
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?RegisterPhoneNumberCell
        if cell == nil {
            cell = RegisterPhoneNumberCell.init(reuseIdentifier: cellIdentifier, delegate: self)
        }
        cell!.textField!.inputAccessoryView = keyboardInputView
        cell!.type = type
        
        return cell!
    }
}
