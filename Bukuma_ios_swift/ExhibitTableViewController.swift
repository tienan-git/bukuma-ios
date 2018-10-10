//
//  ExhibitTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/29.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD

let ExhibitTableViewControllerPostedMerchandiseKey: String = "ExhibitTableViewControllerPostedMerchandiseKey"

import Social

open class ExhibitTableViewController: BaseTableViewController,
ExhibitCommentCellDelegate,
BaseTextFieldDelegate,
ExhibitButtonCellDelegate,
ExhibitBulkPhotoCellDelegate,
BaseTextFieldPickerCellDelegate,
ExhibitBookStatusCellDelegate,
ExhibitHeaderTabViewDelegate,
BaseCommentCellDelegate,
ExhibitThanksViewDelegate,
SalesCommissionProtocol {
    
    var book: Book! = Book()
    var merchandise: Merchandise = Merchandise()
    fileprivate var imageTag: Int?
    var thanksView: ExhibitThanksView?
    var normalSections = [Section]()
    var seriesSections = [Section]()
    fileprivate var tabsView: ExhibitHeaderTabView?
    var isSeries: Bool = false {
        didSet {
            let transition = CATransition()
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            transition.fillMode = kCAFillModeForwards
            transition.speed = 3.0
            self.tableView?.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
            self.tableView?.beginUpdates()
            self.tableView?.reloadSections(IndexSet(integer: 0), with: isSeries == true ? UITableViewRowAnimation.none : UITableViewRowAnimation.fade)
            self.tableView?.endUpdates()
        }
    }
    var isEdit: Bool {
        return false
    }

    private var bookImageView: UIImageView = UIImageView()
    
    // ================================================================================
    // MARK: tableView struct
    
    enum ExhibitTableViewSectionType: Int {
        case bookInfo
        case help
    }
    
    enum ExhibitTableViewRowType: Int {
        case bookInfoBookDetail
        case bookInfoBulkTitle
        case bookInfoBulkPhoto
        case bookInfoPrice
        case bookInfoCommissionAndBenefits
        case bookInfoStatus
        case bookInfoShippingComment
        case bookInfoShippingFrom
        case bookInfoShippingWay
        case bookInfoShippingIn
        case bookInfoExhibitButton
        case bookInfoDeleteButton
        case bookInfoOr
        case bookInfoSeparator
        case helpTitle
        case helpPrice
        case helpConfirmFlowTransaction
        case helpCompareDeliver
    }
    
    struct Section {
        var sectionType: ExhibitTableViewSectionType
        var rowItems: [ExhibitTableViewRowType]
    }

    private let separatorHeight: CGFloat = 4.0

    // ================================================================================
    // MARK: - setting
    
    override open func footerHeight() -> CGFloat {
        return 66
    }
    
    override open func scrollIndicatorInsetBottom() -> CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    override func initializeTableViewStruct() {
        self.setUpStruct()
    }
    
    func setUpStruct() {
        if self.isInCommission() {
            normalSections = [Section(sectionType: .bookInfo,
                                      rowItems: [.bookInfoBookDetail, .bookInfoPrice, .bookInfoCommissionAndBenefits, .bookInfoSeparator,
                                                 .bookInfoStatus, .bookInfoShippingComment, .bookInfoSeparator,
                                                 .bookInfoShippingIn, .bookInfoShippingFrom, .bookInfoShippingWay,
                                                 .bookInfoExhibitButton]),
                              Section(sectionType: .help,
                                      rowItems: [.helpTitle, .helpPrice, .helpConfirmFlowTransaction, .helpCompareDeliver])]

            seriesSections = [Section(sectionType: .bookInfo,
                                      rowItems: [.bookInfoBookDetail, .bookInfoBulkTitle, .bookInfoPrice, .bookInfoCommissionAndBenefits, .bookInfoSeparator,
                                                 .bookInfoStatus, .bookInfoBulkPhoto , .bookInfoShippingComment, .bookInfoSeparator,
                                                 .bookInfoShippingIn, .bookInfoShippingFrom, .bookInfoShippingWay,
                                                 .bookInfoExhibitButton]),
                              Section(sectionType: .help,
                                      rowItems: [.helpTitle, .helpPrice, .helpConfirmFlowTransaction, .helpCompareDeliver])]
        } else {
            normalSections = [Section(sectionType: .bookInfo,
                                      rowItems: [.bookInfoBookDetail, .bookInfoPrice, .bookInfoSeparator,
                                                 .bookInfoStatus, .bookInfoShippingComment, .bookInfoSeparator,
                                                 .bookInfoShippingIn, .bookInfoShippingFrom, .bookInfoShippingWay,
                                                 .bookInfoExhibitButton]),
                              Section(sectionType: .help,
                                      rowItems: [.helpTitle, .helpPrice, .helpConfirmFlowTransaction, .helpCompareDeliver])]

            seriesSections = [Section(sectionType: .bookInfo,
                                      rowItems: [.bookInfoBookDetail, .bookInfoBulkTitle, .bookInfoPrice, .bookInfoSeparator,
                                                 .bookInfoStatus, .bookInfoBulkPhoto , .bookInfoShippingComment, .bookInfoSeparator,
                                                 .bookInfoShippingIn, .bookInfoShippingFrom, .bookInfoShippingWay,
                                                 .bookInfoExhibitButton]),
                              Section(sectionType: .help,
                                      rowItems: [.helpTitle, .helpPrice, .helpConfirmFlowTransaction, .helpCompareDeliver])]
        }
    }
    
    func section(_ isSeries: Bool) ->[Section] {
        var sections = [Section]()
        if isSeries == false {
            sections = normalSections
        } else {
            sections = seriesSections
        }
        return sections
    }

    func indexPath(withSection: ExhibitTableViewSectionType, andRow: ExhibitTableViewRowType) -> IndexPath? {
        let sections = self.section(self.isSeries)
        for (sectionIndex, section) in sections.enumerated() {
            if section.sectionType == withSection {
                for (rowIndex, row) in section.rowItems.enumerated() {
                    if row == andRow {
                        return IndexPath(row: rowIndex, section: sectionIndex)
                    }
                }
            }
        }
        return nil
    }

    func cell<CellT>(withSection: ExhibitTableViewSectionType, andRow: ExhibitTableViewRowType) -> CellT? {
        if let indexPath = self.indexPath(withSection: withSection, andRow: andRow) {
            if let cell = self.tableView?.cellForRow(at: indexPath) as? CellT {
                return cell
            }
        }
        return nil
    }

    // ================================================================================
    // MARK: init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(book: Book?) {
        super.init(nibName: nil, bundle: nil)
        self.book = book
        
        //set default Value if exsi
        merchandise.shipFrom = Me.sharedMe.defaultShipFrom
        _ = Me.sharedMe.defaultShipWay.map { merchandise.shipWay = Merchandise.shippingWays.index(of: $0) }
        _ = Me.sharedMe.defaultShipIn.map { merchandise.shipInDay = Merchandise.shippingDaysRangesLong.index(of: $0) }
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "商品を出品する"
    }
   
    // ================================================================================
    // MARK: - viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        if let imageUrl = self.book.coverImage?.url {
            self.bookImageView.downloadImageWithURL(imageUrl, placeholderImage: kPlacejolderBookImage)
        } else {
            self.bookImageView.image = kPlacejolderBookImage
        }
        
        isNeedKeyboardNotification = true
        tabsView = ExhibitHeaderTabView(delegate: self)
        tableView?.tableHeaderView = tabsView
        
        tableView?.showsPullToRefresh = false
        self.automaticallyAdjustsScrollViewInsets = false
        tableView?.isFixTableScrollWhenChangeContentsSize = true
        tableView?.contentInsetTop = self.pullToRefreshInsetTop()
        tableView?.contentOffsetY = -tableView!.contentInsetTop
        tableView?.scrollIndicatorInsets = UIEdgeInsets(top: tableView!.contentInsetTop,
                                                        left: tableView!.scrollIndicatorInsets.left,
                                                        bottom: tableView!.scrollIndicatorInsets.bottom,
                                                        right: tableView!.scrollIndicatorInsets.right)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(ExhibitTableViewController.tapView(_:)))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        thanksView = ExhibitThanksView(delegate: self,
                                       image: UIImage(named: "img_cover_after_submit")!,
                                       title: "出品が完了しました",
                                       detail: "出品した商品は「マイページ」から\nいつでも見ることができます。また出品が反映されるまで数分かかる場合がございます",
                                       buttonText: "続けて出品する")

        tableView?.register(UINib(nibName: ExhibitCommissionAndBenefitsCell.nibName, bundle: nil),
                            forCellReuseIdentifier: ExhibitCommissionAndBenefitsCell.reuseID)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
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
        if touch.view is UITableViewCell {
            if touch.view!.tag == 1 {
                return false
            }
        }
        if touch.view is UITextView || touch.view is UITextField || touch.view is UIButton {
            return false
        }
        if self.isEditing == true {
            return false
        }
        return true
    }
    
    // ================================================================================
    // MARK: - tabsView delegate
    
    open func exhibitHeaderTabViewTabisSelected(_ view: ExhibitHeaderTabView, tag: Int) {
        isSeries = Bool.init(NSNumber.init(value: tag as Int))
    }
    
    // ================================================================================
    // MARK: - textField delegate
    
    open func baseTextFieldDidBeginEditting(_ textField: UITextField) {
        var rectOfCellInSuperview: CGRect?

        if textField.tag == self.indexPath(withSection: .bookInfo, andRow: .bookInfoShippingFrom)?.row {
            if Me.sharedMe.defaultShipFrom != nil {
                return
            }
            if let cell: BaseTextFieldPickerCell = self.cell(withSection: .bookInfo, andRow: .bookInfoShippingFrom) {
                cell.textFieldText = cell.pickerContents?[0]
                merchandise.shipFrom = cell.pickerContents?[0]
                Me.sharedMe.defaultShipFrom = merchandise.shipFrom

                rectOfCellInSuperview = self.tableView?.convert((self.tableView?.bounds)!, to: cell)
            }
        } else if textField.tag == self.indexPath(withSection: .bookInfo, andRow: .bookInfoShippingWay)?.row {
            if Me.sharedMe.defaultShipWay != nil {
                return
            }
            if let cell: BaseTextFieldPickerCell = self.cell(withSection: .bookInfo, andRow: .bookInfoShippingWay) {
                cell.textFieldText = cell.pickerContents?[0]
                merchandise.shipWay = 0
                Me.sharedMe.defaultShipWay = merchandise.shipWay!.string()

                rectOfCellInSuperview = self.tableView?.convert((self.tableView?.bounds)!, to: cell)
            }
        } else if textField.tag == self.indexPath(withSection: .bookInfo, andRow: .bookInfoShippingIn)?.row {
            if Me.sharedMe.defaultShipIn != nil {
                return
            }
            if let cell: BaseTextFieldPickerCell = self.cell(withSection: .bookInfo, andRow: .bookInfoShippingIn) {
                cell.textFieldText = cell.pickerContents?[0]
                merchandise.shipInDay = 0
                Me.sharedMe.defaultShipIn = merchandise.shipInDay!.string()

                rectOfCellInSuperview = self.tableView?.convert((self.tableView?.bounds)!, to: cell)
            }
        }

        if rectOfCellInSuperview != nil {
            self.moveContentOffsetWithTargetCellRect(rectOfCellInSuperview!, index: 1)
        }
    }
    
    open func edittingText<T : SignedNumber>(_ string: String?, type: T?) {
        switch type {
        case .some(0):
            merchandise.seriesDespription = string!
            break
        case .some(1):
            if let stringValue = string {
                self.merchandise.price = stringValue

                if let cell: ExhibitCommissionAndBenefitsCell = self.cell(withSection: .bookInfo, andRow: .bookInfoCommissionAndBenefits) {
                    cell.reflect(withPrice: Int(stringValue) ?? 0)
                }
            }
            break
        default:
            break
        }
    }
    
    open func didSelectTextFieldShouldReturn() {
        self.view.endEditing(true)
    }
    
    open func baseTextFieldPickerCellEditingPicker(_ row: Int, cell: BaseTextFieldPickerCell) {
        if cell.textFieldType == self.indexPath(withSection: .bookInfo, andRow: .bookInfoShippingFrom)?.row {
            merchandise.shipFrom = Merchandise.shippingFromContents[row]
            Me.sharedMe.defaultShipFrom = merchandise.shipFrom
        }
        if cell.textFieldType == self.indexPath(withSection: .bookInfo, andRow: .bookInfoShippingWay)?.row {
            merchandise.shipWay = row
            Me.sharedMe.defaultShipWay = merchandise.shipWay!.string()
        }
        if cell.textFieldType == self.indexPath(withSection: .bookInfo, andRow: .bookInfoShippingIn)?.row {
            merchandise.shipInDay = row
            Me.sharedMe.defaultShipIn = merchandise.shipInDay!.string()
        }
    }
    
    open func baseTextFieldReturnKeyTapped(_ textField: UITextField) {}
    
    open func baseTextFieldPickerCellFinishEditPicker(_ text: String, cell: BaseTextFieldPickerCell) {
        if (cell.textFieldType == self.indexPath(withSection: .bookInfo, andRow: .bookInfoShippingFrom)?.row ||
            cell.textFieldType == self.indexPath(withSection: .bookInfo, andRow: .bookInfoShippingWay)?.row) &&
            cell.keyboardToolbarButtonText == "次へ" {
            let nextKeyBoradCellTag = cell.textFieldType! + 1
            let nextKeyBoradCellIndexPath = IndexPath(row: nextKeyBoradCellTag, section: ExhibitTableViewSectionType.bookInfo.rawValue)
            let targetCell = tableView?.cellForRow(at: nextKeyBoradCellIndexPath) as? BaseTextFieldPickerCell
            targetCell?.textField?.becomeFirstResponder()
        }
        if cell.textFieldType == self.indexPath(withSection: .bookInfo, andRow: .bookInfoShippingIn)?.row {
            cell.textField?.resignFirstResponder()
        }
    }
    
    // ================================================================================
    // MARK: - exhibitBulkPhotoCellDelegate
    
    open func exhibitBulkPhotoCellImageViewButtonTapped(_ tag: Int, cell: ExhibitBulkPhotoCell) {
        imageTag = tag
        self.showPhotoActionSheet()
    }
    
    // ================================================================================
    // MARK: - ExhibitButtonCellDelegate
    
    open func exhibitButtonTapped(_ cell: ExhibitButtonCell) {
        
        self.view.endEditing(true)
        
        if Me.sharedMe.isRegisterd == false {
            self.showUnRegisterAlert()
            return
        }
        
        if Me.sharedMe.verified == false {
            self.showUnVerifiedAlert()
            return
        }

        let emptyAleart: EmptyAleartView = EmptyAleartView()
        
        if Utility.isEmpty(merchandise.price) || merchandise.price == "¥" {
            emptyAleart.showWithText("価格を入力してください", dismissAfter: 2.50, onViewController: self)
            return
        }

        if merchandise.price!.replaceYenSign().int() < ExternalServiceManager.minPrice {
            let message = String(format: "価格は%d円以上である必要があります", ExternalServiceManager.minPrice)
            emptyAleart.showWithText(message, dismissAfter: 2.50, onViewController: self)
            return
        }
        
        if merchandise.price!.replaceYenSign().int() > ExternalServiceManager.maxPrice {
            let message = String(format: "価格は%@円以下である必要があります", ExternalServiceManager.maxPrice.toCommaString())
            emptyAleart.showWithText(message, dismissAfter: 2.50, onViewController: self)
            return
        }
        
        if Utility.isEmpty(merchandise.quality) {
            emptyAleart.showWithText("商品の状態を入力してください", dismissAfter: 2.50, onViewController: self)
            return
        }
        
        if Utility.isEmpty(merchandise.seriesDespription) && merchandise.isSeries == true {
            emptyAleart.showWithText("掲載用タイトルを入力してください", dismissAfter: 2.50, onViewController: self)
            return
        }
        
        if Utility.isEmpty(merchandise.shipFrom) {
            emptyAleart.showWithText("発送元の地域を入力してください", dismissAfter: 2.50, onViewController: self)
            return
        }
        
        if Utility.isEmpty(merchandise.shipWay) {
            emptyAleart.showWithText("発送方法を入力してください", dismissAfter: 2.50, onViewController: self)
            return
        }
        
        if Utility.isEmpty(merchandise.shipInDay) {
            emptyAleart.showWithText("発送までの日程を入力してください", dismissAfter: 2.50, onViewController: self)
            return
        }
        
        self.view.isUserInteractionEnabled = false
        self.navigationController?.navigationItem.leftBarButtonItem?.isEnabled = false
        
        
        self.setbookId()
        
        merchandise.isSeries = isSeries

        if  merchandise.isSeries == true {
            if Utility.isEmpty(merchandise.seriesDespription) == true {
                emptyAleart.showWithText("掲載用タイトルを入力してください", dismissAfter: 2.50, onViewController: self)
                return
            }
        }
        self.createMerchandise()
    }
    
    func createMerchandise() {
        SVProgressHUD.show()
        Merchandise.createMerchandise(merchandise) { (merch, error) in
            DispatchQueue.main.async(execute: {
                if error != nil {
                    self.view.isUserInteractionEnabled = true
                    self.navigationController?.navigationItem.leftBarButtonItem?.isEnabled = true
                    self.simpleAlert(nil, message: error!.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                
                SVProgressHUD.dismiss()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: ExhibitTableViewControllerPostedMerchandiseKey), object: nil, userInfo: nil)
                    self.thanksView?.appearOnViewController(self.navigationController ?? self)
                    self.view.isUserInteractionEnabled = true
                    self.navigationController?.navigationItem.leftBarButtonItem?.isEnabled = true
                })
            })
        }
    }
    
    func setbookId() {
        if !Utility.isEmpty(book.parentId) {
            merchandise.bookId = book.parentId
        } else {
            merchandise.bookId = book.identifier
        }
    }
    
    // ================================================================================
    // MARK: - shareTwitter
    
    func shareTwitter() {
        let controller: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        controller.setInitialText("ブクマ!の招待コード[\(Me.sharedMe.invitationCode ?? "")]\n入力で、今なら\(ExternalServiceManager.invitationPoint)ポイントプレゼント!!\nブクマ！なら¥\(merchandise.price?.replaceYenSign() ?? "")でこの本が買えるよ！\n#ブクマ！")

        if let bookImage = self.prepareBookImage() {
            controller.add(bookImage)
        }
        controller.add(URL(string: kAppStoreURL))
        
        controller.completionHandler = { [weak self] (result: SLComposeViewControllerResult) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                self?.navigationController?.popToRootViewController(animated: true)
            })
        }
        self.present(controller, animated: true, completion: nil)
    }

    private func prepareBookImage()-> UIImage? {
        if self.bookImageView.image == nil {
            self.bookImageView.image = kPlacejolderBookImage
        }

        guard let rawImageWidth = self.book.imageWidth?.cgfloat() else {
            return self.bookImageView.image
        }
        guard let rawImageHeight = self.book.imageHeight?.cgfloat() else {
            return self.bookImageView.image
        }
        let rawImageSize = CGSize(width: rawImageWidth, height: rawImageHeight)
        let fixedImageSize = CGSize(width: kCommonDeviceWidth, height: kCommonDeviceWidth)

        self.bookImageView.resize(rawImageSize, fixedHeight: fixedImageSize.height, fixedWidth: fixedImageSize.width, center: fixedImageSize.width)
        let bookImage = self.bookImageView.image

        let imageViewSize = self.bookImageView.frame.size
        UIGraphicsBeginImageContext(imageViewSize)
        bookImage?.draw(in: CGRect(x: 0, y: 0, width: imageViewSize.width, height: imageViewSize.height))
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let resizedImage = generatedImage {
            let whiteImage = UIImage.imageWithColor(UIColor.white, size: fixedImageSize)
            let imageOffset = CGPoint(x: (fixedImageSize.width - resizedImage.size.width) / 2, y: (fixedImageSize.height - resizedImage.size.height) / 2)
            let imageToShare = whiteImage?.imageAddingImage(resizedImage, offset: imageOffset)
            return imageToShare
        }

        return bookImage
    }

    // ================================================================================
    // MARK: - image pi
    override open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let img: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        switch imageTag! {
        case 0:
            merchandise.photo = Photo(image: img)
            break
        case 1:
            merchandise.photo2 = Photo(image: img)
            break
        case 2:
            merchandise.photo3 = Photo(image: img)
            break
        default:
            break
        }

        picker.dismiss(animated: true, completion: nil)
        tableView!.reloadData()
    }
    
    // ================================================================================
    // MARK: - ExhibitCommentCellDelegate , scroll
    
    open func baseCommentCellStartEditing(_ cell: BaseCommentCell) {
        if let cell: UITableViewCell = self.cell(withSection: .bookInfo, andRow: .bookInfoStatus) {
            let rectOfCellInSuperview = self.tableView!.convert(self.tableView!.bounds, to: cell)
            self.moveContentOffsetWithTargetCellRect(rectOfCellInSuperview, index: 1)
        }
    }
    
    open func baseCommentCellEdittingText(_ cell: BaseCommentCell, text: String) {}
    
    open func exhibitCommentCellEdittingText(_ cell: ExhibitCommentCell, arterInputText: String) {
         merchandise.comment = arterInputText
    }
    
    open func exhibitBookStatusCellButtonTapped(_ tag: Int) {
        merchandise.quality = tag
        if let cell: ExhibitCommentCell = self.cell(withSection: .bookInfo, andRow: .bookInfoShippingComment) {
            cell.type = ExhibitCommentCellPlaceholderType(rawValue: merchandise.quality ?? 0)
        }
    }
    
    open func exhibitCommentCellEndEditting(_ cell: ExhibitCommentCell) {
        if let cell: BaseTextFieldCell = self.cell(withSection: .bookInfo, andRow: .bookInfoShippingFrom) {
            if Me.sharedMe.defaultShipFrom == nil && Me.sharedMe.defaultShipIn == nil && Me.sharedMe.defaultShipWay == nil {
                cell.textField?.becomeFirstResponder()
            }
        }
    }
    
    // ================================================================================
    // MARK: thanksview delegate
    
    open override func baseSuggestViewCancelButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {}
    
    open override func baseSuggestViewActionButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?){
        let controller: BarcodeScannerViewController = BarcodeScannerViewController()
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    open func exhibitThanksViewShareTwitter(_ view: ExhibitThanksView) {
        self.shareTwitter()
    }
    
    open func exhibitThanksViewGoBackHome(_ view: ExhibitThanksView) {
        for controller in self.navigationController!.viewControllers {
            if controller is DetailPageTableViewController {
                _ = self.navigationController?.popToRootViewController(animated: true)
                return
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // ================================================================================
    // MARK: tableView
    
     override public func numberOfSections(in tableView: UITableView) -> Int {
        return self.section(self.isSeries).count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section(isSeries)[section].rowItems.count
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: UIView = UIView()
        sectionView.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonTableSectionHeight)
        sectionView.backgroundColor = UIColor.clear
        return sectionView
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? self.separatorHeight : 0
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.section(isSeries)[(indexPath as IndexPath).section].rowItems[(indexPath as IndexPath).row] {
        case .bookInfoBookDetail:
            return ExhibitBookInfoDetailCell.cellHeightForObject(book)
        case .bookInfoBulkPhoto:
            return ExhibitBulkPhotoCell.cellHeightForObject(nil)
        case .bookInfoPrice:
            return 60.0
        case .bookInfoCommissionAndBenefits:
            return ExhibitCommissionAndBenefitsCell.cellHeight
        case .bookInfoStatus:
            return 60.0
        case .bookInfoShippingComment:
            return ExhibitCommentCell.cellHeightForObject(nil)
        case .bookInfoExhibitButton, .bookInfoDeleteButton:
            return ExhibitButtonCell.cellHeightForObject(nil)
        case .bookInfoSeparator:
            return self.separatorHeight
        case .bookInfoOr, .helpTitle:
            return BaseTitleCell.cellHeightForObject(nil)
        default:
            return 50.0
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        activeTableViewtag = tableView.tag
        var cell: BaseTableViewCell?
        var cellIdentifier: String?
        let accessoryImage: UIImage! = UIImage(named: "ic_to")
        
        switch self.section(self.isSeries)[indexPath.section].rowItems[indexPath.row] {
        case .bookInfoBookDetail:
            cellIdentifier = "ExhibitBookInfoDetailCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?ExhibitBookInfoDetailCell
            if cell == nil {
                cell = ExhibitBookInfoDetailCell.init(reuseIdentifier: cellIdentifier!, delegate: self, book: book)
            }
            break
        case .bookInfoBulkTitle:
            cellIdentifier = "BookInfoBulkTitle"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?BaseTextFieldCell
            if cell == nil {
                cell = BaseTextFieldCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as? BaseTextFieldCell)?.textFieldType = 0
            (cell as? BaseTextFieldCell)?.isShortBottomLine = true
            (cell as? BaseTextFieldCell)?.titleText = "掲載用タイトル"
            (cell as? BaseTextFieldCell)?.placeholderText = "(例)ONE PIECE 全巻"
            (cell as? BaseTextFieldCell)?.textFieldText = merchandise.seriesDespription
            (cell as? BaseTextFieldCell)?.textField?.textAlignment = .right
            cell?.selectionStyle = .none
            break
        case .bookInfoBulkPhoto:
            cellIdentifier = NSStringFromClass(ExhibitBulkPhotoCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?ExhibitBulkPhotoCell
            if cell == nil {
                cell = ExhibitBulkPhotoCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            
            if Utility.isEmpty(merchandise.photo?.imageURL) == false {
                (cell as! ExhibitBulkPhotoCell).photoImageUrl = [0: merchandise.photo!.imageURL!]
            }
            
            if Utility.isEmpty(merchandise.photo2?.imageURL) == false {
                (cell as! ExhibitBulkPhotoCell).photoImageUrl = [1: merchandise.photo2!.imageURL!]
            }

            if Utility.isEmpty(merchandise.photo3?.imageURL) == false {
                (cell as! ExhibitBulkPhotoCell).photoImageUrl = [2: merchandise.photo3!.imageURL!]
            }

            if Utility.isEmpty(merchandise.photo?.image) == false {
                (cell as! ExhibitBulkPhotoCell).photoImage = [0: merchandise.photo!.image!]
            }
            
            if Utility.isEmpty(merchandise.photo2?.image) == false {
                (cell as! ExhibitBulkPhotoCell).photoImage = [1: merchandise.photo2!.image!]
            }
            
            if Utility.isEmpty(merchandise.photo3?.image) == false {
                (cell as! ExhibitBulkPhotoCell).photoImage = [2: merchandise.photo3!.image!]
            }
            (cell as? ExhibitBulkPhotoCell)?.isShortBottomLine = true
          
            break
        case .bookInfoPrice:
            cellIdentifier = "BookInfoPrice"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?ExhibitSellingPriceCell
            if cell == nil {
                cell = ExhibitSellingPriceCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as? ExhibitSellingPriceCell)?.textFieldType = 1
            (cell as? ExhibitSellingPriceCell)?.isShortBottomLine = true
            (cell as? ExhibitSellingPriceCell)?.cellModelObject = book
            
            _ = merchandise.price.map({ (price) in
                (cell as? ExhibitSellingPriceCell)?.textFieldText = price
            })
            break
        case .bookInfoCommissionAndBenefits:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExhibitCommissionAndBenefitsCell.reuseID, for: indexPath) as! ExhibitCommissionAndBenefitsCell
            cell.reflect(withPrice: Int(self.merchandise.price ?? "0") ?? 0)
            return cell
        case .bookInfoStatus:
            cellIdentifier = "BookInfoStatus"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?ExhibitBookStatusCell
            if cell == nil {
                cell = ExhibitBookStatusCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as? ExhibitBookStatusCell)?.cellModelObject = merchandise
            break
        case .bookInfoShippingIn:
            cellIdentifier = "BookInfoShippingDay"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?ExhibitPickerCell
            if cell == nil {
                cell = ExhibitPickerCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as? ExhibitPickerCell)?.titleText = "発送までの日程"
            (cell as? ExhibitPickerCell)?.placeholderText = "未設定"
            (cell as? ExhibitPickerCell)?.pickerContents = Merchandise.shippingDaysRangesLong
            (cell as? ExhibitPickerCell)?.textFieldText = Me.sharedMe.defaultShipIn
            (cell as? ExhibitPickerCell)?.textFieldType = indexPath.row
            (cell as? ExhibitPickerCell)?.isShortBottomLine = true
            (cell as? ExhibitPickerCell)?.useDefaultValue = true
            break
        case .bookInfoShippingWay:
            cellIdentifier = "BookInfoShippingWay"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?ExhibitPickerCell
            if cell == nil {
                cell = ExhibitPickerCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as? ExhibitPickerCell)?.titleText = "発送方法"
            (cell as? ExhibitPickerCell)?.placeholderText = "未設定"
            (cell as? ExhibitPickerCell)?.pickerContents = Merchandise.shippingWays
            (cell as? ExhibitPickerCell)?.textFieldText = Me.sharedMe.defaultShipWay
            (cell as? ExhibitPickerCell)?.textFieldType = indexPath.row
            (cell as? ExhibitPickerCell)?.useDefaultValue = true
            if Me.sharedMe.defaultShipIn == nil {
                (cell as? ExhibitPickerCell)?.keyboardToolbarButtonText = "次へ"
            } else {
                (cell as? ExhibitPickerCell)?.keyboardToolbarButtonText = "完了"
            }
            (cell as? ExhibitPickerCell)?.isShortBottomLine = true
            break
        case .bookInfoShippingFrom:
            cellIdentifier = "BookInfoShippingFrom"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?ExhibitPickerCell
            if cell == nil {
                cell = ExhibitPickerCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as? ExhibitPickerCell)?.titleText = "発送元の地域"
            (cell as? ExhibitPickerCell)?.placeholderText = "(例)東京都"
            (cell as? ExhibitPickerCell)?.textFieldText = Me.sharedMe.defaultShipFrom
            (cell as? ExhibitPickerCell)?.textField!.keyboardType = .default
            (cell as? ExhibitPickerCell)?.textFieldType = indexPath.row
            (cell as? ExhibitPickerCell)?.pickerContents = Merchandise.shippingFromContents
            (cell as? ExhibitPickerCell)?.useDefaultValue = true
            if Me.sharedMe.defaultShipWay == nil {
                (cell as? ExhibitPickerCell)?.keyboardToolbarButtonText = "次へ"
            } else {
                (cell as? ExhibitPickerCell)?.keyboardToolbarButtonText = "完了"
            }
            (cell as? ExhibitPickerCell)?.isShortBottomLine = true
            break
        case .bookInfoShippingComment:
            cellIdentifier = NSStringFromClass(ExhibitCommentCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?ExhibitCommentCell
            if cell == nil {
                cell = ExhibitCommentCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as? ExhibitCommentCell)?.commentTextView.text = merchandise.comment
            (cell as? ExhibitCommentCell)?.type = ExhibitCommentCellPlaceholderType(rawValue: merchandise.quality ?? 0)
            break
        case .bookInfoExhibitButton:
            cellIdentifier = NSStringFromClass(ExhibitButtonCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?ExhibitButtonCell
            if cell == nil {
                cell = ExhibitButtonCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            break
        case .bookInfoDeleteButton:
            cellIdentifier = NSStringFromClass(ExhibitDeleteCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?ExhibitDeleteCell
            if cell == nil {
                cell = ExhibitDeleteCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            break

        case .bookInfoOr:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as? BaseTitleCell)?.title = "or"
            (cell as? BaseTitleCell)?.titleLabel?.x = (kCommonDeviceWidth - (cell as! BaseTitleCell).titleLabel!.width) / 2
            (cell as? BaseTitleCell)?.titleLabel?.textAlignment = .center
            (cell as? BaseTitleCell)?.bottomLineView?.backgroundColor = UIColor.clear
            break
        case .bookInfoSeparator:
            let cell = EmptyTableViewCell(withHeight: self.separatorHeight)
            return cell

        case .helpTitle:
            cellIdentifier = NSStringFromClass(BaseTitleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?BaseTitleCell
            if cell == nil {
                cell = BaseTitleCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as? BaseTitleCell)?.title = "ヘルプ"
            break
        case .helpPrice:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "出品にお金はかかるの?"
            (cell as! BaseIconTextTableViewCell).titleLabel!.x = 15.0
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            (cell as! BaseIconTextTableViewCell).rightImage = accessoryImage
            break
        case .helpConfirmFlowTransaction:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "取引の流れを確認する"
            (cell as! BaseIconTextTableViewCell).titleLabel!.x = 15.0
            (cell as! BaseIconTextTableViewCell).rightImage = accessoryImage
            break
        case .helpCompareDeliver:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier!, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).title = "一番安く発送するには？"
            (cell as! BaseIconTextTableViewCell).titleLabel!.x = 15.0
            (cell as! BaseIconTextTableViewCell).rightImage = accessoryImage
            break
        }
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let targetCell: BaseTextFieldCell? = tableView.cellForRow(at: indexPath) as? BaseTextFieldCell
        targetCell?.textField?.becomeFirstResponder()
        
        var helpUrl: URL? = URL(string: "")
        
        switch self.section(isSeries)[(indexPath as IndexPath).section].rowItems[(indexPath as IndexPath).row] {
        case .helpPrice:
            helpUrl = URL(string: "http://static.bukuma.io/bkm_app/faq.html#section1-01")!
            let controller = BaseWebViewController(url: helpUrl!)
            controller.view.clipsToBounds = true
            controller.view.backgroundColor = kBackGroundColor
            controller.webView?.backgroundColor = kBackGroundColor
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case .helpConfirmFlowTransaction:
            helpUrl = URL(string: "http://static.bukuma.io/bkm_app/guide/flow.html")!
            let controller = BaseWebViewController(url: helpUrl!)
            controller.view.clipsToBounds = true
            controller.view.backgroundColor = kBackGroundColor
            controller.webView?.backgroundColor = kBackGroundColor
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case .helpCompareDeliver:
            helpUrl = URL(string: "http://static.bukuma.io/bkm_app/guide/delivery_compare.html")!
            let controller = BaseWebViewController(url: helpUrl!)
            controller.view.clipsToBounds = true
            controller.view.backgroundColor = kBackGroundColor
            controller.webView?.backgroundColor = kBackGroundColor
            self.navigationController?.pushViewController(controller, animated: true)
            break
        default:
            break
        }
    }
}

