//
//  ShippingProgressTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert
import LINEActivity
import SwiftTips

open class ShippingProgressTableViewController: BaseTableViewController,
    ShippingProgressBarCellDelegate,
    ShippingProgressReviewCellDelegate,
    ShippingProgressCancelCellDelegate,
    TransactionThanksViewProtocol {
    var transaction: Transaction?
    fileprivate var tmpReview: Review? = Review()
    fileprivate var finishShippingView: BaseThanksView?
    fileprivate var finishBuyerReviewView: TransactionThanksView?
    fileprivate var finishSellerReviewView: TransactionThanksView?
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate var sections = [Section]()
    
    fileprivate enum ShippingProgressTableViewSectionType: Int {
        case shippingProgress
        case review
        case transactionContents
        case shippingAdress
        case exhibitor
        case help
    }
    
    fileprivate enum ShippingProgressTableViewRowType {
        case shippingProgressCancel
        case shippingProgressTitle
        case shippingProgressDetail
        case reviewTitle
        case reviewDetail
        case transactionContentsTitle
        case transactionContentsBookInfo
        case transactionContentsPrice
        case transactionContentsBoughtDate
        case transactionContentsShippingDate
        case transactionContentsContactID
        case shippingAdressTitle
        case shippingAdressDetail
        case exhibitorUser
        case exhibitorChat
        case helpTitle
        case howToPacking
        case helpInTransaction
    }

    private let howToPackingTitle: String = "梱包の方法は？"
    private let howToPackingIconName: String = "ic_to"
    private let howToPackingUrlString: String = "http://static.bukuma.io/bkm_app/guide/sell.html#section02-02"

    private let helpInTransactionTitle: String = "取引で困った時"
    private let helpInTransactionIconName: String = "ic_to"
    private let helpInTransactionUrlString: String = "http://static.bukuma.io/bkm_app/faq.html#section2"
    
    fileprivate struct Section {
        var sectionType: ShippingProgressTableViewSectionType
        var rowItems: [ShippingProgressTableViewRowType]
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
        guard let targetTransaction = self.transaction else { return }

        if targetTransaction.type == .initial {
            sections = [Section(sectionType: .shippingProgress,
                                rowItems: [.shippingProgressDetail]),
                        Section(sectionType: .transactionContents,
                                rowItems: [.transactionContentsTitle, .transactionContentsPrice,
                                           .transactionContentsBoughtDate, .transactionContentsShippingDate, .transactionContentsContactID])]
            return
        }

        if targetTransaction.shouldShowCancelFlow() == true {
            sections = [Section(sectionType: .shippingProgress,
                                rowItems: [.shippingProgressCancel,.shippingProgressTitle, .shippingProgressDetail, .exhibitorUser, .exhibitorChat]),
                        Section(sectionType: .transactionContents,
                                rowItems: [.transactionContentsTitle, .transactionContentsBookInfo, .transactionContentsPrice,
                                           .transactionContentsBoughtDate, .transactionContentsShippingDate, .transactionContentsContactID]),
                        Section(sectionType: .shippingAdress,
                                rowItems: [.shippingAdressTitle, .shippingAdressDetail]),
                        Section(sectionType: .help,
                                rowItems: [.helpTitle, .howToPacking, .helpInTransaction])]

            return
        }

        if targetTransaction.daysSinceFinished >= self.nomorePrivatesDays ||
            targetTransaction.type == .cancelled {
            sections = [Section(sectionType: .shippingProgress,
                                rowItems: [ .shippingProgressDetail, .exhibitorUser, .exhibitorChat]),
                        Section(sectionType: .transactionContents,
                                rowItems: [.transactionContentsTitle, .transactionContentsBookInfo, .transactionContentsPrice,
                                           .transactionContentsBoughtDate, .transactionContentsShippingDate, .transactionContentsContactID]),
                        Section(sectionType: .help,
                                rowItems: [.helpTitle, .howToPacking, .helpInTransaction])]
            return
        }

        sections = [Section(sectionType: .shippingProgress,
                            rowItems: [ .shippingProgressDetail, .exhibitorUser, .exhibitorChat]),
                    Section(sectionType: .transactionContents,
                            rowItems: [.transactionContentsTitle, .transactionContentsBookInfo, .transactionContentsPrice,
                                       .transactionContentsBoughtDate, .transactionContentsShippingDate, .transactionContentsContactID]),
                    Section(sectionType: .shippingAdress,
                            rowItems: [.shippingAdressTitle, .shippingAdressDetail]),
                    Section(sectionType: .help,
                            rowItems: [.helpTitle, .howToPacking, .helpInTransaction])]
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "取引画面"
    }
    
    func updateTableViewStruct(_ transaction: Transaction?) {
        guard let targetTransaction = self.transaction else { return }

        if (targetTransaction.isBuyer() == true && targetTransaction.type == .sellerShipped) ||
            (targetTransaction.isBuyer() == false && targetTransaction.type == .buyerItemArried) {
            if targetTransaction.shouldShowCancelFlow() == true {
                self.sections = [Section(sectionType: .shippingProgress,
                                         rowItems: [.shippingProgressCancel,.shippingProgressTitle, .shippingProgressDetail, .exhibitorUser, .exhibitorChat]),
                                 Section(sectionType: .review,
                                         rowItems: [.reviewTitle, .reviewDetail]),
                                 Section(sectionType: .transactionContents,
                                         rowItems: [.transactionContentsTitle, .transactionContentsBookInfo, .transactionContentsPrice,
                                                    .transactionContentsBoughtDate, .transactionContentsShippingDate, .transactionContentsContactID]),
                                 Section(sectionType: .shippingAdress,
                                         rowItems: [.shippingAdressTitle, .shippingAdressDetail]),
                                 Section(sectionType: .help,
                                         rowItems: [.helpTitle, .howToPacking, .helpInTransaction])]
                return
            }

            self.sections = [Section(sectionType: .shippingProgress,
                                     rowItems: [ .shippingProgressDetail, .exhibitorUser, .exhibitorChat]),
                             Section(sectionType: .review,
                                     rowItems: [.reviewTitle, .reviewDetail]),
                             Section(sectionType: .transactionContents,
                                     rowItems: [.transactionContentsTitle, .transactionContentsBookInfo, .transactionContentsPrice,
                                                .transactionContentsBoughtDate, .transactionContentsShippingDate, .transactionContentsContactID]),
                             Section(sectionType: .shippingAdress,
                                     rowItems: [.shippingAdressTitle, .shippingAdressDetail]),
                             Section(sectionType: .help,
                                     rowItems: [.helpTitle, .howToPacking, .helpInTransaction])]
        }
    }
    
    // ================================================================================
    // MARK: init
    
    deinit {
        DBLog("----------------------ShippingProgressTableViewController deinit ---------------------")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(transaction: Transaction) {
        super.init(nibName: nil, bundle: nil)
        self.transaction = transaction
        if tmpReview?.type == nil {
            tmpReview?.type = .good
        }
    }
    
    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "取引画面"

        let reviewCellNib = UINib(nibName: ShippingProgressReviewCell.nibName, bundle: nil)
        self.tableView?.register(reviewCellNib, forCellReuseIdentifier: ShippingProgressReviewCell.reuseID)
        let addressCellNib = UINib(nibName: AddressAndNameCell.nibName, bundle: nil)
        self.tableView?.register(addressCellNib, forCellReuseIdentifier: AddressAndNameCell.reuseID)
        let priceCellNib = UINib(nibName: ShippingProgressPriceCell.nibName, bundle: nil)
        self.tableView?.register(priceCellNib, forCellReuseIdentifier: ShippingProgressPriceCell.reuseID)
        let boughtDateCellNib = UINib(nibName: ShippingProgressBoughtDateCell.nibName, bundle: nil)
        self.tableView?.register(boughtDateCellNib, forCellReuseIdentifier: ShippingProgressBoughtDateCell.reuseID)
        let shippingDateCellNib = UINib(nibName: ShippingProgressShippingDateCell.nibName, bundle: nil)
        self.tableView?.register(shippingDateCellNib, forCellReuseIdentifier: ShippingProgressShippingDateCell.reuseID)
        let contactIdCellNib = UINib(nibName: ShippingProgressContactIdCell.nibName, bundle: nil)
        self.tableView?.register(contactIdCellNib, forCellReuseIdentifier: ShippingProgressContactIdCell.reuseID)
        let bookInfoCellNib = UINib(nibName: ShippingProgressBookInfoCell.nibName, bundle: nil)
        self.tableView?.register(bookInfoCellNib, forCellReuseIdentifier: ShippingProgressBookInfoCell.reuseID)
        let titleWithImageCellNib = UINib(nibName: LabelAndImageCell.nibName, bundle: nil)
        self.tableView?.register(titleWithImageCellNib, forCellReuseIdentifier: LabelAndImageCell.reuseID)
        
        tableView!.showsPullToRefresh = false
        tableView!.isFixTableScrollWhenChangeContentsSize = true
        
        isNeedKeyboardNotification = true
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapView(_:)))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        finishShippingView = BaseThanksView(delegate: self,
                                            image: UIImage(named: "img_cover_after_shipping")!,
                                            title: "発送手続きが完了しました",
                                            detail: "取引相手に商品を発送したことを知らせました\n取引相手があなたを評価するのをお待ち下さい",
                                            buttonText: "OK")

        finishBuyerReviewView = TransactionThanksView(delegate: self,
                                                      image: UIImage(named: "img_cover_after_reviewing")!,
                                                      title: "取引相手を評価しました",
                                                      detail: "取引終了までお待ちください",
                                                      buttonText: "ホームに戻る")

        finishSellerReviewView = TransactionThanksView(delegate: self,
                                                       image: UIImage(named: "img_cover_after_purchase")!,
                                                       title: "レビューを送信しました",
                                                       detail: "取引終了です！お疲れさまでした！",
                                                       buttonText: "ホームに戻る")

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshDataSource), name: NSNotification.Name(rawValue: TransactionRefreshKey), object: nil)

        self.tableView?.register(UINib(nibName: ExhibitCommissionAndBenefitsCell.nibName, bundle: nil),
                                 forCellReuseIdentifier: ExhibitCommissionAndBenefitsCell.reuseID)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.refreshDataSource()
    }
    
    override func popViewController() {
        _ = self.navigationController.map { (navi)  in
            for controller in navi.viewControllers {
                if controller is PurchaseViewController {
                    navi.popToRootViewController(animated: true)
                    return
                }
            }
            navi.popViewController(animated: true)
        }
    }
    
    override open func refreshDataSource() {
        super.refreshDataSource()
        
        self.transaction?.getItemTransactionInfo({[weak self] (error) in
            DispatchQueue.main.async {
                self?.updateTableViewStruct(self?.transaction)
                self?.tableView?.reloadData()
            }
        })
    }
    
    // ================================================================================
    // MARK: - gesture delegate
    
    func tapView(_ sender: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if touch.view is UITextView || touch.view is UITextField || touch.view is UIButton {
            return false
        }
        if self.isEditing == true {
            return false
        }
        
        return true
    }

    // ================================================================================
    // MARK: - shippingProgressBarCellDelegate
    
    public func shippingProgressBarButtonTapped(_ cell: ShippingProgressBarCell, completion:@escaping () ->Void) {
        if transaction == nil {
            return
        }
        
        if transaction?.isBuyer() == false && transaction!.type == .sellerPrepareShipping {
            RMUniversalAlert.show(in: self,
                                  withTitle: "",
                                  message: "発送完了したことを購入者に通知しますか?",
                                  cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: ["通知する"],
                                  tap: {[weak self] (al, index) in

                                    DispatchQueue.main.async {
                                        if index == al.firstOtherButtonIndex {
                                            self?.transaction?.sellerShipped({(error) in
                                                DispatchQueue.main.async {
                                                    if error != nil {
                                                        self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)

                                                        completion()
                                                        return
                                                    }
                                                    self?.tableView?.reloadData()
                                                    SVProgressHUD.dismiss()
                                                    if let weakS = self {

                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute:{
                                                            weakS.finishShippingView?.appearOnViewController(weakS.navigationController ?? weakS)
                                                        })
                                                        self?.transaction?.getItemTransactionInfo({ (error) in
                                                            self?.enterChatRoom(withUser: self?.transaction?.oppositeUser() ?? User(),
                                                                                transaction: self?.transaction ?? Transaction(),
                                                                                isCancel: false,
                                                                                isSendMension: true,
                                                                                completion: nil)
                                                        })
                                                    }

                                                    completion()

                                                }
                                            })
                                        }else {
                                            completion()
                                        }
                                    }
            })
        }
    }

    // ================================================================================
    // MARK: - shippingProgressReviewCellDelegate

    open func shippingProgressReviewCellDidBeginEditing(_ textView: UITextView) {
        let indexpath: IndexPath =  IndexPath(row: 1, section: 1)
        let rectOfCellInSuperview: CGRect = self.tableView!.convert(self.tableView!.bounds, to: self.tableView!.cellForRow(at: indexpath))
        self.moveContentOffsetWithTargetCellRect(rectOfCellInSuperview, index: 1)
    }

    override func additionalMoveFloat() ->CGFloat {
        return 0
    }
    
    open func shippingProgressReviewCellTextViewDidChange(_ text: String) {
        tmpReview?.comment = text
    }
    
    open func shippingProgressReviewCellReviewButtonTapped(_ reviewTag: Int, completion: ()-> Void) {
        let reviewType = ReviewType(rawValue: reviewTag)
        if reviewType != self.tmpReview?.type {
            self.tmpReview?.type = reviewType

            self.tableView?.reloadData()
        }

        completion()
    }
    
    func shippingProgressReviewCellSendButtonTapped(_ cell: ShippingProgressReviewCell, completion: @escaping () ->Void) {
    
        if tmpReview?.type == nil {
            self.simpleAlert(nil, message: "評価を選択してください", cancelTitle: "OK", completion: completion)
            return
        }
       
        if Utility.isEmpty(tmpReview?.comment) {
            self.simpleAlert(nil, message: "コメントを入力して下さい", cancelTitle: "OK", completion: completion)
            return
        }
        
        cell.dismissKeyBoard()
        
        if transaction?.oppositeUser() == nil || transaction?.oppositeUser()?.identifier == nil {
            self.showAlredyUserDeletedAlert()
            completion()
            return
        }
        
        if transaction?.isBuyer() == true {
            self.showArrivedAlret {[weak self] (willReview) in
    
                DispatchQueue.main.async {
                    if willReview == true {
                        self?.view.isUserInteractionEnabled = false
                        SVProgressHUD.show()
                        self?.transaction?.buyerBookArrived(self!.tmpReview!, completion: { (error) in
                            DispatchQueue.main.async {
                                self?.view.isUserInteractionEnabled = true
                                if error != nil {
                                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                                    completion()
                                    return
                                }
                                completion()
                                SVProgressHUD.dismiss()
                                if let weakS = self {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                                         weakS.finishBuyerReviewView?.appearOnViewController(weakS.navigationController ?? weakS)
                                    })
                                    self?.transaction?.getItemTransactionInfo({ (error) in
                                        self?.enterChatRoom(withUser: self?.transaction?.oppositeUser() ?? User(),
                                                            transaction: self?.transaction ?? Transaction(),
                                                            isCancel: false,
                                                            isSendMension: true,
                                                            completion: nil)
                                    })
                                }
                            }
                        })
                        return
                    }
                    completion()
                }
            }
            return
        }
        
        self.showShippedAlret {[weak self] (willReview) in
            DispatchQueue.main.async  {
                if willReview == true {
                    self?.view.isUserInteractionEnabled = false
                    SVProgressHUD.show()
                    self?.transaction?.sellerReviewsBuyer(self!.tmpReview!, completion: { (error) in
                        DispatchQueue.main.async  {
                            self?.view.isUserInteractionEnabled = true
                            if error != nil {
                                self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                                completion()
                                return
                            }
                            
                            completion()
                            SVProgressHUD.dismiss()
                            
                            if let weakS = self {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                                    weakS.finishSellerReviewView?.appearOnViewController(weakS.navigationController ?? weakS)
                                })
                                
                                self?.transaction?.getItemTransactionInfo({ (error) in
                                    self?.enterChatRoom(withUser: self?.transaction?.oppositeUser() ?? User(),
                                                        transaction: self?.transaction ?? Transaction(),
                                                        isCancel: false,
                                                        isSendMension: true,
                                                        completion: nil)
                                })
                            }
                        }
                    })
                    return
                }
                completion()
            }
        }
    }

    public func shippingProgressReviewCellInquireToSupportButtonTapped(_ completion: @escaping ()-> Void) {
        let viewController = ContactViewController(type: .none, object: nil)
        let navigationController = NavigationController.init(rootViewController: viewController)
        self.present(navigationController, animated: true, completion: nil)
        completion()
    }
    
    fileprivate func showArrivedAlret(_ completion: @escaping (_ willReview: Bool) ->Void) {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "レビューを送って、出品者に商品を受け取ったことを通知しますか？",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["レビューを送信"]) {(al, index) in

                                DispatchQueue.main.async {
                                    if index != al.cancelButtonIndex {
                                        completion(true)
                                        return
                                    }
                                    completion(false)
                                }
        }
    }

    fileprivate func showShippedAlret(_ completion: @escaping (_ willReview: Bool) ->Void) {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "レビューを送って、購入者を評価しますか？",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["レビューを送信"]) {(al, index) in
                                DispatchQueue.main.async {
                                    if index != al.cancelButtonIndex {
                                        completion(true)
                                        return
                                    }
                                    completion(false)
                                }
        }
    }

    // ================================================================================
    // MARK: - TransactionThanksViewProtocol

    open override func baseSuggestViewCancelButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {

    }

    open override func baseSuggestViewActionButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {

        // Chatへ画面遷移して吐き出す　messageを吐き出してから、遷移しよう
        for controller in self.navigationController!.viewControllers {
            if controller is BoughtBookListViewController {
             _ =  self.navigationController?.popToViewController(controller, animated: true)
                return
            }
            if controller is ExhibitingBookListViewController {
             _ =  self.navigationController?.popToRootViewController(animated: true)
                return
            }
        }
     _ =  self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    func tappedIntroduceBukumaButton(_ view: TransactionThanksView, completion: (()-> Void)?) {
        // InvitationUserViewController#recommentdApp コピペ（「ブクマ！に友達を招待」→「ともだちにシェアする」）
        let activityItems: [String] = ["ブクマ!の招待コード[\(Me.sharedMe.invitationCode ?? "")]\n入力で、今なら\(ExternalServiceManager.invitationPoint)ポイントプレゼント!!\nブクマ！なら中古本を10秒で出品できるよ！\n#ブクマ！" + kShareLink]
        let applicationActivities: [UIActivity] = [LINEActivity()]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        self.present(activityViewController, animated: true, completion: nil)
    }

    // ================================================================================
    // MARK: - ShippingProgressCancelCellDelegate
    
    open func shippingProgressCancelCellCancelButtonTapped(_ cell: ShippingProgressCancelCell) {
        RMUniversalAlert.show(in: self,
                              withTitle: "本当にキャンセルしますか?",
                              message: nil,
                              cancelButtonTitle: "キャンセルしない",
                              destructiveButtonTitle: "キャンセルする",
                              otherButtonTitles: ["運営に問い合わせる"]) {[weak self] (al, index) in
                                DispatchQueue.main.async {
                                    if index == al.cancelButtonIndex {

                                    } else if index == al.destructiveButtonIndex {
                                        self?.view.isUserInteractionEnabled = false

                                        self?.transaction?.cancel() { (error) in
                                            DispatchQueue.main.async {
                                                self?.view.isUserInteractionEnabled = true
                                                if error != nil {
                                                    self?.simpleAlert(error?.errorDespription,
                                                                      message: nil,
                                                                      cancelTitle: "OK",
                                                                      completion: nil)
                                                    return
                                                }
                                                self?.simpleAlert("キャンセルしました",
                                                                  message: nil,
                                                                  cancelTitle: "OK")  {
                                                                    DispatchQueue.main.async {
                                                                        self?.popViewController()

                                                                        self?.enterChatRoom(withUser: self?.transaction?.oppositeUser() ?? User(),
                                                                                            transaction: self?.transaction ?? Transaction(),
                                                                                            isCancel: true,
                                                                                            isSendMension: true,
                                                                                            completion: nil)
                                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        let controller: ContactViewController = ContactViewController(type: ReportType.itemTransactionCancel, object: self?.transaction)
                                        controller.view.clipsToBounds = true
                                        self?.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
        }
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
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .shippingProgressCancel:
            return ShippingProgressCancelCell.cellHeightForObject(nil)
        case .shippingProgressTitle, .transactionContentsTitle, .shippingAdressTitle, .reviewTitle, .helpTitle:
            return BaseTitleCell.cellHeightForObject(nil)
        case .shippingProgressDetail:
            return ShippingProgressBarCell.cellHeightForObject(transaction)
        case .transactionContentsBookInfo:
            return ShippingProgressBookInfoCell.cellHeightForObject(self.transaction)
        case .transactionContentsPrice:
            return ShippingProgressPriceCell.cellHeightForObject(self.transaction)
        case .transactionContentsBoughtDate:
            return ShippingProgressBoughtDateCell.cellHeightForObject(nil)
        case .transactionContentsShippingDate:
            return ShippingProgressShippingDateCell.cellHeightForObject(nil)
        case .transactionContentsContactID:
            return ShippingProgressContactIdCell.cellHeightForObject(nil)
        case .howToPacking, .helpInTransaction:
            return LabelAndImageCell.cellHeightForObject(nil)
        case .shippingAdressDetail:
            return AddressAndNameCell.cellHeightForObject(self.transaction?.buyerAdress)
        case .exhibitorUser:
            return ShippingProgressUserCell.cellHeightForObject(nil)
        case .exhibitorChat:
            return ShippingProgressChatCell.cellHeightForObject(nil)
        case .reviewDetail:
            return ShippingProgressReviewCell.cellHeightForObject(nil)
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
         case .shippingProgressCancel:
            cellIdentifier = NSStringFromClass(ShippingProgressCancelCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ShippingProgressCancelCell
            if cell == nil {
                cell = ShippingProgressCancelCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }

            break
        case .shippingProgressTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "取引の進捗"
            break
        case .shippingProgressDetail:
            cellIdentifier = NSStringFromClass(ShippingProgressBarCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ShippingProgressBarCell
            if cell == nil {
                cell = ShippingProgressBarCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? ShippingProgressBarCell)?.cellModelObject = transaction
            break
            
        case .reviewTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "取引の評価"
            break
        case .reviewDetail:
            cell = tableView.dequeueReusableCell(withIdentifier: ShippingProgressReviewCell.reuseID) as? ShippingProgressReviewCell
            cell?.delegate = self
            cell?.cellModelObject = self.transaction
            self.tmpReview?.comment = (cell as! ShippingProgressReviewCell).reviewCommentView.text
            break

        case .transactionContentsTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "取引の内容"
            break
        case .transactionContentsBookInfo:
            cell = tableView.dequeueReusableCell(withIdentifier: ShippingProgressBookInfoCell.reuseID) as? ShippingProgressBookInfoCell
            cell?.cellModelObject = self.transaction
            cell?.isShortBottomLine = true
            break
        case .transactionContentsPrice:
            cell = tableView.dequeueReusableCell(withIdentifier: ShippingProgressPriceCell.reuseID) as? ShippingProgressPriceCell
            cell?.cellModelObject = self.transaction
            cell?.isShortBottomLine = true
            cell?.selectionStyle = .none
            break
        case .transactionContentsBoughtDate:
            cell = tableView.dequeueReusableCell(withIdentifier: ShippingProgressBoughtDateCell.reuseID) as? ShippingProgressBoughtDateCell
            cell?.cellModelObject = self.transaction
            cell?.isShortBottomLine = true
            cell?.selectionStyle = .none
            break
        case .transactionContentsShippingDate:
            cell = tableView.dequeueReusableCell(withIdentifier: ShippingProgressShippingDateCell.reuseID) as? ShippingProgressShippingDateCell
            cell?.cellModelObject = self.transaction
            cell?.isShortBottomLine = true
            cell?.selectionStyle = .none
            break
        case .transactionContentsContactID:
            cell = tableView.dequeueReusableCell(withIdentifier: ShippingProgressContactIdCell.reuseID) as? ShippingProgressContactIdCell
            cell?.cellModelObject = self.transaction
            break

        case .shippingAdressTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "お届け先情報"
            break
        case .shippingAdressDetail:
            cell = tableView.dequeueReusableCell(withIdentifier: AddressAndNameCell.reuseID) as? AddressAndNameCell
            cell?.delegate = self
            cell?.cellModelObject = self.transaction?.buyerAdress
            break

        case .exhibitorUser:
            cellIdentifier = NSStringFromClass(ShippingProgressUserCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ShippingProgressUserCell
            if cell == nil {
                cell = ShippingProgressUserCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? ShippingProgressUserCell)?.cellModelObject = transaction?.oppositeUser()
            break
        case .exhibitorChat:
            cellIdentifier = NSStringFromClass(ShippingProgressChatCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ShippingProgressChatCell
            if cell == nil {
                cell = ShippingProgressChatCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? ShippingProgressChatCell)?.cellModelObject = transaction
            break

        case .helpTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTitleCell).title = "ヘルプ"
            break
        case .howToPacking:
            cell = tableView.dequeueReusableCell(withIdentifier: LabelAndImageCell.reuseID) as? LabelAndImageCell
            cell?.cellModelObject = (self.howToPackingTitle, self.howToPackingIconName) as AnyObject
            break
        case .helpInTransaction:
            cell = tableView.dequeueReusableCell(withIdentifier: LabelAndImageCell.reuseID) as? LabelAndImageCell
            cell?.cellModelObject = (self.helpInTransactionTitle, self.helpInTransactionIconName) as AnyObject
            break
        }
        
        return cell!
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        var controller: UIViewController?
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .exhibitorChat:
            if transaction!.oppositeUser() == nil || transaction!.oppositeUser()?.identifier == nil {
                return
            }
            
            self.enterChatRoom(withUser: transaction?.oppositeUser() ?? User(), transaction: transaction, isCancel: false, isSendMension: false, completion: nil)
           
            break
        case .exhibitorUser:
            controller = UserPageViewController(user: transaction?.oppositeUser())
            break

        case .transactionContentsBookInfo:
            self.view.isUserInteractionEnabled = false
            SVProgressHUD.show()

            DetailPageTableViewController.generate(for: self.transaction?.book) { [weak self] (generatedViewController: DetailPageTableViewController?) in
                guard let viewController = generatedViewController else {
                    SVProgressHUD.dismiss()
                    self?.view.isUserInteractionEnabled = true
                    return
                }
                self?.navigationController?.pushViewController(viewController, animated: true)

                SVProgressHUD.dismiss()
                self?.view.isUserInteractionEnabled = true
            }
            break
        case .transactionContentsContactID:
            let cell = tableView.cellForRow(at: indexPath) as? ShippingProgressContactIdCell
            DBLog(cell)
            self.copyContactId(cell)
            break

        case .shippingAdressDetail:
            if let cell = tableView.cellForRow(at: indexPath) as? AddressAndNameCell {
                let pastableText = cell.pastableText()

                UIPasteboard.general.setValue(pastableText, forPasteboardType: "public.utf8-plain-text")
                self.simpleAlert(nil, message: "コピーしました", cancelTitle: "OK", completion: nil)
            }
            break

        case .howToPacking:
            controller = self.makeWebViewController(withUrl: self.howToPackingUrlString)
            break
        case .helpInTransaction:
            controller = self.makeWebViewController(withUrl: self.helpInTransactionUrlString)
            break

        default:
            break
        }
        
        if controller != nil {
            controller!.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller!, animated: true)
        }
    }

    private func makeWebViewController(withUrl urlString: String)-> BaseWebViewController? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        let webViewController = BaseWebViewController(url: url)
        webViewController.view.backgroundColor = kBackGroundColor
        webViewController.webView?.backgroundColor = kBackGroundColor
        return webViewController
    }
    
    func copyContactId(_ cell: ShippingProgressContactIdCell?) {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "このお問い合わせIDで運営に問題を報告しますか",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["報告","コピー"]) {[weak self] (al, index) in
                                DispatchQueue.main.async  {

                                    if index == al.firstOtherButtonIndex {
                                        let controller: ContactViewController =  ContactViewController(type: .itemTransaction, object: self?.transaction ?? Transaction())
                                        controller.view.clipsToBounds = true
                                        self?.navigationController?.pushViewController(controller, animated: true)
                                    } else if index == al.cancelButtonIndex {

                                    } else {
                                        let pb: UIPasteboard? = UIPasteboard.general
                                        _ = cell.map({ (cell) in
                                            pb?.setValue(cell.contents.text ?? "", forPasteboardType: "public.utf8-plain-text")
                                            self?.simpleAlert(nil, message: "コピーしました", cancelTitle: "OK", completion: nil)
                                        })
                                    }
                                }
        }
    }

    override func showBlockUserAlert() {
        SVProgressHUD.dismiss()
        RMUniversalAlert.show(in: self,
                              withTitle: "ブロックユーザーとメッセージすることはできません",
                              message: "購入後の取引についてのメッセージの場合運営にお問い合わせください", cancelButtonTitle: "OK",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["お問い合わせ"]) {[weak self] (al, index) in
                                DispatchQueue.main.async  {
                                    if index == al.firstOtherButtonIndex {
                                        let controller: ContactViewController = ContactViewController(type: .itemTransaction, object: self!.transaction)
                                        controller.view.clipsToBounds = true
                                        self?.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
        }
    }

    fileprivate func showAlredyUserDeletedAlert() {
        RMUniversalAlert.show(in: self,
                              withTitle: "ユーザーがいません",
                              message: "すでに退会したユーザーです。取引が終了する前に退会してしまったなど、取引に関してトラブルがあった場合お問い合わせください",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["お問い合わせ"]) { [weak self] (al, index) in
                                DispatchQueue.main.async {
                                    if index == al.firstOtherButtonIndex {
                                        let controller: ContactViewController = ContactViewController(type: .itemTransaction, object: self!.transaction)
                                        controller.view.clipsToBounds = true
                                        self?.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
        }
    }
}

extension ShippingProgressTableViewController {
    fileprivate var nomorePrivatesDays: Int { get { return 3 } }
}
