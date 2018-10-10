//
//  PurchaseViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/14.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import FBSDKCoreKit
import SVProgressHUD
import RMUniversalAlert

let PurchaseViewControllerPurchaseKey: String = "PurchaseViewControllerPurchaseKey"

open class PurchaseViewController: BaseTableViewController,
ProfileSettingSaveButtonCellDelegate {
    
    fileprivate var sections = [Section]()
    fileprivate var merchandise: Merchandise?
    fileprivate var book: Book?
    fileprivate var purchaseThanksView: PurchaseThanksView?
    fileprivate var repeatTimer: Timer?
    
    deinit {
        repeatTimer?.invalidate()
        repeatTimer = nil
        SVProgressHUD.dismiss()
    }
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate enum PurchaseViewControllerSectionType: Int {
        case merchandiseInfo
        case purchaseInfo
        case shippingAdressInfo
        case purchaseButton
    }
    
    fileprivate enum PurchaseViewControllerRowType {
        case merchandiseInfoTitle
        case merchandiseInfoBookDetail
        case merchandiseInfoSeller
        case purchaseInfoTitle
        case purchaseInfoPaymentWay
        case purchaseInfoMerchandisePrice
        case purchaseUsablePoint
        case purchaseUsableSales
        case purchaseInfoPaymentAmount
        case purchaseInfoNote
        case shippingAdressInfoTitle
        case shippingAdressInfoDetail
        case purchaseButton
    }
    
    fileprivate struct Section {
        var sectionType: PurchaseViewControllerSectionType
        var rowItems: [PurchaseViewControllerRowType]
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
        
        if Me.sharedMe.defaultCards == nil {
            if consmePoint() == 0 && consmeSales() == 0 {
                sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                             Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice]),
                             Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                             Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                return
            }
            
            if consmePoint() > 0 && consmeSales() == 0 {
                sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                             Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice, .purchaseUsablePoint, .purchaseInfoPaymentAmount, .purchaseInfoNote]),
                             Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                             Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                return
            }
            
            if consmePoint() == 0 && consmeSales() > 0 {
                sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                             Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice, .purchaseUsableSales, .purchaseInfoPaymentAmount, .purchaseInfoNote]),
                             Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                             Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                return
            }
            
            if consmePoint() > 0 && consmeSales() > 0  {
                sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                             Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice, .purchaseUsablePoint, .purchaseUsableSales, .purchaseInfoPaymentAmount, .purchaseInfoNote]),
                             Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                             Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                return
            }
            
        } else {
            if paymentAmount() == 0 {
                if consmePoint() == 0 && consmeSales() == 0 {
                    sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                                 Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice, .purchaseInfoPaymentAmount, .purchaseInfoNote]),
                                 Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                                 Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                    return
                }
                
                if consmePoint() > 0 && consmeSales() == 0 {
                    sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                                 Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice, .purchaseUsablePoint, .purchaseInfoPaymentAmount, .purchaseInfoNote]),
                                 Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                                 Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                    return
                }
                
                if consmePoint() == 0 && consmeSales() > 0 {
                    sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                                 Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice, .purchaseUsableSales, .purchaseInfoPaymentAmount, .purchaseInfoNote]),
                                 Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                                 Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                    return
                }
                
                if consmePoint() > 0 && consmeSales() > 0  {
                    sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                                 Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice, .purchaseUsablePoint, .purchaseUsableSales, .purchaseInfoPaymentAmount, .purchaseInfoNote]),
                                 Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                                 Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                    return
                }

            } else {
                if consmePoint() == 0 && consmeSales() == 0 {
                    sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                                 Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice, .purchaseInfoPaymentWay, .purchaseInfoPaymentAmount, .purchaseInfoNote]),
                                 Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                                 Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                    return
                }
                
                if consmePoint() > 0 && consmeSales() == 0 {
                    sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                                 Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice, .purchaseInfoPaymentWay, .purchaseUsablePoint, .purchaseInfoPaymentAmount, .purchaseInfoNote]),
                                 Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                                 Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                    return
                }
                
                if consmePoint() == 0 && consmeSales() > 0 {
                    sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                                 Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice, .purchaseInfoPaymentWay, .purchaseUsableSales, .purchaseInfoPaymentAmount, .purchaseInfoNote]),
                                 Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                                 Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                    return
                }
                
                if consmePoint() > 0 && consmeSales() > 0  {
                    sections = [ Section(sectionType: .merchandiseInfo, rowItems: [.merchandiseInfoTitle, .merchandiseInfoBookDetail, .merchandiseInfoSeller]),
                                 Section(sectionType: .purchaseInfo, rowItems: [.purchaseInfoTitle, .purchaseInfoMerchandisePrice, .purchaseInfoPaymentWay, .purchaseUsablePoint, .purchaseUsableSales, .purchaseInfoPaymentAmount, .purchaseInfoNote]),
                                 Section(sectionType: .shippingAdressInfo, rowItems: [.shippingAdressInfoTitle, .shippingAdressInfoDetail]),
                                 Section(sectionType: .purchaseButton, rowItems: [.purchaseButton])]
                    return
                }
            }
        }
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "購入手続き"
        self.title = "購入手続き"
    }
    
    // ================================================================================
    // MARK: init
    
    required public init(merchandise: Merchandise, book: Book) {
        super.init(nibName: nil, bundle: nil)
        self.merchandise = merchandise
        self.book = book
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        let addressCellNib = UINib(nibName: AddressAndNameCell.nibName, bundle: nil)
        self.tableView?.register(addressCellNib, forCellReuseIdentifier: AddressAndNameCell.reuseID)
        
        tableView?.reloadData()
        tableView?.showsPullToRefresh = false
        self.automaticallyAdjustsScrollViewInsets = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
        
        purchaseThanksView = PurchaseThanksView(delegate: self,
                                                image: UIImage(named: "img_cover_after_purchase")!,
                                                title: "購入が完了しました",
                                                detail: "出品者の発送をお待ちください",
                                                buttonText: "取引ページへ")
        
    }
    
    func reload() {
        tableView?.reloadData()
    }
    
    //念のためuserのpointを再計算して、クレジットカード、の情報を再取得
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        User.recalculatePoint { [weak self] (error) in
            if error != nil {
                if error?.errorCodeType == .userBanned {
                    SVProgressHUD.dismiss()
                    self?.navigationController?.popViewController(animated: false)
                } else {
                    self?.pleaseRetry()
                }
                return
            }

            CreditCard.getCardInfo { (cards, error) in
                if error != nil {
                    self?.pleaseRetry()
                    return
                }

                Me.sharedMe.syncronizeMyProfileWithCompletion { (error) in
                    if error != nil {
                        self?.pleaseRetry()
                        return
                    }

                    DispatchQueue.main.async {
                        self?.initializeTableViewStruct()
                        self?.tableView?.reloadData()
                        SVProgressHUD.dismiss()

                        if Me.sharedMe.defaultAdress == nil {
                            self?.showCanBuyAlert("住所が登録されていません。\n購入するためには、住所登録が必要です。",
                                                  controller: AdressRegisterViewController(adress: nil),
                                                  otherButtonsTitle: ["住所登録画面へ進む"])
                            return
                        } else {
                            if let myPoint = Me.sharedMe.point,
                               let usablePoint = self?.usablePoint() {
                                if usablePoint > 0 || myPoint.usableSales.int() > 0 {
                                    return
                                }
                            }

                            if Me.sharedMe.defaultCards == nil {
                                RMUniversalAlert.show(in: self!,
                                                      withTitle: nil,
                                                      message: "購入のためにはクレジットカード登録もしくは、ブクマポイントが必要です",
                                                      cancelButtonTitle: "キャンセル",
                                                      destructiveButtonTitle: nil,
                                                      otherButtonTitles: ["クレジットカード登録画面へ進む", "友人を招待してポイントをゲット"]) { (al, index) in
                                                        DispatchQueue.main.async {
                                                            if index == al.cancelButtonIndex {
                                                                self?.popViewController()
                                                            } else if index == al.firstOtherButtonIndex {
                                                                let controller: CreditCardRegisterViewController = CreditCardRegisterViewController(card: nil)
                                                                controller.view.clipsToBounds = true
                                                                self?.navigationController?.pushViewController(controller, animated: true)
                                                            } else {
                                                                let controller: InvitationUserViewController = InvitationUserViewController()
                                                                controller.view.clipsToBounds = true
                                                                self?.navigationController?.pushViewController(controller, animated: true)
                                                            }
                                                        }
                                }
                                return
                            }

                            if self?.isValidDate(for: Me.sharedMe.defaultCards!) == false {
                                self?.showCanBuyAlert("カードの有効期限が過ぎているようです。\n別のカードを選択するか新しくカードを登録してください。",
                                                      controller: CreditCardInfoViewController(),
                                                      otherButtonsTitle: ["了解"])
                                return
                            }
                        }
                    }
                }
            }
        }
    }

    private func isValidDate(for card: CreditCard)-> Bool {
        guard let cardYearString = card.expirationYear else { return false }
        guard let cardMonthString = card.expirationMonth else { return false }
        let cardYear = cardYearString.int()
        let cardMonth = cardMonthString.int()

        let now = Calendar.current.dateComponents([.year, .month], from: Date())
        if now.year! > cardYear {
            return false
        } else if now.year! == cardYear {
            return now.month! <= cardMonth
        } else {
            return true
        }
    }

    private func pleaseRetry() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()

            self.simpleAlert(nil, message: "ユーザー情報が取得できませんでした。もう一度購入手続きボタンを押してみてください。", cancelTitle: "了解") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    public func saveButtonCellSaveButtonTapped(_ cell: ProfileSettingSaveButtonCell) {
        
        if merchandise?.isSold == true {
            self.simpleAlert(nil, message: "この商品はすでに購入されています", cancelTitle: "OK", completion: nil)
            return
        }
        
        if  Me.sharedMe.isMine(merchandise!.user!.identifier!) == true {
            self.simpleAlert(nil, message: "自分が出品した商品は買うことができません", cancelTitle: "OK", completion: nil)
            return
        }
        
        self.view.isUserInteractionEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        if Me.sharedMe.defaultCards?.id == nil {
            if consmeSales() > 0 || consmePoint() > 0 {
                if consmeAmount() < (merchandise?.price?.int() ?? 0) {
                    self.showInviteAlert()
                    return
                }
                
                self.showPurchaseViaPointAlert(self.consmePoint(),
                                               usableSales: self.consmeSales(),
                                               buyAdditinalPoint: false,
                                               merchandise: merchandise ?? Merchandise())
            }
            
            return
        }
    
        if consmeSales() > 0 || consmePoint() > 0 {
            if consmeAmount() < (merchandise?.price?.int() ?? 0) {
                self.showPurchaseViaPointAlert(self.consmePoint(),
                                               usableSales: self.consmeSales(),
                                               buyAdditinalPoint: true,
                                               merchandise: merchandise ?? Merchandise())
                return
            }
            self.showPurchaseViaPointAlert(self.consmePoint(),
                                           usableSales: self.consmeSales(),
                                           buyAdditinalPoint: false,
                                           merchandise: merchandise ?? Merchandise())
            return
        }
        
        
        self.showComformAlert {[weak self] (buy) in
            DispatchQueue.main.async {
                if buy {
                    self?.buy(merchandise: self?.merchandise ?? Merchandise())
                }
            }
        }
    }
    
    // ================================================================================
    // MARK: - BaseSuggestView delegate
    
    open override func baseSuggestViewCancelButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {}
    
    open override func baseSuggestViewActionButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {
        SVProgressHUD.show()
        Transaction.getTransactionFromMerchandiseId(merchandise!.id!) { (transaction) in
            SVProgressHUD.dismiss()
            if transaction != nil {
                let controller: ShippingProgressTableViewController = ShippingProgressTableViewController(transaction: transaction!)
                controller.view.clipsToBounds = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    // ================================================================================
    // MARK: - Purchase Alerts function
    
    fileprivate func showPurchaseViaPointAlert(_ usablePoint: Int, usableSales: Int, buyAdditinalPoint: Bool, merchandise: Merchandise) {
        
        let additinalPoint: Int = self.paymentAmount()
        var string: String = ""
        
        if buyAdditinalPoint {
            if usablePoint > 0 && usableSales > 0 {
                string = "ブクマポイントを\(usablePoint.thousandsSeparator())pt、売上を¥\(usableSales.thousandsSeparator())を使って、残り¥\(additinalPoint.thousandsSeparator())をクレジットカードで支払いますか?"
            } else if usablePoint > 0 && usableSales == 0 {
                 string = "ブクマポイントを\(usablePoint)pt使って、残り¥\(additinalPoint.thousandsSeparator())をクレジットカードで支払いますか?"
            } else if usablePoint == 0 && usableSales > 0 {
                string = "売上を¥\(usableSales.thousandsSeparator())使って、残り¥\(additinalPoint.thousandsSeparator())をクレジットカードで支払いますか?"
            }
        } else {
            if usablePoint > 0 && usableSales > 0 {
                string = "ブクマポイントを\(usablePoint.thousandsSeparator())pt、売上を¥\(usableSales.thousandsSeparator())使って購入しますか?"
            } else if usablePoint > 0 && usableSales == 0 {
                string = "ブクマポイントを\(usablePoint.thousandsSeparator())pt使って購入しますか?"
            } else if usablePoint == 0 && usableSales > 0 {
                string = "売上を¥\(usableSales.thousandsSeparator())使って購入しますか?"
            }
        }
        
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: string,
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["支払う"]) {[weak self] (al, index) in
                                DispatchQueue.main.async(execute: {
                                    if index == al.cancelButtonIndex {
                                        self?.navigationItem.leftBarButtonItem?.isEnabled = true
                                        self?.view.isUserInteractionEnabled = true
                                    } else {
                                        self?.buy(merchandise: merchandise)
                                    }
                                })
        }
    }

    fileprivate func showErrorWhenPurchaseAlert(_ error: Error?) {
        var title: String = "エラーが発生しました"
        var message: String = "時間をおいて再度お試し下さい"
        var cancelButtonTitle: String = "了解しました"
        var otherButtonTitles: [String] = ["何度もエラーが出る場合"]
        
        if error?.errorCodeType == .pointInsufficient {
            title = "ポイントが不足しています"
        }
        
        if error?.errorCodeType == .shouldRecaluclate {
            #if DEBUG
                title = "ポイント再計算エラーが発生しました"
            #else
                 title = "不明なエラーです"
            #endif
        }
        
        if error?.errorCodeType == .accessForbidden {
            title = "決済システムでエラーが発生しました"
        }
        
        if error?.errorCodeType == .badRequest {
            title = "決済システムでエラーが発生しました。"
            message = "ご登録のクレジットカードをお確かめください。"
            
            if Me.sharedMe.defaultCards?.validsecurityCode == "false" {
                message = "登録したセキュリティコードが間違っている可能性があります。クレジットカードを削除して登録し直してください"
                cancelButtonTitle = "今はしない"
                otherButtonTitles = ["削除して登録し直す"]
            }
        }
        
        RMUniversalAlert.show(in: self,
                              withTitle: title,
                              message: message,
                              cancelButtonTitle: cancelButtonTitle,
                              destructiveButtonTitle: nil,
                              otherButtonTitles: otherButtonTitles) {[weak self] (al, index) in
                                DispatchQueue.main.async(execute: {
                                    if index == al.firstOtherButtonIndex {
                                        if error?.errorCodeType == .badRequest {
                                            let controller: CreditCardInfoViewController = CreditCardInfoViewController()
                                            controller.view.clipsToBounds = true
                                            self?.navigationController?.pushViewController(controller, animated: true)
                                            return
                                        }
                                        let controller: ContactViewController = ContactViewController(objects: [self?.book, self?.merchandise])
                                        let navi: NavigationController = NavigationController(rootViewController: controller)
                                        self?.present(navi, animated: true, completion: nil)
                                    }
                                })
        }
    }

    fileprivate func showInviteAlert() {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "ポイントが足りません。クレジットカードで購入するか、友達を招待してポイントをゲットしてください",
                              cancelButtonTitle: "OK",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["友達を招待する","クレジットカードを登録する"]) {[weak self] (al, index) in
                                DispatchQueue.main.async(execute: {
                                    self?.view.isUserInteractionEnabled = true
                                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                                    if index == al.cancelButtonIndex {

                                    } else if index == al.firstOtherButtonIndex {
                                        let controller: InvitationUserViewController = InvitationUserViewController()
                                        controller.view.clipsToBounds = true
                                        self?.navigationController?.pushViewController(controller, animated: true)
                                    } else {
                                        let controller: CreditCardRegisterViewController = CreditCardRegisterViewController(card: nil)
                                        controller.view.clipsToBounds = true
                                        self?.navigationController?.pushViewController(controller, animated: true)
                                    }
                                })
        }
    }

    fileprivate func showComformAlert(_ completion: @escaping (_ buy: Bool) ->Void) {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "本当に購入しますか?",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["購入する"]) {[weak self] (al, index) in
                                DispatchQueue.main.async(execute: {
                                    if index == al.firstOtherButtonIndex {
                                        completion(true)
                                        return
                                    }
                                    self?.view.isUserInteractionEnabled = true
                                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                                    completion(false)
                                })
        }
    }

    fileprivate func showCanBuyAlert(_ alertMessage: String, controller: BaseViewController?, otherButtonsTitle: [String]?) {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: alertMessage,
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: otherButtonsTitle,
                              tap: {[weak self] (al, index) in
                                DispatchQueue.main.async(execute: {
                                    if index == al.cancelButtonIndex {
                                        self?.popViewController()
                                    } else {
                                        if controller != nil {
                                            controller!.view.clipsToBounds = true
                                            self?.navigationController?.pushViewController(controller!, animated: true)
                                        }
                                    }
                                })
        })
    }

    // MARK: - 購入メソッド

    fileprivate func buy(merchandise inMerchandise: Merchandise) {
        SVProgressHUD.show()

        Merchandise.getMerchandiseInfo(inMerchandise.id ?? "0") { [weak self] (merchandiseInfo: Merchandise?, error: Error?) in
            if error != nil {
                DispatchQueue.main.async {
                    self?.view.isUserInteractionEnabled = true
                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                    SVProgressHUD.dismiss()
                    self?.showErrorWhenPurchaseAlert(error)
                }
                return
            }

            if merchandiseInfo?.isSold == true {
                DispatchQueue.main.async {
                    self?.view.isUserInteractionEnabled = true
                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                    self?.simpleAlert(nil, message: "この商品はすでに購入されています", cancelTitle: "OK", completion: nil)
                }
                return
            }

            if Me.sharedMe.isMine(merchandiseInfo?.user?.identifier ?? "") == true {
                DispatchQueue.main.async {
                    self?.view.isUserInteractionEnabled = true
                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                    self?.simpleAlert(nil, message: "自分が出品した商品は買うことができません", cancelTitle: "OK", completion: nil)
                }
                return
            }

            let myPoint = self?.consmePoint() ?? 0
            let mySales = self?.consmeSales() ?? 0
            let myPayment = self?.paymentAmount() ?? 0
            merchandiseInfo?.buyMerchandise(withPoint: myPoint, withSales: mySales, withPayment: myPayment) { (transaction: Transaction?, roomId: Int?, error: Error?) in
                if error != nil {
                    DispatchQueue.main.async {
                        self?.view.isUserInteractionEnabled = true
                        self?.navigationItem.leftBarButtonItem?.isEnabled = true
                        SVProgressHUD.dismiss()
                        self?.showErrorWhenPurchaseAlert(error)
                    }
                    return
                }

                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()

                    self?.purchaseThanksView?.appearOnViewController((self?.navigationController)!)
                    self?.sendPurchase(transaction: transaction)

                    self?.view.isUserInteractionEnabled = true
                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                }
            }
        }
    }

    // ================================================================================
    // MARK: - Consume Point Caluclate function
    
    //消費するPoint
    fileprivate func consmePoint() ->Int {
        let userPoint = usablePoint()
        guard userPoint > 0 else {
            return 0
        }
        let userSales = Me.sharedMe.point?.usableSales.int() ?? 0
        let price = self.merchandise?.price?.int() ?? 0

        if amount() <= price {
            if differenceAmountWithin100() && userSales == 0 {
                return price - 100
            }
            
            if differenceAmountWithin100() {
                let difPoint = difference(drawnNumber: price, drawNumber: userPoint)
                if difPoint < 100 {
                    return userPoint - (100 - difPoint)
                }
                return userPoint
            }
            return userPoint
        }
        
        if userPoint > price {
            return price
        }
        return userPoint
    }
    
    //消費する売上
    
    fileprivate func consmeSales() ->Int {
        let userSales = Me.sharedMe.point?.usableSales.int() ?? 0
        guard userSales > 0 else {
            return 0
        }
        let userPoint = self.consmePoint()
        let price = self.merchandise?.price?.int() ?? 0

        let difSales = difference(drawnNumber: price, drawNumber: userPoint)
        if differenceAmountWithin100() {
            if userSales >= difSales {
                return difSales
            }
            if userSales > userPoint {
               return price - userPoint - 100
            }
            if userSales < difSales {
                return difSales - 100
            }
            return 0
        }
     
        if difSales > 0 {
            if userSales < difSales {
               return userSales
            }
            return difSales
        }
        return 0
    }
    
    //消費するPoint合計
    fileprivate func consmeAmount() ->Int {
        return consmePoint() + consmeSales()
    }
    
    //支払うする合計
    fileprivate func paymentAmount() ->Int {
        let price = self.merchandise?.price?.int() ?? 0
        if self.amount() <= price {
            if differenceAmountWithin100() {
                return 100
            }
            return price - consmeAmount()
        }
        return 0
    }
    
    fileprivate func differenceAmountWithin100() ->Bool {
        let price = self.merchandise?.price?.int() ?? 0
        let userPrice = (price - self.amount())
        return userPrice < 100 && userPrice > 0
    }
    
    fileprivate func amount() ->Int {
        guard let points = Me.sharedMe.point else {
            return 0
        }
        return points.usableSales.int() + usablePoint()
    }

    private func difference(drawnNumber: Int, drawNumber: Int) ->Int {
        return drawnNumber - drawNumber
    }
    
    private func usablePoint() -> Int {
        if merchandise?.isBrandNew ?? false {
            return 0
        }
        return Me.sharedMe.point?.usablePoint.int() ?? 0
    }
    
    // ================================================================================
    // MARK: - send Purchase Event
    
    fileprivate func sendPurchase(transaction: Transaction?) {
        FBSDKAppEvents.logPurchase(self.merchandise?.price?.int().double() ?? 0,
                                   currency: self.book?.categoryName ?? "カテゴリなし")
        
        let parameter: [String: AnyObject] = ["merchandise_price": self.merchandise?.price as AnyObject ,
                                              "book_category" : self.book?.categoryName as AnyObject ,
                                              "item_transaction_id": transaction?.id as AnyObject,
                                              "bonus": self.consmePoint() as AnyObject,
                                              "sales": self.consmeSales() as AnyObject,
                                              "credit": self.paymentAmount() as AnyObject]
        
        AnaliticsManager.sendAction("purchase",
                                    actionName: "bought_merchandise",
                                    label: self.merchandise?.price ?? "",
                                    value: 1,
                                    dic: parameter)
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
        switch sections[(indexPath as IndexPath).section].rowItems[(indexPath as IndexPath).row] {
        case .purchaseInfoTitle, .shippingAdressInfoTitle, .merchandiseInfoTitle:
            return BaseTitleCell.cellHeightForObject(nil)
        case .merchandiseInfoBookDetail:
            return ShippingProgressBookDetailCell.cellHeightForObject(book)
        case .merchandiseInfoSeller:
            return PurchaseUserCell.cellHeightForObject(merchandise)
        case .purchaseInfoPaymentWay:
            return PurchaseInfoPaymentWayCell.cellHeightForObject(Me.sharedMe.defaultCards)
        case .shippingAdressInfoDetail:
            return AddressAndNameCell.cellHeightForObject(Me.sharedMe.defaultAdress)
        case .purchaseButton:
            return ProfileSettingSaveButtonCell.cellHeightForObject(nil)
        case .purchaseInfoPaymentAmount:
            return 73.0
        default:
            return 50.0
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch sections[(indexPath as IndexPath).section].rowItems[(indexPath as IndexPath).row] {
            
        case .merchandiseInfoTitle:
            cellIdentifier = "MerchandiseInfoTitle"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? BaseTitleCell)?.title = "商品の情報"
            break
        case .merchandiseInfoBookDetail:
            cellIdentifier = NSStringFromClass(ShippingProgressBookDetailCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ShippingProgressBookDetailCell
            if cell == nil {
                cell = ShippingProgressBookDetailCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? ShippingProgressBookDetailCell)?.cellModelObject = book
            break
        case .merchandiseInfoSeller:
            cellIdentifier = "MerchandiseInfoSeller"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?PurchaseUserCell
            if cell == nil {
                cell = PurchaseUserCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? PurchaseUserCell)?.cellModelObject = merchandise
            break
        case .purchaseInfoTitle:
            cellIdentifier = "UserInfoTitle"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? BaseTitleCell)?.title = "お支払い情報"
            break
        case .purchaseInfoPaymentWay:
            cellIdentifier = "PurchaseInfoPaymentWay"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?PurchaseInfoPaymentWayCell
            if cell == nil {
                cell = PurchaseInfoPaymentWayCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }

            (cell as? PurchaseInfoPaymentWayCell)?.cellModelObject = Me.sharedMe.defaultCards
            
            break
        case .purchaseInfoMerchandisePrice:
            cellIdentifier = NSStringFromClass(PurchasePaymentPriceCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?PurchasePaymentPriceCell
            if cell == nil {
                cell = PurchasePaymentPriceCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! PurchasePaymentPriceCell).textFieldText = "¥\(merchandise!.price!.int().thousandsSeparator())"
            break
        case .purchaseUsablePoint:
           
            cellIdentifier = "PurchaseUsablePoint"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "ポイントを使用"
            (cell as! BaseTextFieldCell).textFieldText = "\(self.consmePoint().thousandsSeparator())pt"
            (cell as! BaseTextFieldCell).textField?.textColor = kBlackColor87
            (cell as! BaseTextFieldCell).textField!.font = UIFont.boldSystemFont(ofSize: 18)
            (cell as! BaseTextFieldCell).textField!.isUserInteractionEnabled = false
            (cell as! BaseTextFieldCell).isShortBottomLine = true
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            break
        case .purchaseUsableSales:
            
            cellIdentifier = "PurchaseUsableSales"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "売上金で支払う"
            (cell as! BaseTextFieldCell).textFieldText = "¥\(self.consmeSales().thousandsSeparator())"
            (cell as! BaseTextFieldCell).textField?.textColor = kBlackColor87
            (cell as! BaseTextFieldCell).textField!.font = UIFont.boldSystemFont(ofSize: 18)
            (cell as! BaseTextFieldCell).textField!.isUserInteractionEnabled = false
            (cell as! BaseTextFieldCell).isShortBottomLine = true
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textField?.textAlignment = .right
            
            break
        case .purchaseInfoPaymentAmount:
            cellIdentifier = "PurchaseInfoPaymentAmount"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldCell).titleText = "お支払い金額"
            (cell as! BaseTextFieldCell).textFieldText = "¥\(self.paymentAmount().thousandsSeparator())"
            (cell as! BaseTextFieldCell).textField?.textColor = kBlackColor87
            (cell as! BaseTextFieldCell).textField!.font = UIFont.boldSystemFont(ofSize: 18)
            (cell as! BaseTextFieldCell).textField!.isUserInteractionEnabled = false
            (cell as! BaseTextFieldCell).isShortBottomLine = false
            (cell as! BaseTextFieldCell).selectionStyle = .none
            (cell as! BaseTextFieldCell).textField?.textAlignment = .right

            
            break
        case .purchaseInfoNote:
            cellIdentifier = NSStringFromClass(PurchaseInfoNoteCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?PurchaseInfoNoteCell
            if cell == nil {
                cell = PurchaseInfoNoteCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            break
        case .shippingAdressInfoTitle:
            cellIdentifier = "ShippingAdressInfoTitle"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? BaseTitleCell)?.title = "お届け先情報"
            
            break
        case .shippingAdressInfoDetail:
            cell = tableView.dequeueReusableCell(withIdentifier: AddressAndNameCell.reuseID) as? AddressAndNameCell
            cell?.cellModelObject = Me.sharedMe.defaultAdress
            break
        case .purchaseButton:
            cellIdentifier = NSStringFromClass(ProfileSettingSaveButtonCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ProfileSettingSaveButtonCell
            if cell == nil {
                cell = ProfileSettingSaveButtonCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            
            (cell as! ProfileSettingSaveButtonCell).saveButton.setTitle("購入する", for: .normal)
            (cell as! ProfileSettingSaveButtonCell).saveButton.setBackgroundImage(UIImage(named: "img_stretch_btn_red")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
            
            break
        }
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        switch sections[(indexPath as IndexPath).section].rowItems[(indexPath as IndexPath).row] {
        case .merchandiseInfoSeller:
            let controller: UserPageViewController = UserPageViewController(user: merchandise?.user)
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case .purchaseInfoPaymentWay:
            let controller: CreditCardInfoViewController = CreditCardInfoViewController()
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case .shippingAdressInfoDetail:
            let controller: AdressInfoViewController = AdressInfoViewController()
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
            break
        default:
            break
        }
    }
}
