//
//  CreditCardRegisterViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/18.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert
import OmiseSDK

public let CreditCardViewControllerShouldRefreshKey = "CreditCardViewControllerShouldRefreshKey"

open class CreditCardRegisterViewController: BaseTableViewController,
    BaseTextFieldDelegate,
    CreditCardExpireAndCCVCellDelegate {
    
    fileprivate var sections = [Section]()
    fileprivate var tmpCard: CreditCard?
    fileprivate var backGroundView: UIView?
    fileprivate var ccvView: BaseThanksView?
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate enum CreditCardRegisterTableViewSectionType: Int {
        case creditCard
    }
    
    fileprivate enum CreditCardRegisterTableViewRowType: Int {
        case creditCardName
        case creditCardNumber
        case creditCardExpireAndCCVCell
    }
    
    fileprivate struct Section {
        var sectionType: CreditCardRegisterTableViewSectionType
        var rowItems: [CreditCardRegisterTableViewRowType]
    }
    
    // ================================================================================
    // MARK: setting
    
    override var shouldShowRightNavigationButton: Bool {
        get {
            return true
        }
    }
    
    override open func footerHeight() -> CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    override func initializeTableViewStruct() {
        sections = [Section(sectionType: .creditCard, rowItems: [.creditCardName,.creditCardNumber, .creditCardExpireAndCCVCell])]
    }
    
    override open func initializeNavigationLayout() {
        let rightButton = BarButtonItem.barButtonItemWithText("追加",
                                                              isBold: true,
                                                              isLeft: false,
                                                              target: self,
                                                              action: #selector(self.rightButtonTapped(_:)))
        self.setNavigationBarButton(rightButton, isLeft: false)
        self.navigationBarTitle = "クレジットカードの追加"
    }
    
    // ================================================================================
    // MARK: init
    
    required public init(card:  CreditCard?) {
        super.init(nibName: nil, bundle: nil)
        if card != nil {
            tmpCard = card
        } else {
            tmpCard = CreditCard()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.showsPullToRefresh = false
        self.automaticallyAdjustsScrollViewInsets = false
        tableView?.showsVerticalScrollIndicator = false
        tableView?.backgroundColor = UIColor.white
        tableView?.isFixTableScrollWhenChangeContentsSize = true
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())
        
        let headerView: CreditCardRegisterHeaderView = CreditCardRegisterHeaderView()
        tableView?.tableHeaderView = headerView

        backGroundView = UIView(frame: CGRect(x: 0, y: -backGroundGreenViewHeight, width: kCommonDeviceWidth, height: backGroundGreenViewHeight + headerView.height - NavigationHeightCalculator.navigationHeight()))
        backGroundView!.backgroundColor = kBackGroundColor
        self.view.insertSubview(backGroundView!, aboveSubview: tableView!)

        ccvView = BaseThanksView(delegate: self,
                                 image: UIImage(named: "img_cover_tutorial_ccv")!,
                                 title: "CCV番号の確認方法",
                                 detail: "CCV項目には、クレジットカード裏面のご署名\n記入欄、最後の3桁の数字を入力ください。",
                                 buttonText: "OK")
    }
    
    func rightButtonTapped(_ sender: BarButtonItem) {
        
        if Utility.isEmpty(Adress.defaultAdress()?.id) == true {
            RMUniversalAlert.show(in: self,
                                  withTitle: nil,
                                  message: "カード情報を紐付ける住所が登録されていません。まず先にお届け先住所を登録してください",
                                  cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: ["登録する"],
                                  tap: {[weak self] (al, index) in
                                    DispatchQueue.main.async {
                                        if index == al.firstOtherButtonIndex {
                                            let controller: AdressRegisterViewController = AdressRegisterViewController(adress: nil)
                                            controller.view.clipsToBounds = true
                                            self?.navigationController?.pushViewController(controller, animated: true)
                                        }
                                    }

            })
            return
        }

        if Utility.isEmpty(tmpCard?.name) {
            self.simpleAlert(nil, message: "名義人を入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpCard?.cardNumber) {
            self.simpleAlert(nil, message: "カード番号を入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpCard?.expirationMonth) {
            self.simpleAlert(nil, message: "期限(月)を入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpCard?.expirationYear) {
            self.simpleAlert(nil, message: "期限(年)を入力してください", cancelTitle: "OK", completion: nil)
            return
        }

        if Utility.isEmpty( tmpCard?.securityCode) {
            self.simpleAlert(nil, message: "セキュリティコードを入力してください", cancelTitle: "OK", completion: nil)
            return
        }
        
        SVProgressHUD.show()
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        let request = OmiseTokenRequest(
            name: tmpCard?.name ?? "",
            number: tmpCard?.cardNumber ?? "",
            expirationMonth: tmpCard?.expirationMonth?.int() ?? 0,
            expirationYear:  tmpCard?.expirationYear?.int() ?? 0,
            securityCode: tmpCard?.securityCode ?? ""
        )
        
        DBLog(request)
        
        var key: String = ""
        #if DEBUG
            key = kDebugOmiseTokenKey
        #elseif STAGING
            key = kDebugOmiseTokenKey
        #else
            key = ProductionOmiseTokenKey
        #endif
        
        let client = OmiseSDKClient(publicKey: key)
        client.__sendRequest(request) { (token, error) in
            // この戻りブロックは DispatchQueue.main.async で実行されることが規定されているようだ
            if error == nil {
                self.omiseOnSucceededToken(token)
                return
            }
            self.omiseOnFailed(error)
        }
    }

    // ================================================================================
    // MARK: - omise results

    private let invalidCardKey = "code"
    private let invalidCardValue = "invalid_card"
    private let invalidCardCode: Int64 = -4860373065024453427

    open func omiseOnFailed(_ error: NSError?) {
        self.view.isUserInteractionEnabled = true
        self.navigationItem.leftBarButtonItem?.isEnabled = true

        SVProgressHUD.dismiss()

        if let _ = error {
            if let errValue = error!.userInfo[self.invalidCardKey] as? String {
                if errValue == self.invalidCardValue {
                    RMUniversalAlert.show(in: self,
                                          withTitle: nil,
                                          message: "こちらのカードはブクマ！ではご利用いただけません。\n詳細は運営にお問い合わせください。",
                                          cancelButtonTitle: "キャンセル",
                                          destructiveButtonTitle: nil,
                                          otherButtonTitles: ["お問い合わせ"]) { [weak self] (alert: RMUniversalAlert, tappedButton: Int) in
                                            if tappedButton == alert.firstOtherButtonIndex {
                                                DispatchQueue.main.async {
                                                    let viewController = ContactViewController(type: .none, object: nil)
                                                    let navigationController = NavigationController(rootViewController: viewController)
                                                    self?.present(navigationController, animated: true, completion: nil)
                                                }
                                            }
                    }
                    return
                }
            }
        }

        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "クレジットカード登録に失敗しました。入力内容をご確認ください。",
                              cancelButtonTitle: "OK",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: nil,
                              tap: nil)
    }
    
    open func omiseOnSucceededToken(_ token: OmiseToken?) {
        tmpCard?.omiseCardId = token!.card!.cardId!
        tmpCard?.omiseToken = token!.tokenId
        tmpCard?.adressId = Adress.defaultAdress()?.id
        tmpCard?.last4 = token?.card?.lastDigits
        
        CreditCard.registerCard(tmpCard!) { (error) in
            self.view.isUserInteractionEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            DispatchQueue.main.async {
                if error != nil {
                    self.simpleAlert(nil, message: error!.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                SVProgressHUD.dismiss()
                
                self.simpleAlert(nil, message: "登録しました", cancelTitle: "OK", completion: { [weak self] in
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: CreditCardViewControllerShouldRefreshKey), object: nil)
                        for controller in self!.navigationController!.viewControllers {
                            if controller is PurchaseViewController {
                                _ =  self?.navigationController?.popToViewController(controller, animated: true)
                                return
                            }
                            if controller is AdressRegisterViewController {
                                _ =  self?.navigationController?.popToRootViewController(animated: true)
                                return
                            }
                        }

                        self?.popViewController()
                    }
                })
            }
        }
    }
    
    // ================================================================================
    // MARK: -  baseText delegate
    
    open func baseTextFieldDidBeginEditting(_ textField: UITextField) {}
    
    open func edittingText<T : SignedNumber>(_ string: String?, type: T?) {
        switch type {
        case .some(0):
            tmpCard?.name = string
            break
        case .some(1):
             tmpCard?.cardNumber = string
             let targetIndexPass = IndexPath(row: 1, section: 0)
             let targetCell: CardNumberCell?  = tableView?.cellForRow(at: targetIndexPass) as? CardNumberCell
             if (string?.length ?? 0) < 2 {
                targetCell?.setCardImage(string ?? "")
             }
            break
        default:
            break
        }
    }
    
    open func didSelectTextFieldShouldReturn() {}
    
    open func baseTextFieldReturnKeyTapped(_ textField: UITextField) {
        let nextKeyBoradCellTag: Int = textField.tag + 1
        let nextKeyBoradCellIndexPass = IndexPath(row: nextKeyBoradCellTag, section: 0)
        let targetCell: BaseTextFieldCell? = tableView?.cellForRow(at: nextKeyBoradCellIndexPass) as? BaseTextFieldCell
        targetCell?.textField?.becomeFirstResponder()
    }
    
    // ================================================================================
    // MARK: -  baseText delegate
    
    open func creditCardExpireAndCCVCellPickerValueChanged(_ text: String, year: String, month: String) {
        tmpCard?.expirationMonth = month
        tmpCard?.expirationYear = year
    }
    
    open func creditCardExpireAndCCVCellTextFieldDidChange(_ text: String) {
        tmpCard?.securityCode = text
    }
    
    open func creditCardExpireAndCCVCellTextFieldShouldReturn(_ cell: CreditCardExpireAndCCVCell) {
        let nextKeyBoradCellIndexPass = IndexPath(row: 2, section: 0)
        let targetCell: CreditCardExpireAndCCVCell? = tableView?.cellForRow(at: nextKeyBoradCellIndexPass) as? CreditCardExpireAndCCVCell
        targetCell?.ccvTextField?.becomeFirstResponder()
    }
    
    open func creditCardExpireAndCCVCellTextFieldDidEndEditting(_ cell: CreditCardExpireAndCCVCell) {
        
    }
    
    open func creditCardExpireAndCCVCellCCVTutorialButtonTapped(_ cell: CreditCardExpireAndCCVCell) {
        self.view.endEditing(true)
        ccvView?.appearOnViewController(self.navigationController ?? self)
    }
    
    // ================================================================================
    // MARK: -  BaseSuggestView delegate
    open override func baseSuggestViewCancelButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {
        
    }
    
    open override func baseSuggestViewActionButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {
        
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
        return CreditCardNameCell.cellHeightForObject(nil)
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .creditCardName:
            cellIdentifier = NSStringFromClass(CreditCardNameCell.self)
            cell =  tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?CreditCardNameCell
            if cell == nil {
                cell = CreditCardNameCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! CreditCardNameCell).textFieldType = .some(0)
            (cell as! CreditCardNameCell).textField?.textAlignment = .left

            break
        case .creditCardNumber:
            cellIdentifier = NSStringFromClass(CardNumberCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?CardNumberCell
            if cell == nil {
                cell =  CardNumberCell(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! CardNumberCell).textFieldType = .some(1)
            (cell as! CardNumberCell).textFieldMaxLength = 16
            (cell as! CardNumberCell).textField?.textAlignment = .left

            break
        case .creditCardExpireAndCCVCell:
            cellIdentifier = NSStringFromClass(CreditCardExpireAndCCVCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?CreditCardExpireAndCCVCell
            if cell == nil {
                cell = CreditCardExpireAndCCVCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            
            break
        }
        return cell!
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UITableView && scrollView.tag == 0 {
            if scrollView.contentOffsetY < 0 {
                backGroundView?.height = scrollView.contentOffsetY * -1 + backGroundGreenViewHeight
            } else {
                backGroundView?.height = 0
            }
        }
    }
}
