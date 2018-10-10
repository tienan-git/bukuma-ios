//
//  BKMBaseTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import PhotoSlider
import SVProgressHUD
import RMUniversalAlert

/**
 TableViewを作りたいときにこのはBaseTableViewControllerを継承して作られている
ActivityViewControllerや、TransactionListTableViewControllerのように、cellClass,dataSourceClassを設定するだけで
簡単にList構造のTableViewControllerを作ることができる。
 
 */

open class BaseTableViewController: BaseDataSourceViewController,
BaseTableViewDelegate,
BaseTableViewCellDelegate,
UserIconCellDelegate,
UITableViewDataSource,
PhotoSlider.PhotoSliderDelegate,
PhotoSlider.ZoomingAnimationControllerTransitioning,
UIViewControllerTransitioningDelegate,
UIImagePickerControllerDelegate {

    // ================================================================================
    // MARK: - property
    var tableView: BaseTableView?
    var activeTableViewtag: Int?
    var pickerNavigationBarView: NavigationBarView? /// imagePickerなどのためのNavigationBarView

    // ================================================================================
    // MARK: - setting

    deinit {
        pickerNavigationBarView = nil
        tableView = nil
        DBLog("-----------deinit BaseTableViewController --------")
    }

    open func footerHeight() -> CGFloat {
        return kAppDelegate.tabBarController.tabBar.height + 64.0
    }
    
    open func scrollIndicatorInsetBottom() ->CGFloat {
        return kAppDelegate.tabBarController.tabBar.height
    }
    
    override open func registerCellClass() -> AnyClass? {
        return nil
    }
    
    // ================================================================================
    // MARK: - emptyData delegate
    /// EmptyDataView Class参照
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "表示するコンテンツがありません"
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return "表示するコンテンツがありません"
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "img_ph_00")
    }
    
    override open func emptyViewCenterPositionY() -> CGFloat {
        let contentHeight: CGFloat = self.view.height - NavigationHeightCalculator.navigationHeight() - kAppDelegate.tabBarController.tabBar.height
        return (contentHeight - self.tableView!.contentInsetTop) / 2
    }
    
    // ================================================================================
    // MARK: init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init () {
        self.init(nibName: nil, bundle: nil)
    }
        
    // ================================================================================
    // MARK: -tableViewGenerate
    
    open func generateTableView() ->BaseTableView {
        
        let tableView = BaseTableView.init(frame: self.view.bounds, style: .plain)
        tableView.tableViewDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = kBackGroundColor
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = kBorderColor
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.scrollsToTop = true
        tableView.alwaysBounceVertical = true

        /// pullToRefreshを追加している
        tableView.addPull(toRefreshScrollHeight: self.pullToRefreshScrollHeight(),
            contentInsetTop: self.pullToRefreshInsetTop()) { [weak self] () -> Void in
                self?.refreshDataSource()
        }
        
        return tableView
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeTableViewStruct()

        self.tableView = self.generateTableView()
        self.tableView!.separatorStyle = .none
        self.view.insertSubview(self.tableView!, belowSubview: navigationBarView!)
        
        tableView!.addSubview(emptyDataView!)
        emptyDataView?.adjustEmptyView()
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())
    
    }
    
    func adjustTableViewInset(_ tableView: BaseTableView, contentInsetTop:CGFloat) {
        tableView.contentInsetTop = contentInsetTop
        tableView.contentOffsetY = -tableView.contentInsetTop
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.scrollIndicatorInsets.bottom = tableView.contentInset.bottom + 64.0
    }
    
    /// SettingViewControllerなどの継承先で使われている。
    func initializeTableViewStruct() {}
    
    // ================================================================================
    // MARK: - Keyboard notofocation
    ///Keyboardが出現した時に、tableViewをいい感じにするための
    
    override func keyboardDidShow(_ notification: Foundation.Notification) {
        let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as!NSValue).cgRectValue
        tableView!.viewSize = CGSize(width: kCommonDeviceWidth, height: kCommonDeviceHeight - keyboardFrame.size.height)
    }
    
    override func keyboardDidHide(_ notification: Foundation.Notification) {
        tableView!.viewSize = CGSize(width: kCommonDeviceWidth, height: kCommonDeviceHeight)
    }
    
    // ================================================================================
    // MARK: - DataSource Delegate
    /**
     BaseDataSource Classを参照
     completeRequestはarrayにデータが代入された後に呼ばれる。ここでデータ取得後tableViewを更新するなどの処理をしている
     failedRequestは通信が失敗した後に呼ばれる
    */
    
    override open func completeRequest() {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
            self.tableView?.pullToRefreshView?.stopAnimating()
            SVProgressHUD.dismiss()
            
            self.emptyDataView?.isHidden = (self.dataSource?.count() ?? 0) > 0
            if self.tableView?.isFixScrollIndicatorBottom == true {
                self.tableView?.scrollIndicatorInsets = self.tableView!.contentInset
                self.tableView?.scrollIndicatorInsets.bottom = self.scrollIndicatorInsetBottom()
                return
            }
            self.tableView?.scrollIndicatorInsets = self.tableView!.contentInset

        }
    }
    
    override open func failedRequest(_ error: Error) {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
            self.tableView?.pullToRefreshView.stopAnimating()
            SVProgressHUD.dismiss()
            self.emptyDataView?.isHidden = (self.dataSource?.count() ?? 0) > 0
            self.tableView?.scrollIndicatorInsets = self.tableView!.contentInset
        }
    }
    
    // ================================================================================
    // MARK: - action alrat
    
    /**
     showPhoto()はuserPage、本の詳細pageでまとめ売りの写真を見るときなどに使われている
     */
    func showPhoto(_ photo: Photo?) {
        if photo == nil {
            self.simpleAlert(nil, message: "表示する写真がありません", cancelTitle: "OK", completion: nil)
            return
        }
        
        var slider: PhotoSlider.ViewController?
        
        if photo!.image != nil {
            //slider = PhotoViewController(images: [photo!.image!])
            slider = PhotoSlider.ViewController(images: [photo!.image!])
            slider?.transitioningDelegate = self
            slider?.modalPresentationStyle = .overCurrentContext
            slider?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            slider?.visiblePageControl = false
            if slider != nil {
                self.present(slider!, animated: true, completion: nil)
            }
            return
        }
        if photo?.imageURL == nil {
            self.simpleAlert(nil, message: "表示する写真がありません", cancelTitle: "OK", completion: nil)
            return
        }
        
        photo!.downloadPhoto({[weak self] (image, error) in
            DispatchQueue.main.async {
                if !Utility.isEmpty(error) || Utility.isEmpty(image) {
                    self?.simpleAlert(nil, message: "画像の表示に失敗しました", cancelTitle: "OK", completion: nil)
                    return
                }
                //slider = PhotoViewController(images: [image!])
                slider = PhotoSlider.ViewController(images: [image!])
                slider?.transitioningDelegate = self
                slider?.modalPresentationStyle = .overCurrentContext
                slider?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                slider?.visiblePageControl = false
                if slider != nil {
                    self?.present(slider!, animated: true, completion: nil)
                }
            }
        })
    }
    
    func showPrifileSettingViewController() {
        let controller: ProfileSettingViewController = ProfileSettingViewController()
        let navi: NavigationController = NavigationController(rootViewController: controller)
        self.present(navi, animated: true, completion: nil)
    }
    
    func showPhotoActionSheet() {
        _ =  RMUniversalAlert.showActionSheet(in: self,
                                              withTitle: nil,
                                              message: nil,
                                              cancelButtonTitle:"キャンセル",
                                              destructiveButtonTitle: nil,
                                              otherButtonTitles: ["写真を撮影","アルバムから選択"],
                                              popoverPresentationControllerBlock: { [weak self] (popover) in
                                                popover.sourceView = self?.view
                                                popover.sourceRect = self!.view.frame
        }) { [weak self] (alert, buttonIndex) in
            DBLog(buttonIndex)

            if buttonIndex != alert.cancelButtonIndex {
                self?.showImagePicker(buttonIndex != alert.firstOtherButtonIndex)
            }
        }
    }

    // ================================================================================
    // MARK: - PhotoSliderDelegate delegate
    
    /**
     PhotoSlider classを参照
      https://github.com/nakajijapan/PhotoSlider
      Swift3.0.1に対応してなかったので、cloneして対応させたやつを使ってますが、基本的には同じです。
     　今は対応されているかもしれません。
     */
    
    open func transitionSourceImageView() -> UIImageView {
        let imageView: UIImageView! = UIImageView()
        imageView.frame = CGRect(x: 0,
                                 y: NavigationHeightCalculator.navigationHeight(),
                                 width: kCommonDeviceWidth,
                                 height: kCommonDeviceWidth)
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        return imageView
    }
    
    open func transitionDestinationImageView(sourceImageView: UIImageView) {
        
    }

     func showImagePicker(_ isAlubum: Bool) {
        let picker: BaseImagePickerController = BaseImagePickerController()
        if isAlubum {
            pickerNavigationBarView = NavigationBarView()
            pickerNavigationBarView?.backgroundColor = kMainGreenColor
            picker.view.addSubview(pickerNavigationBarView!)
            picker.view.bringSubview(toFront: picker.navigationBar)
        }
        picker.view.backgroundColor = UIColor.white
        picker.navigationBar.barTintColor = kMainGreenColor
        picker.sourceType = isAlubum ? .photoLibrary : .camera
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    // ================================================================================
    // MARK: - image picker delegate
    /**
     UIImagePickerControllerのDelegateメソッドです。
     didFinishPickingMediaWithInfoを継承先で使って、写真を選んだあとの処理を書いてます。Baseでdelegateだけ持たせて
     という感じです
     */
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {}
    
    open func navigationController(_ navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count == 3 {
            pickerNavigationBarView?.isHidden = true
        } else {
            pickerNavigationBarView?.isHidden = false
        }
    }
    
    // ================================================================================
    // MARK: - other 
    /**
     reloadTableView()は、tableViewをreloadするだけか、それとも新たにserverから取得してリフレッシュしてtableViewを更新するのか
     という処理をしています
     
     alreadyInTargetView()は結局使ってないメソッドですが、意図としては、例えば、facebookアプリなどで自分の投稿をタップしたとき
    のanimationですね。他人の投稿タップすると他人のユーザーページへ、自分のだと、ポンポンっていうanimationが
     よく他のアプリなどで見かけると思います。あのanimationです
     */
    func reloadTableView() {
        if self.shouldReloadMainView == true {
            self.dataSource?.update()
            self.tableView?.reloadData()
        }
        
        if self.shouldRefreshDataSource == true {
            self.refreshDataSource()
        }
    }
    
    func alreadyInTargetView() {
        UIView.animate(withDuration: 0.15, animations: {[weak self] () -> Void in
            self?.view.x = 8
            }) { (isfinished) -> Void in
                UIView.animate(withDuration: 0.1, animations: {[weak self] () -> Void in
                    self?.view.x = -2
                    }, completion: { (isfinished) -> Void in
                        UIView.animate(withDuration: 0.05, animations: {[weak self] () -> Void in
                            self?.view.x = 2
                            }, completion: { (isfinished) -> Void in
                                UIView.animate(withDuration: 0.01, animations: {[weak self] () -> Void in
                                    self?.view.x = 0
                                })
                        })
                })
        }
    }
    
    override open func scrollToTop() {
        tableView!.setContentOffset(tableView!.contentOffset, animated: false)
        UIView.animate(withDuration: 0.25) {[weak self] () -> Void in
            if let wself = self {
                wself.tableView!.contentInsetTop = wself.pullToRefreshInsetTop()
                wself.tableView!.contentOffsetY = -wself.tableView!.contentInsetTop
            }
        }
    }
    
    /**
     moveContentOffsetWithTargetCellRect()は、targetとなるCellのRectへmoveしています
     登録画面などでキーボードの次へというボタンを押すと、次のcellへ行き、animationするかと思います。
     あのanimationです
    
     */
    func moveContentOffsetWithTargetCellRect(_ targetCellRect: CGRect, index: Int) {
        let movieInset: CGFloat = (index == 0 ? tableView!.contentInsetTop : -tableView!.contentOffsetY) + targetCellRect.origin.y + NavigationHeightCalculator.navigationHeight() + self.additionalMoveFloat()
        UIView.animate(withDuration: 0.25) {[weak self] () -> Void in
            if let wself = self {
                wself.tableView?.contentOffsetY = -movieInset
            }
        }
    }
    
    func additionalMoveFloat() ->CGFloat {
        if UIScreen.is3_5inchDisplay() {
            return 20.0
        } else if UIScreen.is4inchDisplay() {
            return 70.0
        } else if UIScreen.is4_7inchDisplay() {
            return 120.0
        }
        return 170.0
    }

    // ================================================================================
    // MARK: - userIcondelegate
    /**
     UserIconCell Class 参考
     userIconをタップした時の処理です
     
     */
    
    open func didUserIconTapped(_ user: User?) {
        if Me.sharedMe.isRegisterd == false {
            self.showUnRegisterAlert()
            return
        }
        let controller: UserPageViewController = UserPageViewController(user: user)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // ================================================================================
    // MARK: - create chat

    func moveToChatRoom(_ room: ChatRoom, transaction: Transaction?) {
        let controller: ChatRoomViewController = ChatRoomViewController(room: room)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller , animated: true)
    }
    
    func sendMention(_ room: ChatRoom, transaction: Transaction) {
        let controller: ChatRoomViewController = ChatRoomViewController(room: room)
        controller.sendTransaction(transaction) { (error) in
            if error != nil {
                DBLog(error)
                return
            }
            DBLog("sucsess")
        }
    }
    
    func enterChatRoom(withUser user: User, transaction: Transaction?, isCancel: Bool, isSendMension: Bool, completion: ((_ chatRoom: ChatRoom?, _ error: Error?) ->Void)?) {
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.show()

        ChatRoom.createChatRoom(user) { [weak self] (chatRoom: ChatRoom?, error: Error?) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self?.view.isUserInteractionEnabled = true

                if let err = error {
                    if err.errorCodeType == .userBlocked {
                        self?.showBlockUserAlert()
                    } else {
                        self?.simpleAlert(nil, message: err.errorDespription, cancelTitle: "OK", completion: nil)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        completion?(nil, err)
                    }
                } else {
                    if isSendMension {
                        self?.sendMention(chatRoom ?? ChatRoom(), transaction: transaction ?? Transaction())
                    }
                    if !isCancel && !isSendMension {
                        self?.moveToChatRoom(chatRoom ?? ChatRoom(), transaction: transaction)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        completion?(chatRoom, nil)
                    }
                }
            }
        }
    }
    
    func showBlockUserAlert() {
        SVProgressHUD.dismiss()
        _ = RMUniversalAlert.show(in: self,
                                  withTitle: "ブロックユーザーとメッセージすることはできません",
                                  message: "購入後の取引についてのメッセージの場合運営にお問い合わせください", cancelButtonTitle: "OK",
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: ["お問い合わせ"]) {[weak self] (al, index) in
                                    DispatchQueue.main.async {
                                        if index == al.firstOtherButtonIndex {
                                            let controller: ContactViewController = ContactViewController(type: .none, object: nil)
                                            controller.view.clipsToBounds = true
                                            self?.navigationController?.pushViewController(controller, animated: true)
                                        }
                                    }
        }
    }

    func showUserReportMenu(_ user: User, completion: @escaping (_ isBlocked: Bool) ->Void) {

        _ = RMUniversalAlert.showActionSheet(in: self,
                                             withTitle: nil,
                                             message: nil,
                                             cancelButtonTitle: "キャンセル",
                                             destructiveButtonTitle: "ブロック",
                                             otherButtonTitles: ["通報する"],
                                             popoverPresentationControllerBlock: {[weak self] (popover) in
                                                popover.sourceView = self?.view
                                                popover.sourceRect = self!.view!.frame
        }) {[weak self] (al, index) in
            DispatchQueue.main.async {
                if index == al.cancelButtonIndex {
                    completion(false)
                } else if index == al.destructiveButtonIndex {
                    self?.tryBlock(user, completion: { (isBlocked) in
                        DispatchQueue.main.async {
                            self?.view?.isUserInteractionEnabled = true
                            completion(isBlocked)
                        }
                    })
                } else if index == al.firstOtherButtonIndex {
                    self?.reportUser(user, completion: completion)
                }
            }
        }
    }

    static var reportReason: [String] = ["不適切な商品を出品している","不適切なメッセージを送ってくる","詐欺行為をしている","その他悪質行為"]
    func reportUser(_ user: User, completion: @escaping (_ isBlocked: Bool) ->Void) {
        
        if Me.sharedMe.isRegisterd == false {
            self.suggestDetailReport(.user, object: user, completion: completion)
            return
        }
        
        _ = RMUniversalAlert.show(in: self,
                                  withTitle: "通報理由を選択ください",
                                  message: nil,
                                  cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: BaseTableViewController.reportReason) {[weak self] (al, index) in
                                    DispatchQueue.main.async {
                                        if index == al.cancelButtonIndex {
                                            completion(false)
                                            return
                                        }
                                        user.reportUser(BaseTableViewController.reportReason[index - 2], completion: { (error) in
                                            DispatchQueue.main.async {
                                                if error != nil {
                                                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                                                    completion(false)
                                                    return
                                                }
                                                self?.suggestDetailReport(.user, object: user, completion: completion)
                                            }
                                        })
                                    }

        }
    }

    func tryBlock(_ user: User, completion: @escaping (_ isBlocked: Bool) ->Void) {
        if Me.sharedMe.isRegisterd == false {
            self.sucsessAlert("ブロック機能を使うためにはプロフィール登録が必要です", completion: {
                DispatchQueue.main.async {
                    completion(false)
                }
            })
            return
        }

        if Transaction.searchTransactionFromUserId(user.identifier) != nil {
            self.simpleAlert(nil, message: "取引中のユーザーはブロックすることができません", cancelTitle: "OK", completion: nil)
            return
        }
        
        _ = RMUniversalAlert.show(in: self,
                                  withTitle: nil,
                                  message: "ブロックすると相手とのやりとりの全てが削除されます",
                                  cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: "ブロック",
                                  otherButtonTitles: nil) {[weak self] (al, index) in
                                    DispatchQueue.main.async {
                                        if index == al.cancelButtonIndex {
                                            completion(false)
                                        } else if index == al.destructiveButtonIndex {
                                            SVProgressHUD.show()
                                            user.blockUser({ (error) in
                                                DispatchQueue.main.async {
                                                    if error != nil {
                                                        self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)

                                                        completion(false)
                                                        return
                                                    }

                                                    self?.sucsessAlert("ブロックしました！", completion: {
                                                        DispatchQueue.main.async {
                                                            completion(true)
                                                            return
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    }
        }
    }

    func suggestDetailReport(_ reportableType: ReportType, object: BaseModelObject?, completion:((_ isBlocked: Bool) ->Void)?) {
        SVProgressHUD.dismiss()
        _ = RMUniversalAlert.show(in: self,
                                  withTitle: "通報しました！",
                                  message: "複雑な問題を解決するためには詳細な情報も必要です。通報の詳細も通報しますか?",
                                  cancelButtonTitle: "キャンセル",
                                  destructiveButtonTitle: nil,
                                  otherButtonTitles: ["詳細に通報する"]) {[weak self] (al, index) in
                                    DispatchQueue.main.async {
                                        if index >= al.firstOtherButtonIndex {
                                            let controller: ContactViewController = ContactViewController(type: reportableType, object: object)
                                            let navi: NavigationController = NavigationController(rootViewController: controller)
                                            self?.navigationController?.present(navi, animated: true, completion: nil)
                                        }
                                        completion?(false)
                                    }
        }
    }

    func sucsessAlert(_ message: String, completion: (() ->Void)?) {
        SVProgressHUD.dismiss()
        self.simpleAlert(nil, message: message, cancelTitle: "OK") { [weak self] in
            DispatchQueue.main.async {
                if self?.isModal == true {
                    self?.dismiss()
                    if completion != nil {
                        completion!()
                    }
                    return
                }
                self?.popViewController()
                if completion != nil {
                    completion!()
                }
            }
        }
    }
    
    func startEditNextTextField(_ textFieldTag: Int) {
        let nextKeyBoradCellTag: Int = textFieldTag + 1
        var nextKeyBoradCellSection: Int = 0
        
        var targetRow: Int = nextKeyBoradCellTag + 1
        
        if nextKeyBoradCellTag > 3 {
            nextKeyBoradCellSection = 1
            targetRow = nextKeyBoradCellTag - 3
        }
        
        if nextKeyBoradCellTag > 8 {
            nextKeyBoradCellSection = 2
            targetRow = 1
        }
                
        let nextKeyBoradCellIndexPass = IndexPath(item: targetRow, section: nextKeyBoradCellSection)
        let targetCell: BaseTableViewCell? = tableView?.cellForRow(at: nextKeyBoradCellIndexPass) as? BaseTableViewCell
        if targetCell is BaseTextFieldCell {
            (targetCell as? BaseTextFieldCell)?.textField?.becomeFirstResponder()
        }
    }
    
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**
    registerCellClassのcellHeightForObjectを呼んでいます。objectを引数に取ることで、そのobjectの状態に合わせた高さを返す
     処理をしています
     */

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        activeTableViewtag = tableView.tag
        let object: AnyObject? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate:false)
        if object == nil {
            return TableViewLoadMoreCellHeight
        }
        
        let tableViewCellClass = self.registerCellClass() as! BaseTableViewCell.Type
        return tableViewCellClass.cellHeightForObject(object)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count() ?? 0
    }
    
    /**
     registerCellClassのcellを生成して、cellModelObjectにtableViewのarrayに入っているmodelを代入しています
     */

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        activeTableViewtag = tableView.tag
        let object: AnyObject? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate:true)
        var cell: UITableViewCell! = UITableViewCell(frame: CGRect.zero)
        var cellIdentifier: String! = ""
        
        let tableViewCellClass = self.registerCellClass() as! BaseTableViewCell.Type
        
        if object == nil {
            cellIdentifier = TableViewLoadMoreCell.description()
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            if cell == nil {
                cell = TableViewLoadMoreCell()
            }
        }else {
            cellIdentifier = NSStringFromClass(tableViewCellClass)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            if cell == nil {
                cell = tableViewCellClass.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            
            ///ここオプショナルバインディングじゃないと呼ばれない
            if let modelObject = object {
                (cell as! BaseTableViewCell).cellModelObject = modelObject
            }
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activeTableViewtag = tableView.tag
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
