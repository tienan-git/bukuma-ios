//
//  DetailPageTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/17.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import PhotoSlider
import SVProgressHUD
import RMUniversalAlert

public enum DetailPageType {
    case normal
    case edit
}

open class DetailPageTableViewController: BaseTableViewController,
DetailHeaderViewDelegate,
DetailPageUserCellDelegate,
DetailRecommendBookDelegate,
TagControllerProtocol {
    
    var lowestMerchandise: Merchandise?
    var otherMerchandises: [Merchandise]?
    var detailView: DetailHeaderView?
    var book: Book?
    var recommendBooks: [Book]? = []
    var mers: Merchandises?
    var type: DetailPageType?

    fileprivate enum TableViewSectionType: Int {
        case bookDetail
        case tagSection
        case exhibitors
        case other
        case unexpect
    }
    
    fileprivate enum TableViewRowType: Int {
        case bookDetailTitle
        case bookDetail
        case tagHeader
        case oneOfTags
        case tagFooter
        case exhibitorTitle
        case exhibitors
        case exhibitorsLoadMore
        case otherTitle
        case exhibitBook
        case amazonLink
        case rakutenLink
        case reportBook
        case unexpect
    }

    /// ViewController 自身の生成
    /// 引数用に Merchandises を生成＆取得する流れが必須のようなので、一箇所にまとめた
    /// 前後に SVProgressHUD.show, dismiss や self.view.isUserInteractionEnabled = false, true 処理が必要に応じてあると良いだろう
    class func generate(for book: Book?, pageType type: DetailPageType = .normal, withCompletion completion: ((_ generatedViewController: DetailPageTableViewController?)-> Void)?) {
        let merchandises = Merchandises()
        merchandises.getMerchandises(book) { (error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }

            DispatchQueue.main.async {
                let viewController = DetailPageTableViewController(book: book, merchandises: merchandises, type: type)
                viewController.view.clipsToBounds = true

                completion?(viewController)
            }
        }
    }
    
    // ================================================================================
    // MARK: setting
    
    deinit {
        DBLog("-------------deinit DetailPageTableViewController ----------")
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
    
    override var shouldShowProgressHUDWhenDataSourceRefresh: Bool {
        get {
            return false
        }
    }
    
    var isNoneSeller: Bool {
        return mers?.isSellerBeing() == false
    }

    private let numberOfMerchandisesToShow = 5
    private let sellerListHeader = 1
    private let showMoreFooter = 1
    
    private var isSellerLessThan5: Bool {
        get { return (self.mers?.count())! <= self.numberOfMerchandisesToShow }
    }

    private var noMoreData: Bool {
        get { return self.book?.merchandisesCount?.int() == self.mers?.count() }
    }

    private let unuseDataPage: Int = -1
    private let initialDataPage: Int = 1
    private var dataPage: Int = 1

    private var yetMoreData: Bool {
        get { return self.dataPage == self.initialDataPage }
    }

    private var isShowMoreData: Bool = true

    var isEmptyBookDetail: Bool {
        return Utility.isEmpty(book?.summary)
    }

    override open func initializeNavigationLayout() {
        self.navigationBarTitle = book.flatMap{$0.titleText()}
    }
    
    // ================================================================================
    // MARK: init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(book: Book?, merchandises: Merchandises?, type: DetailPageType) {
        super.init(nibName: nil, bundle: nil)
        self.book = book
        self.type = type
        lowestMerchandise = book?.lowestMerchandise
        mers = merchandises
        mers?.allMerchandiseCount = book?.merchandisesCount?.int() ?? 0
        otherMerchandises = merchandises?.otherMerchandises
        recommendBooks = Book.recomendBookList(book?.categoryId ?? "1", exceptBook: book ?? Book())
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        detailView = DetailHeaderView(delegate: self)
        detailView?.book = book
        detailView?.merchandise = lowestMerchandise

        tableView?.tableHeaderView = detailView
        tableView?.showsPullToRefresh = false

        self.automaticallyAdjustsScrollViewInsets = false

        self.get1stTags() { [weak self] (_ error: Error?) in
            guard error == nil else {
                return
            }
            if (self?.numberOfTags ?? 0) > 0 {
                DispatchQueue.main.async {
                    self?.detailView?.tagArrayView = self?.makeTagArrayView()

                    self?.tableView?.reloadData()
                }
            }
        }

        var nib = UINib(nibName: TagHeaderCell.nibName, bundle: nil)
        self.tableView?.register(nib, forCellReuseIdentifier: TagHeaderCell.reuseID)
        nib = UINib(nibName: TagCell.nibName, bundle: nil)
        self.tableView?.register(nib, forCellReuseIdentifier: TagCell.reuseID)
        nib = UINib(nibName: TagFooterCell.nibName, bundle: nil)
        self.tableView?.register(nib, forCellReuseIdentifier: TagFooterCell.reuseID)
    }
    
    func rightButtonTapped(_ sender: UIButton) {
        let myMerchandise: Merchandise? = otherMerchandises?.filter {$0.user?.identifier == Me.sharedMe.identifier}.first
        if myMerchandise?.isSold == true {
            self.simpleAlert(nil, message: "すでに購入された商品は編集できません", cancelTitle: "OK", completion: nil)
            return
        }
        let controller: ExhibitEditViewController = ExhibitEditViewController(merchandise: myMerchandise, book: book, type: book?.isSeries == true ? .series : .normal)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
        self.view.isUserInteractionEnabled = true
    }
    
    // ================================================================================
    // MARK: - headerView delegate
    
    open func headerViewBuyButtonTapped(_ view: DetailHeaderView) {
        if Me.sharedMe.isRegisterd == false {
            self.showUnRegisterAlert()
            return
        }
        
        if Me.sharedMe.verified == false {
            self.showUnVerifiedAlert()
            return
        }
        
        if Utility.isEmpty(lowestMerchandise?.user?.identifier) {
            self.deletedUsersMerchandiseAlert()
            return
        }

        if lowestMerchandise?.isSold == true {
            self.alreadySoldAlert()
            return
        }

        if self.isTagEditing {
            return
        }
        
        if lowestMerchandise != nil && book != nil {
            if Me.sharedMe.isMine(lowestMerchandise?.user?.identifier ?? "") == true {
                self.simpleAlert(nil, message: "自分が出品した商品は買うことができません", cancelTitle: "OK", completion: nil)
                return
            }
            
            if lowestMerchandise == nil || book == nil {
                return
            }
            let controller: PurchaseViewController = PurchaseViewController(merchandise: lowestMerchandise!, book: book!)
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    public func headerViewLikeCountButtonTapped(_ view: DetailHeaderView, completion: @escaping (_ isLiked: Bool, _ numLike: Int) -> Void) {
        if Me.sharedMe.isRegisterd == false {
            self.showUnRegisterAlert()
            return
        }

        if self.isTagEditing {
            return
        }

        book?.toggleLikeBook({ (isLiked, numLike, error) in
            DispatchQueue.main.async {
                completion(isLiked, numLike)
            }
        })
    }

    // ================================================================================
    // MARK: - detailRecommendBookCell delegate
    open func detailRecommendBookDidSelectAdRow(_ row: Int, book: Book) {
        self.goDetailBook(book, completion: nil)
    }
    
    // ================================================================================
    // MARK: - detailUserCell delegate
    
    open func detailPageUserCellBuyButtonTapped(_ cell: DetailPageUserCell) {
        if Me.sharedMe.isRegisterd == false {
            self.showUnRegisterAlert()
            return
        }

        if Me.sharedMe.verified == false {
            self.showUnVerifiedAlert()
            return
        }

        if self.isTagEditing {
            return
        }
        
        if (cell.cellModelObject as? Merchandise)?.user?.identifier == Me.sharedMe.identifier {
            if (cell.cellModelObject as? Merchandise)?.isSold == true {
                self.simpleAlert(nil, message: "すでに購入された商品は編集できません", cancelTitle: "OK", completion: nil)
                return
            }
            self.goEditMerchandise(cell.cellModelObject as? Merchandise)
            return
        }
        
        if cell.cellModelObject as? Merchandise != nil {
            if (cell.cellModelObject as? Merchandise)?.isSold == true {
                self.alreadySoldAlert()
                return
            }
            
            if Utility.isEmpty((cell.cellModelObject as? Merchandise)?.user?.identifier) {
                self.deletedUsersMerchandiseAlert()
                return
            }

            if  Me.sharedMe.isMine((cell.cellModelObject as? Merchandise)?.user?.identifier ?? "") == true {
                self.simpleAlert(nil, message: "自分が出品した商品は買うことができません", cancelTitle: "OK", completion: nil)
                return
            }

            if cell.cellModelObject == nil || book == nil {
                return
            }
            
            let controler: PurchaseViewController = PurchaseViewController(merchandise: cell.cellModelObject as! Merchandise, book: book!)
            controler.view.clipsToBounds = true
            self.navigationController?.pushViewController(controler, animated: true)
        }
    }
    
    open func detailPageUserCellImageViewTapped(_ cell: DetailPageUserCell, tag: Int) {
        var slider: PhotoSlider.ViewController?
        
        var images: [UIImage]? = Array()
        
        for button in cell.images {
            if button .imageView?.image != nil {
                images?.append(button.imageView!.image!)
            }
        }
        
        slider = PhotoSlider.ViewController(images: images!)
        slider!.transitioningDelegate = self
        slider!.modalPresentationStyle = .overCurrentContext
        slider!.modalTransitionStyle = .crossDissolve
        slider!.visiblePageControl = true
        if images!.count >= tag {
            slider!.currentPage = tag
        }
        
        self.present(slider!, animated: true, completion: nil)
    }
    
    fileprivate func goEditMerchandise(_ merchandise: Merchandise?) {
        let controller: ExhibitEditViewController = ExhibitEditViewController(merchandise: merchandise, book: book, type: book?.isSeries == true ? .series : .normal)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func alreadySoldAlert() {
        self.simpleAlert(nil, message: "この商品はすでに購入されました。いいねをしておくと、新たな出品者が出た際に通知を受けとることができます", cancelTitle: "OK", completion: nil)
    }
    
    fileprivate func deletedUsersMerchandiseAlert() {
        self.simpleAlert(nil, message: "この商品の出品者はすでに退会しました。いいねをしておくと、新たな出品者が出た際に通知を受けとることができます", cancelTitle: "OK", completion: nil)
    }

    // MARK: - userIcondelegate

    override open func didUserIconTapped(_ user: User?) {
        if Me.sharedMe.isRegisterd == false {
            self.showUnRegisterAlert()
            return
        }

        if self.isTagEditing {
            return
        }

        let controller: UserPageViewController = UserPageViewController(user: user)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }

    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return  4
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec: TableViewSectionType = self.tableViewSectionType(section)

        switch sec {
        case .bookDetail:
            if isEmptyBookDetail == true {
                return 0
            }
            return 2

        case .tagSection:
            return self.numberOfTagItems

        case .exhibitors:
            if isNoneSeller == true {
                return 0
            } else {
                if self.isSellerLessThan5 {
                    return self.mers!.count() + self.sellerListHeader
                } else {
                    if self.yetMoreData {
                        return self.numberOfMerchandisesToShow + self.sellerListHeader + self.showMoreFooter
                    } else if self.isShowMoreData {
                        return self.mers!.count() + self.sellerListHeader + self.showMoreFooter
                    } else {
                        return self.mers!.count() + self.sellerListHeader
                    }
                }
            }
            
        case .other:
            if (Utility.isEmpty(book?.amazonLink) || (book?.amazonLink?.absoluteString.length ?? 0) <= 1) && (Utility.isEmpty(book?.rakutenLink) || (book?.rakutenLink?.absoluteString.length ?? 0) <= 1) {
                return 3
            }
            if !Utility.isEmpty(book?.amazonLink) && (book?.amazonLink?.absoluteString.length ?? 0) > 1 && !Utility.isEmpty(book?.rakutenLink) && (book?.rakutenLink?.absoluteString.length ?? 0) > 1 {
                return 5
            }
            return 4
        case .unexpect:
            return 0
        }
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.showableRowType(indexPath) {
        case .exhibitorTitle, .otherTitle, .exhibitorsLoadMore, .amazonLink, .rakutenLink, .reportBook, .exhibitBook, .bookDetailTitle:
            return BaseTitleCell.cellHeightForObject(nil)
        case .bookDetail:
            return DetailBookDespCell.cellHeightForObject(book, shouldShort: false)
        case .tagHeader:
            return TagHeaderCell.cellHeight()
        case .oneOfTags:
            return TagCell.cellHeight(with: self.tag(atRow: indexPath.row))
        case .tagFooter:
            return TagFooterCell.cellHeight()
        case .exhibitors:
            let merchandise: Merchandise? = mers?.dataSource?[indexPath.row - 1]
            guard let m = merchandise else { return 0 }
            return DetailPageUserCell.cellHeightForObject(m)
            
        case .unexpect:
            return 0
        }
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: UIView = UIView()
        sectionView.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonTableSectionHeight)
        sectionView.backgroundColor = UIColor.clear
        return sectionView
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         let sec: TableViewSectionType = self.tableViewSectionType(section)
        if sec == TableViewSectionType.exhibitors && isNoneSeller == true {
            return 0
        }
        if sec == TableViewSectionType.bookDetail && isEmptyBookDetail == true {
            return 0
        }
        return kCommonTableSectionHeight
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch self.showableRowType(indexPath) {
        case .bookDetailTitle:
            cellIdentifier = NSStringFromClass(DetailTItleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?DetailTItleCell
            if cell == nil {
                cell = DetailTItleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? DetailTItleCell)?.title = "本のあらすじ"
            break
        case .bookDetail:
            cellIdentifier = NSStringFromClass(DetailBookDespCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?DetailBookDespCell
            if cell == nil {
                cell = DetailBookDespCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            
            (cell as? DetailBookDespCell)?.setCellModel(book, shouldShort: false)
            break

        case .tagHeader:
            let cell = tableView.dequeueReusableCell(withIdentifier: TagHeaderCell.reuseID, for: indexPath) as! TagHeaderCell
            cell.setup()
            cell.delegate = self
            cell.addingTag = self.isTagEditing
            return cell
        case .oneOfTags:
            let cell = tableView.dequeueReusableCell(withIdentifier: TagCell.reuseID, for: indexPath) as! TagCell
            cell.setup(with: self.tag(atRow: indexPath.row))
            cell.delegate = self
            return cell
        case .tagFooter:
            let cell = tableView.dequeueReusableCell(withIdentifier: TagFooterCell.reuseID, for: indexPath) as! TagFooterCell
            cell.setup()
            return cell

        case .exhibitorTitle:
            cellIdentifier = NSStringFromClass(DetailTItleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?DetailTItleCell
            if cell == nil {
                cell = DetailTItleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            
            if book?.isSeries == true {
                 (cell as? DetailTItleCell)?.title = "この本の出品者"
            } else {
                 (cell as? DetailTItleCell)?.title = "この本の出品者一覧 ( \(book?.merchandisesCount ?? "0") )"
            }
            break
        case .exhibitors:
            let merchandise: Merchandise? = mers!.dataSource![indexPath.row - 1]
            cellIdentifier = NSStringFromClass(DetailPageUserCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?DetailPageUserCell
            if cell == nil {
                cell = DetailPageUserCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            
            (cell as? DetailPageUserCell)?.cellModelObject = merchandise
            break
        case .exhibitorsLoadMore:
            cellIdentifier = NSStringFromClass(DetailLoadMoreCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?DetailLoadMoreCell
            if cell == nil {
                cell = DetailLoadMoreCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            break

        case .otherTitle:
            cellIdentifier = NSStringFromClass(DetailTItleCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?DetailTItleCell
            if cell == nil {
                cell = DetailTItleCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as? DetailTItleCell)?.title = "メニュー"
            break
        case .exhibitBook:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_product_sell")
            (cell as! BaseIconTextTableViewCell).title = "この本を出品する"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            break
        case .amazonLink:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_product_amazon")
            (cell as! BaseIconTextTableViewCell).title = "Amazonで詳細を確認"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            break
        case .rakutenLink:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_product_amazon")
            (cell as! BaseIconTextTableViewCell).title = "楽天ブックスでこの本を見る"
            (cell as! BaseIconTextTableViewCell).isShortBottomLine = true
            break
        case .reportBook:
            cellIdentifier = NSStringFromClass(BaseIconTextTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTextTableViewCell
            if cell == nil {
                cell = BaseIconTextTableViewCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseIconTextTableViewCell).iconImage = UIImage(named: "ic_product_report")
            (cell as! BaseIconTextTableViewCell).title = "不適切な商品を報告する"
            break
        case .unexpect:
            break
        }
        return cell!
    }

    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.isTagEditing {
            return self.showableRowType(indexPath) == .tagHeader ? indexPath : nil
        } else {
            return indexPath
        }
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        switch self.showableRowType(indexPath) {
        case .exhibitors:
            let merchandise: Merchandise? = mers?.dataSource?[indexPath.row - 1]
            
            if merchandise != nil {
                if Me.sharedMe.isRegisterd == false {
                    self.showUnRegisterAlert()
                    return
                }
                
                if Me.sharedMe.verified == false {
                    self.showUnVerifiedAlert()
                    return
                }
                
                let controller: UserPageViewController = UserPageViewController(user: merchandise?.user)
                controller.view.clipsToBounds = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
        case .exhibitorsLoadMore:
            if self.noMoreData {
                self.isShowMoreData = false
                self.dataPage = self.unuseDataPage
                self.tableView?.reloadData()
            } else {
                if self.yetMoreData {
                    self.dataPage += 1
                    self.tableView?.reloadData()
                } else {
                    SVProgressHUD.show()

                    self.mers?.moreMerchandises(for: self.book!, dataPage: self.dataPage) { [weak self] (_ moreMerchandises: [Merchandise]?, _ err: Error?) in
                        DispatchQueue.main.async {
                            guard err == nil else {
                                SVProgressHUD.dismiss()
                                return
                            }

                            if moreMerchandises != nil {
                                self?.dataPage += 1

                                if (self?.noMoreData)! {
                                    self?.isShowMoreData = false
                                }
                            } else {
                                self?.isShowMoreData = false
                            }

                            self?.tableView?.reloadData()

                            SVProgressHUD.dismiss()
                        }
                    }
                }
            }
            break
        case .exhibitBook:
            if Me.sharedMe.isRegisterd == false {
                self.showUnRegisterAlert()
                return
            }
            
            if book?.isSeries == true {
                let parentBook: Book = Book()
                parentBook.identifier = book?.parentId
                parentBook.coverImage = book?.coverImage
                parentBook.title = book?.titleText()
                parentBook.publisher = book?.publisher
                parentBook.author = book?.author
                parentBook.listPrice = book?.listPrice
                parentBook.amazonPrice = book?.amazonPrice
                parentBook.imageWidth = book?.imageWidth
                parentBook.imageHeight = book?.imageHeight
                
                let controller: ExhibitTableViewController = ExhibitTableViewController(book: parentBook)
                controller.view.clipsToBounds = true
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller: ExhibitTableViewController = ExhibitTableViewController(book: book)
                controller.view.clipsToBounds = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            break
        case .amazonLink:
            
            if book?.amazonLink != nil {
                let controller: BaseWebViewController = BaseWebViewController(url: book!.amazonLink!)
                controller.view.clipsToBounds = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            break
        case .rakutenLink:
            if book?.rakutenLink != nil {
                let controller: BaseWebViewController = BaseWebViewController(url: book!.rakutenLink!)
                controller.view.clipsToBounds = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            break
        case .reportBook:
            
            if Me.sharedMe.isRegisterd == false {
                self.suggestDetailReport(.book, object: self.book ?? Book(), completion: nil)
                return
            }
            
            RMUniversalAlert.show(in: self,
                                  withTitle: "この商品を通報しますか？",
                                  message: nil,
                                  cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: "通報する",
                                  otherButtonTitles: nil,
                                  tap: {[weak self] (al, index) in
                                    if index == al.destructiveButtonIndex {
                                        self?.book?.reportBook(nil, completion: { (error) in
                                            DispatchQueue.main.async {
                                                SVProgressHUD.dismiss()
                                                if error != nil {
                                                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)

                                                    return
                                                }

                                                self?.suggestDetailReport(.book, object: self?.book ?? Book(), completion: nil)
                                            }
                                        })
                                    }
            })

            break

        case .tagHeader:
            if self.isTagEditing {
                self.endEditTags(completion: nil)
            }
        case .oneOfTags:
            if let tag = self.tag(atRow: indexPath.row) {
                let controller = TagedBooksViewController(withTag: tag)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        case .tagFooter:
            self.getAllTags() { [weak self] (error: Error?) in
                guard error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    self?.tableView?.reloadData()
                }
            }

        default:
            break
        }
    }

    fileprivate func tableViewSectionType(_ section:Int) ->TableViewSectionType {
        switch section {
        case 0: return .bookDetail
        case 1: return .tagSection
        case 2: return .exhibitors
        case 3: return .other
        default: return .unexpect
        }
    }
    
    fileprivate func showableRowType(_ indexPath:IndexPath) ->TableViewRowType {
        let section: TableViewSectionType = self.tableViewSectionType(indexPath.section)
        
        if section == .bookDetail {
            if indexPath.row == 0 {
                return TableViewRowType.bookDetailTitle
            }
            if indexPath.row == 1 {
                return TableViewRowType.bookDetail
            }
        } else if section == .tagSection {
            if indexPath.row == 0 {
                return .tagHeader
            } else if self.isMoreTags == true {
                return indexPath.row == (self.numberOfTagItems - 1) ? .tagFooter : .oneOfTags
            } else {
                return .oneOfTags
            }
        } else if section == .exhibitors {
            if isNoneSeller == false {
                if indexPath.row == 0 {
                    return TableViewRowType.exhibitorTitle
                } else {
                    if self.isSellerLessThan5 {
                        return TableViewRowType.exhibitors
                    } else {
                        if self.yetMoreData {
                            return indexPath.row == (self.numberOfMerchandisesToShow + 1) ? TableViewRowType.exhibitorsLoadMore : TableViewRowType.exhibitors
                        } else if self.isShowMoreData {
                            return indexPath.row == (self.mers!.count() + 1) ? TableViewRowType.exhibitorsLoadMore : TableViewRowType.exhibitors
                        } else {
                            return TableViewRowType.exhibitors
                        }
                    }
                }
            }
        } else if section == .other {
            switch indexPath.row {
            case 0:
                return TableViewRowType.otherTitle
            case 1:
                return TableViewRowType.exhibitBook
            case 2:
                if !Utility.isEmpty(book?.amazonLink) && (book?.amazonLink?.absoluteString.length ?? 0) > 1 {
                    return TableViewRowType.amazonLink
                } else if !Utility.isEmpty(book?.rakutenLink) && (book?.rakutenLink?.absoluteString.length ?? 0) > 1 {
                    return TableViewRowType.rakutenLink
                } else {
                    return TableViewRowType.reportBook
                }
            case 3:
                if !Utility.isEmpty(book?.amazonLink) && (book?.amazonLink?.absoluteString.length ?? 0) > 1 && !Utility.isEmpty(book?.rakutenLink) && (book?.rakutenLink?.absoluteString.length ?? 0) > 1 {
                    return TableViewRowType.rakutenLink
                } else {
                    return TableViewRowType.reportBook
                }
            case 4:
                return TableViewRowType.reportBook
            default:
                return TableViewRowType.unexpect
            }
        }

        return TableViewRowType.unexpect
    }

    // MARK: - TagControllerProtocol

    var tags: [Tag]?

    var isMoreTags: Bool = false

    var isTagEditing: Bool = false
    var tagEditor: TagEditorView?

    // MARK: - Keyboard (TagHeaderCellDelegate)

    override func keyboardDidShow(_ notification: Foundation.Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let animationCurve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! UInt

        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.init(rawValue: animationCurve), animations: {
            var frame = self.tagEditor!.frame
            frame.origin.y = self.view.frame.maxY - keyboardFrame.size.height - frame.size.height
            self.tagEditor?.frame = frame
        }, completion: nil)
    }

    override func keyboardDidHide(_ notification: Foundation.Notification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let animationCurve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! UInt

        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.init(rawValue: animationCurve), animations: {
            self.tagEditor?.removeFromSuperview()
            self.tagEditor = nil
        }, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension DetailPageTableViewController: UITextViewDelegate {
    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.showBooks(withTagIdURL: URL)
        return false
    }

    @available(iOS, introduced: 7.0, deprecated: 10.0)
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.showBooks(withTagIdURL: URL)
        return false
    }

    private func showBooks(withTagIdURL tagIdURL: URL) {
        let urlString = tagIdURL.absoluteString
        let tagId = Int(urlString.substring(from: "hash:".characters.endIndex))
        if let tags = self.tags {
            for tag in tags {
                if tag.id == tagId {
                    let controller = TagedBooksViewController(withTag: tag)
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
}

// MARK: - TagCellDelegate

extension DetailPageTableViewController: TagCellDelegate {
    func tappedLikes(withTagData tagData: Tag) -> Bool {
        if self.isTagEditing {
            return false
        }
        guard let bookId = self.book?.identifier?.int() else {
            return false
        }

        if tagData.isVoted {
            tagData.isVoted = false
            tagData.numberOfVotes -= 1
        } else {
            tagData.isVoted = true
            tagData.numberOfVotes += 1
        }

        tagData.setLikes(forBookId: bookId, completion: nil)

        return true
    }
}

// MARK: - TagHeaderCellDelegate

extension DetailPageTableViewController: TagHeaderCellDelegate {
    func beginEditTags(completion: ((_ isEditable: Bool) -> Void)?) {
        if Me.sharedMe.isRegisterd == false {
            self.showUnRegisterAlert()
            completion?(false)
            return
        }

        if Me.sharedMe.verified == false {
            self.showUnVerifiedAlert()
            completion?(false)
            return
        }

        self.isTagEditing = true
        self.isNeedKeyboardNotification = true

        self.tagEditor = TagEditorView.tagEditorView()
        if let tagEditorView = self.tagEditor {
            tagEditorView.delegate = self

            var viewFrame = self.view.frame
            viewFrame.origin.y = viewFrame.maxY - tagEditorView.frame.size.height
            viewFrame.size.height = tagEditorView.frame.size.height
            tagEditorView.frame = viewFrame
            self.view.addSubview(tagEditorView)

            let indexPath = IndexPath(row: self.topTagRow, section: self.tagSection)
            self.tableView?.scrollToRow(at: indexPath, at: .top, animated: true)

            _ = tagEditorView.becomeFirstResponder()
        } else {
            self.isNeedKeyboardNotification = false
            self.isTagEditing = false
        }
        completion?(true)
    }

    func endEditTags(completion: (() -> Void)?) {
        self.hideKeyboard()

        let indexPath = IndexPath(row: self.topTagRow, section: self.tagSection)
        let cell = self.tableView?.cellForRow(at: indexPath) as? TagHeaderCell
        cell?.addingTag = false

        completion?()

        self.isNeedKeyboardNotification = false
        self.isTagEditing = false
    }
}

// MARK: - TagEditorViewDelegate

extension DetailPageTableViewController: TagEditorViewDelegate {
    func tappedAddTagsButton(tagStringsToAdd tagStrings: [String], _ completion: @escaping () -> Void) {
        guard let bookId = self.book?.identifier?.int() else {
            DispatchQueue.main.async {
                completion()
                self.endEditTags(completion: nil)
            }
            return
        }

        Tag.addTags(forBookId: bookId, tagStringsToAdd: tagStrings) { [weak self] (_ error: Error?) in
            if error != nil {
                DispatchQueue.main.async {
                    completion()
                    self?.endEditTags(completion: nil)
                }
                return
            }

            self?.isMoreTags = true // 全件強制再取得
            self?.getAllTags() { (_ error: Error?) in
                if error != nil {
                    DispatchQueue.main.async {
                        completion()
                        self?.endEditTags(completion: nil)
                    }
                    return
                }

                completion()
                self?.endEditTags(completion: nil)

                DispatchQueue.main.async {
                    self?.detailView?.tagArrayView = self?.makeTagArrayView()

                    self?.tableView?.reloadData()
                }
            }
        }
    }
}
