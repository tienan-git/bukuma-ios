//
//  SettingViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SDWebImage
import SVProgressHUD
import RMUniversalAlert

open class SettingViewController: BaseTableViewController {
    
    fileprivate var sections = [Section]()
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate enum SettingTableViewSectionType: Int {
        case userInfo
        case sales
        case terms
        case other
    }
    
    fileprivate enum SettingTableViewRowType {
        case userInfoTitle
        case userInfoProfile
        case userInfoAdress
        case userInfoPayment
        case userInfoEmail
        case userInfoComformCallNumber
        case salesTitle
        case salesMoneyReqest
        case salesPoint
        case salesHistory
        case termsTitle
        case termsOfUse
        case termsPrivacy
        case termsCommercialLow
        case otherTitle
        case otherPushNotification
        case otherUnBlock
        case otherDeleteCache
        case otherDeleteUser
    }
    
    fileprivate struct Section {
        var sectionType: SettingTableViewSectionType
        var rowItems: [SettingTableViewRowType]
    }
    
    // ================================================================================
    // MARK: setting
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }
    
    override open func scrollIndicatorInsetBottom() -> CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    override func initializeTableViewStruct() {
        sections = [Section(sectionType: .userInfo, rowItems: [.userInfoTitle, .userInfoProfile, .userInfoAdress, .userInfoPayment, .userInfoEmail, .userInfoComformCallNumber]),
                    Section(sectionType: .sales, rowItems: [.salesTitle, .salesMoneyReqest, .salesPoint, .salesHistory]),
                    Section(sectionType: .terms, rowItems: [.termsTitle, .termsOfUse, .termsPrivacy, .termsCommercialLow]),
                    Section(sectionType: .other, rowItems: [.otherTitle, .otherPushNotification, .otherUnBlock, .otherDeleteCache, .otherDeleteUser])]
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "設定"
        self.title = "設定"
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
        self.automaticallyAdjustsScrollViewInsets = false
        tableView!.showsVerticalScrollIndicator = false
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: MeFirstRegisterkey), object: nil)

    }
    
    func reload() {
        Me.sharedMe.syncronizeMyProfileWithCompletion {[weak self] (error) in
            DispatchQueue.main.async {
                self?.tableView?.reloadData()
            }
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
        case .userInfoTitle, .salesTitle, .otherTitle:
            return BaseTitleCell.cellHeightForObject(nil)
        
        default:
            return 50.0
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .userInfoTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "ユーザー情報"
            break
        case .userInfoProfile:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "プロフィール"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_profile")
            cell?.rightImage = UIImage(named: "ic_to")
            break
        case .userInfoAdress:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "住所"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_map")
            cell?.rightImage = UIImage(named: "ic_to")
            break
        case .userInfoPayment:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "支払い方法"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_pay")
            cell?.rightImage = UIImage(named: "ic_to")
            break
        case .userInfoEmail:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "メール・パスワード"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_mail")
            cell?.rightImage = UIImage(named: "ic_to")
            break
        case .userInfoComformCallNumber:
            cellIdentifier = NSStringFromClass(SettingPhoneCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?SettingPhoneCell
            if cell == nil {
                cell = SettingPhoneCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! SettingPhoneCell).title = "電話番号の確認"
            (cell as! SettingPhoneCell).updateLayout()
            break
        case .salesTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "売上・ポイント"
            break
            
        case .salesMoneyReqest:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "売上・振込申請"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
             (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_proceed")
            cell?.rightImage = UIImage(named: "ic_to")
            break
        case .salesPoint:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "ポイント"
             (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_point")
            cell?.rightImage = UIImage(named: "ic_to")
            break
        case .salesHistory:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "取引・ポイント履歴"
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_history")
            cell?.rightImage = UIImage(named: "ic_to")
            break
        case .otherTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "その他の設定"
            break
        case .otherPushNotification:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "通知設定"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_switch")
            cell?.rightImage = UIImage(named: "ic_to")

            break
        case .otherUnBlock:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "ブロックリスト"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_blocking")
            cell?.rightImage = UIImage(named: "ic_to")
            break
        case .otherDeleteCache:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "キャッシュを削除"
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_cash")
            cell?.rightImage = nil
            break
        case .otherDeleteUser:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "退会する"
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_exit")
            (cell as! BaseIconTextTableViewCell).rightImage = UIImage(named: "ic_to")
            break
        case .termsTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "規約"
            break
        case .termsOfUse:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "利用規約"
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_terms")
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            cell?.rightImage = UIImage(named: "ic_to")
            break
        case .termsPrivacy:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "プライバシーポリシー"
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_privacy")
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            cell?.rightImage = UIImage(named: "ic_to")
            break
        case .termsCommercialLow:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "特定商取引法"
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_set_contract")
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            cell?.rightImage = UIImage(named: "ic_to")
            break
        }
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        var controller: BaseViewController?
        
        if Me.sharedMe.isRegisterd == false {
            showUnRegisterAlert()
            return
        }
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .userInfoProfile:
            controller = ProfileSettingViewController()
            break
        case .userInfoAdress:
            controller = AdressInfoViewController()
            break
        case .userInfoPayment:
            if Me.sharedMe.defaultCards == nil {
                controller = PaymentInfoViewController()
            } else {
                controller = CreditCardInfoViewController()
            }
            break
        case .userInfoEmail:
            controller = EmailInfoViewController()
            break
        case .userInfoComformCallNumber:
            if Me.sharedMe.verified == true {
                self.updatePhoneNumberAlert()
            } else {
                controller = RegisterPhoneNumberViewController(type: .input)
            }
            
            break
        case .salesMoneyReqest:
            controller = MoneyReqestViewController()
            break
        case .salesPoint:
            controller = PointViewController()
            break
        case .salesHistory:
            controller = TransactionHistoryViewController()
            break
        case .otherPushNotification:
             controller = NotificationSettingViewController()
            break
        case .otherUnBlock:
            controller = BlockingListViewController()
            break
        case .otherDeleteCache:
            RMUniversalAlert.show(in: self,
                                  withTitle: nil,
                                  message: "キャッシュを削除するとアプリの容量を削減できますが、一時的に通信料が増大します。\nキャッシュを削除しますか？",
                                  cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: ["キャッシュを削除"],
                                  tap: {[weak self] (alert, buttonIndex) in
                                    if buttonIndex == alert.firstOtherButtonIndex {
                                        self?.sucsessDeleteCacheAl()
                                        let imageCache = SDImageCache.shared()
                                        imageCache.clearDisk()
                                        imageCache.clearMemory()
                                    }
            })
            break
        case .otherDeleteUser:
            controller = DeleteAccountViewController()
                break
        case .termsOfUse:
            controller = BaseWebViewController(url: URL(string: kTermURL)!)
            break
        case .termsPrivacy:
            controller = BaseWebViewController(url: URL(string: kPrivacyURL)!)
            break
        case .termsCommercialLow:
            controller = BaseWebViewController(url: URL(string: kCommercialTransactionsLawURL)!)
            break
        default:
            break
        }
        
        if controller != nil {
            controller!.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller!, animated: true)
        }
    }
    
    fileprivate func sucsessDeleteCacheAl() {
        SVProgressHUD.dismiss()
        
        self.simpleAlert(nil, message: "キャッシュを削除しました！", cancelTitle: "OK", completion: nil)
    }
    
    fileprivate func updatePhoneNumberAlert() {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "現在の電話番号 : \(Me.sharedMe.phone?.currentPhoneNumber ?? "")を変更しますか?",
            cancelButtonTitle: "いいえ",
            destructiveButtonTitle: nil,
            otherButtonTitles: ["変更する"]) {[weak self] (al, index) in
                if index == al.firstOtherButtonIndex {
                    DispatchQueue.main.async {
                        let controller = RegisterPhoneNumberViewController(type: .input)
                        controller.view.clipsToBounds = true
                        self?.navigationController?.pushViewController(controller, animated: true)
                    }
                }
        }
    }
}
