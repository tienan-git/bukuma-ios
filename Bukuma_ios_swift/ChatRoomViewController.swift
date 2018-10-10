//
//  ChatRoomViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/01.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

open class ChatRoomViewController: BaseTableViewController,
MessagePostViewDelegate,
MessageDataSourceDelegate,
MediaMessageCellDelegate,
ChatTransactionListViewControllerDelegate,
BaseMensionCellDelegate,
TextMessageCellDelegate
{
    var postView: MessagePostView?
    var isAllowUpdate: Bool = false
    var shouldAnimation: Bool?
    var room: ChatRoom?
    var mensionView: MensionBookView?
    var mensionMerchandise: Merchandise?
    var shouldSendMerchandise: Bool = false
    var transaction: Transaction?
    
    //initのタイミングではpropertyの監視が効かないので
    fileprivate func setRoom(_ room: ChatRoom) {
        self.title = room.chatUser?.nickName
                
        (self.dataSource as? MessageDataSource)?.room = room
        
        tableView?.reloadData()
        
        isAllowUpdate = true
        shouldAnimation = false
        
    }
    
    // ================================================================================
    // MARK: setting

    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return ""
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return ""
    }
    
    override open func footerHeight() -> CGFloat {
        if postView == nil {
            return 8.0
        }
        if mensionMerchandise != nil && !Utility.isEmpty(mensionMerchandise?.id) {
            return postView!.height + MensionBookView.viewHeight(mensionMerchandise) + 8.0
        }
        return postView!.height + 8.0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return MessageDataSource.self
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = self.room?.chatUser?.nickName
        let  rightButton = BarButtonItem.barButtonItemWithImage(UIImage(named: "tab_head_block")!,
                                                                isLeft: false,
                                                                target: self,
                                                                action: #selector(self.blockUser(_:)))
        self.setNavigationBarButton(rightButton, isLeft: false)
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return nil
    }
    
    // ================================================================================
    // MARK: init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(room: ChatRoom) {
        super.init(nibName: nil, bundle: nil)
        self.room = room
        self.setRoom(room)
        self.isNeedKeyboardNotification = true
    }
    
    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.reloadData()
        self.view.backgroundColor = UIColor.white
        
        postView = MessagePostView.init(delegate: self)
        postView?.y = self.view.height - postView!.height
        self.view.addSubview(postView!)
        
        tableView?.showsPullToRefresh = false
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())
        tableView?.separatorColor = UIColor.clear
        tableView?.separatorStyle = .none
        tableView?.isFixTableScrollWhenChangeContentsSize = true
        tableView?.isFixScrollIndicatorBottom = false
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapView(_:)))
        tapGesture.cancelsTouchesInView = false
        tableView?.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(self.disappearMensionView), name: NSNotification.Name(rawValue: MensionBookViewDisappearNotification), object: nil)

        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scrollToBottom()
        
        postView?.isUserInteractionEnabled = true
        if room?.isClosed == true {
            postView?.isUserInteractionEnabled = false
        }
        
//
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (self.dataSource as? MessageDataSource)?.startUpdate()
        
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        postView?.dismissKeyboard()
    }
    
    override open func refreshDataSource() {}
    
    open func updateOnlyPlaceholderView() {
        tableView?.pullToRefreshView.stopAnimating()
        SVProgressHUD.dismiss()
        //self.tableView.em
    }
    
    override open func completeRequest() {
        super.completeRequest()
        DispatchQueue.main.async {
            
            //self.tableView.em
            self.scrollToBottomIfContentsHaveAppropriateOffset()
            self.shouldAnimation = (self.dataSource?.count() ?? 0) > 0
            self.isAllowUpdate = true
        }
    }
    
    override func keyboardDidShow(_ notification: Foundation.Notification) {}
    
    override func keyboardDidHide(_ notification: Foundation.Notification) {}
    
    // ================================================================================
    // MARK:- tableView
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var isSameDay: Bool = false
        var isSequenced: Bool = false
        
        let message: Message? = self.messageForIndexPath(indexPath, isSameDay: &isSameDay, isSequenced: &isSequenced)
        
        if message == nil {
            return TableViewLoadMoreCellHeight
        }
        
        if message?.messageType == .text {

            return  MessageCell.textCellHeight(message?.text ?? "",
                                               isSameWeekDay: isSameDay,
                                               isSequenced: isSequenced,
                                               lineHeight: 36.0)
            
        } else if  message?.messageType == .image {
            return MediaMessageCell.mediaCellHeight(isSameDay, isSequenced: isSequenced)
        } else if message?.messageType == .merchandise {
            return ChatBookMensionCell.mensionCellHeight(message, isSameDay: isSameDay, isSeqence: isSequenced)
        } else if message?.messageType == .transactionStatusUpdate {
            if message?.itemTrasaction?.type == TransactionListType.sellerShipped {
                return ShippedMensionCell.mensionCellHeight(message, isSameDay: isSameDay, isSeqence: isSequenced)
            } else if message?.itemTrasaction?.type == TransactionListType.buyerItemArried || message?.itemTrasaction?.type == TransactionListType.sellerReviewBuyer {
                return ReviewMensionCell.mensionCellHeight(message, isSameDay: isSameDay, isSeqence: isSequenced)
            } else if message?.itemTrasaction?.type == TransactionListType.sellerPrepareShipping {
                return PurchaseMensionCell.mensionCellHeight(message, isSameDay: isSameDay, isSeqence: isSequenced)
            } else if message?.itemTrasaction?.type == TransactionListType.finishedTransaction || message?.itemTrasaction?.type == TransactionListType.cancelled {
                return FinishMensionCell.mensionCellHeight(message, isSameDay: isSameDay, isSeqence: isSequenced)
            } else if message?.itemTrasaction?.type == TransactionListType.unknown {
                return 0
            }
        }
        return 0
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MessageCell? 
        var cellIdentifier: String! = ""
        
        var isSameDay: Bool = false
        var isSequenced: Bool = false
        
        let message: Message? = self.messageForIndexPath(indexPath, isSameDay: &isSameDay, isSequenced: &isSequenced)
        
        if message?.messageType == .text {
            cellIdentifier = NSStringFromClass(TextMessageCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?TextMessageCell
            if cell == nil {
                cell = TextMessageCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            if message != nil {
                cell?.setMessage(message!, isSameWeekDay: isSameDay, isSequenced: isSequenced)
            }
            
        } else if message?.messageType == .image {
            cellIdentifier = NSStringFromClass(MediaMessageCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?MediaMessageCell
            if cell == nil {
                cell = MediaMessageCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            if message != nil {
                cell?.setMessage(message!, isSameWeekDay: isSameDay, isSequenced: isSequenced)
            }
        } else if message?.messageType == .merchandise {
            
            cellIdentifier = NSStringFromClass(ChatBookMensionCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ChatBookMensionCell
            if cell == nil {
                cell = ChatBookMensionCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            if message != nil {
                cell?.setMessage(message!, isSameWeekDay: isSameDay, isSequenced: isSequenced)
            }
        } else if message?.messageType == .transactionStatusUpdate {
            
            if message?.itemTrasaction?.type == TransactionListType.sellerShipped {
                cellIdentifier = NSStringFromClass(ShippedMensionCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ShippedMensionCell
                if cell == nil {
                    cell = ShippedMensionCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                if message != nil {
                    (cell as? ShippedMensionCell)?.setMessage(message!, isSameWeekDay: isSameDay, isSequenced: isSequenced)
                }
            }  else if message?.itemTrasaction?.type == TransactionListType.buyerItemArried ||
                message?.itemTrasaction?.type == TransactionListType.sellerReviewBuyer {
                cellIdentifier = NSStringFromClass(ReviewMensionCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ReviewMensionCell
                if cell == nil {
                    cell = ReviewMensionCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                if message != nil {
                    (cell as? ReviewMensionCell)?.setMessage(message!, isSameWeekDay: isSameDay, isSequenced: isSequenced)
                }
            } else if message?.itemTrasaction?.type == TransactionListType.sellerPrepareShipping {
                cellIdentifier = NSStringFromClass(PurchaseMensionCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?PurchaseMensionCell
                if cell == nil {
                    cell = PurchaseMensionCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                if message != nil {
                    (cell as? PurchaseMensionCell)?.setMessage(message!, isSameWeekDay: isSameDay, isSequenced: isSequenced)
                }
            } else if message?.itemTrasaction?.type == TransactionListType.finishedTransaction || message?.itemTrasaction?.type == TransactionListType.cancelled {
                cellIdentifier = NSStringFromClass(FinishMensionCell.self)
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?FinishMensionCell
                if cell == nil {
                    cell = FinishMensionCell.init(reuseIdentifier: cellIdentifier, delegate: self)
                }
                
                if message != nil {
                    (cell as? FinishMensionCell)?.setMessage(message!, isSameWeekDay: isSameDay, isSequenced: isSequenced)
                }
            }
        }
        
        var user: User?
        if message?.isMine == true {
            user = Me.sharedMe
        } else {
            user = room?.members?.filter({ (member) -> Bool in
                
                return member.identifier == cell?.message?.senderIdentifier
            }).first
        }
        
        cell?.cellModelObject = user
        return cell ?? UITableViewCell()
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        postView?.dismissKeyboard()
        
        let cell: MessageCell? = tableView.cellForRow(at: indexPath) as? MessageCell
        var isSameDay: Bool = false
        var isSequenced: Bool = false
        
        let message: Message? = self.messageForIndexPath(indexPath, isSameDay: &isSameDay, isSequenced: &isSequenced)
        
        if cell?.sendingStatus == .failed && cell != nil {
            self.resendOrDeleteCell(cell!)
        }
        
        if message?.messageType == .merchandise {
            if !Utility.isEmpty(message?.merchandise?.book?.identifier) {
                self.goDetailBook(message?.merchandise?.book ?? Book(), completion: nil)
            }
        }
        
        if message?.messageType == MessageType.transactionStatusUpdate {
            self.goTransaction(message)
        }
    }
    
    // ================================================================================
    // MARK:- gesture
    
    func tapView(_ sender: UITapGestureRecognizer) {
        postView?.dismissKeyboard()
    }
    
    // ================================================================================
    // MARK:- Animation Medhods
    
    func blockUser(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        if room?.chatUser == nil {
            self.simpleAlert(nil, message: "すでにユーザーがいません", cancelTitle: "OK", completion: nil)
            return
        }
        self.tryBlock(room!.chatUser!) {[weak self] (isBlocked) in
            DispatchQueue.main.async {
                if !isBlocked {
                    self?.view.isUserInteractionEnabled = true
                    SVProgressHUD.dismiss()
                    return
                }                
                self?.room?.deleteChatRoom({ (error) in
                    DispatchQueue.main.async {
                        self?.view.isUserInteractionEnabled = true
                        if error != nil {
                             self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                            return
                        }
                        SVProgressHUD.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                            self?.popViewController()
                            return
                        })
                    }
                })
            }
        }
    }
    
    func scrollToBottom() {
        if (self.dataSource?.count() ?? 0) > 0 {
            tableView!.reloadData()
            tableView!.scrollToRow(at: IndexPath.init(row: self.dataSource!.count()! - 1, section: 0),
                                   at: .top,
                                                  animated: false)
        }
    }
    
    func scrollToBottomIfContentsHaveAppropriateOffset() {
        if (tableView?.contentOffsetY ?? 0) + self.view.height + 50 > (tableView?.contentSize.height)! {
            self.scrollToBottom()
        }
    }
    
    // ================================================================================
    // MARK:- imagePicker
    
    override open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            if let img = (info[UIImagePickerControllerEditedImage] as? UIImage)?.resizeImageFromImageSize(CGSize(width: 200, height: 200)) {
                self.sendImage(img, completion: { (error) in
                    
                })
            }
        }
    }
    
    open func mediaMessageCellMediaButtonTapped(_ cell: MediaMessageCell) {
        var photo: Photo?
        if cell.message?.imageUrl != nil {
            photo = Photo(imageUrl: cell.message?.imageUrl)
        } else {
            photo = Photo(image: cell.message?.image)
        }
        self.showPhoto(photo)
    }
    
    override open func showPhoto(_ photo: Photo?) {
        super.showPhoto(photo)
    }
    // ================================================================================
    // MARK:-
    
    fileprivate func messageForIndexPath(_ indexPath: IndexPath, isSameDay: inout Bool, isSequenced: inout Bool) ->Message? {
        let message: Message? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Message
        var oldMessage: Message?
        if indexPath.row - 1 >= 0 {
            oldMessage = self.dataSource?.dataAtIndex(indexPath.row - 1, isAllowUpdate: false) as? Message
        }
        
        if oldMessage == nil || oldMessage?.date == nil {
            isSameDay = false
            isSequenced = false
            return message
        }
        
        if message?.date == nil {
            isSameDay = false
            isSequenced = false
            return message
        }
        
        isSameDay = message!.date!.isEqualToDateIgnoringTime(otherDate: oldMessage!.date!)
        isSequenced = message!.senderIdentifier == oldMessage!.senderIdentifier
        return message
    }
    
    static var faildCounter: Int = 0
    
    fileprivate func sendMessage(_ message: Message, completion: @escaping (_ error: Error?) ->Void) {
        (self.dataSource as? MessageDataSource)?.stopUpdate()
        let newestMessage: Message? = self.dataSource?.firstData() as? Message
        
        (self.dataSource as? MessageDataSource)?.addMessage(message)
        
        tableView?.beginUpdates()
        tableView?.insertRows(at: [IndexPath(row: self.dataSource!.count()! - 1, section: 0)], with: .none)
        tableView?.endUpdates()
        
        self.scrollToBottomIfContentsHaveAppropriateOffset()
        let cell: MessageCell? = tableView?.cellForRow(at: IndexPath(row: self.dataSource!.count()! - 1, section: 0)) as? MessageCell
        cell?.sendingStatus = .sending
        message.sendingFaild = false
        
        self.mensionView?.disappear(nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
            message.sendMessage({[weak self] (id, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                        cell?.sendingStatus = .failed
                        message.sendingFaild = true
                        self?.tableView?.reloadData()
                        
                        if error?.errorCodeType == .userBlocked {
                            (self?.dataSource as? MessageDataSource)?.cancelUpdate()
                            self?.room?.deleteChatRoom(nil)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                                self?.popViewController()
                                completion(error)
                            })
                        } else if error?.errorCodeType == .chatRoomNotFound {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                                self?.popViewController()
                                completion(error)
                            })
                        }
                        
                        (self?.dataSource as? MessageDataSource)?.cancelUpdate()
                        
                        completion(error)
                        
                    } else {
                        cell?.sendingStatus = .complete
                        message.sendingFaild = false
                        message.id = id
                        message.chatOrder = Double(id ?? "")
                    
                        if newestMessage == nil {
                            self?.tableView?.reloadData()
                        } else {
                            (self?.dataSource as? MessageDataSource)?.getNewMessages(newestMessage!.id!)
                        }
                    }
                    (self?.dataSource as? MessageDataSource)?.startUpdate()
                    completion(error)
                }
                })
        })
    }
    
    // ================================================================================
    // MARK:- ChatTransactionListViewController delegate and releated function
    
    open func chatTransactionListViewControllerMensionTapped(_ viewController: ChatTransactionListViewController, merchandise: Merchandise?) {
        self.showMensionView(merchandise)
    }

    func disappearMensionView() {
        shouldSendMerchandise = false
        mensionMerchandise = nil
        
        tableView?.contentInsetBottom = postView!.height + 10.0
        tableView?.scrollIndicatorInsets.bottom = postView!.height
        
        scrollToBottomIfContentsHaveAppropriateOffset()
    }
    
    func showMensionView(_ merchandise: Merchandise?) {
        if mensionView == nil {
            mensionView = MensionBookView()
            self.view.insertSubview(mensionView!, belowSubview: postView!)
        }
        
        shouldSendMerchandise = true
        mensionMerchandise = merchandise
        
        mensionView?.alpha = 1.0
        mensionView?.merchandise = merchandise
        mensionView?.y = kCommonDeviceHeight - MensionBookView.viewHeight(merchandise) - postView!.height
        tableView?.contentInsetBottom = postView!.height + 10.0 + MensionBookView.viewHeight(mensionView?.merchandise)
        tableView?.scrollIndicatorInsets.bottom = postView!.height + MensionBookView.viewHeight(mensionView?.merchandise)
        
        scrollToBottomIfContentsHaveAppropriateOffset()
    }
    
    // ================================================================================
    // MARK:- MensionCell delegate and releated function
    
    open func baseMensionCellActionButtonTapped(_ message: Message) {
        self.goTransaction(message)
    }
    
    open func sendTransaction(_ transaction: Transaction, completion: @escaping (_ error: Error?) -> Void) {
        var message: Message?
        
        message = Message(message: nil, image: nil, videoLocalUrl: nil, merchandise: nil, transaction: transaction, roomIdentifier: room?.id, date:  NSDate(), messageType: .transactionStatusUpdate)
        message?.itemTrasaction = transaction
        message?.text = message?.textForTransactionMension(transaction)
        if message != nil {
            self.sendMessage(message!, completion: completion)
        } else {
            completion(nil)
        }
    }
    
    fileprivate func goTransaction(_ message: Message?) {
        if message?.itemTrasaction?.id != nil {
            self.view.isUserInteractionEnabled = false
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            
            SVProgressHUD.show()
            Transaction.getItemTransactionInfoFromId(message?.itemTrasaction?.id ?? "",
                                                     completion: { (transaction, error) in
                                                        DispatchQueue.main.async {
                                                            self.view.isUserInteractionEnabled = true
                                                            self.navigationItem.leftBarButtonItem?.isEnabled = true
                                                            SVProgressHUD.dismiss()
                                                            if error != nil || message?.itemTrasaction == nil {
                                                                self.simpleAlert(nil, message: "該当する取引を取得できませんでした", cancelTitle: "OK", completion: nil)
                                                                return
                                                            }
                                                            let controller: ShippingProgressTableViewController = ShippingProgressTableViewController(transaction: transaction ?? Transaction())
                                                            controller.view.clipsToBounds = true
                                                            self.navigationController?.pushViewController(controller, animated: true)
                                                        }
            })
        }
    }
    
    // ================================================================================
    // MARK:- MessagePostView delegate
    
    open func showCameraMenu(_ completion:@escaping () -> Void) {
        postView?.dismissKeyboard()
        if shouldSendMerchandise == true {
            self.simpleAlert(nil, message: "画像を本のメンションと同時に送ることはできません", cancelTitle: "OK", completion: nil)
            completion()
            return
        }
        
        self.showPhotoActionSheet()
        completion()
    }
    
    open func sendTetxt(_ text: String?, completion: @escaping (_ error: Error?) -> Void) {
        var message: Message?
        
        if shouldSendMerchandise == true {
           message = Message(message: text, image: nil, videoLocalUrl: nil, merchandise: mensionMerchandise, transaction: nil, roomIdentifier: room?.id, date:  NSDate(), messageType: .merchandise)
        } else {
           message = Message(message: text, image: nil, videoLocalUrl: nil, merchandise: nil, transaction: nil, roomIdentifier: room?.id, date:  NSDate(), messageType: .text)
        }
        if message != nil {
            self.sendMessage(message!, completion: completion)
        } else {
            completion(nil)
        }
    }
    
    open func showMensionList(_ completion: @escaping () ->Void) {
        let controller: ChatTransactionListViewController = ChatTransactionListViewController(opponent: room?.chatUser, delegate: self)
        let navi: NavigationController = NavigationController(rootViewController: controller)
        self.present(navi, animated: true, completion: completion)
    }
    
    func sendImage(_ image: UIImage, completion: @escaping (_ error: Error?) ->Void) {
        let message: Message? = Message(message: nil,
                                        image: image,
                                        videoLocalUrl: nil,
                                        merchandise: nil,
                                        transaction: nil,
                                        roomIdentifier: room?.id,
                                        date:  NSDate(),
                                        messageType: .image)
        if message != nil {
            self.sendMessage(message!, completion: completion)
        } else {
            completion(nil)
        }
    }
    
    func resendOrDeleteCell(_ cell: MessageCell) {
        let message: Message? = cell.message
        RMUniversalAlert.showActionSheet(in: self,
                                         withTitle: nil,
                                         message: nil,
                                         cancelButtonTitle: "キャンセル",
                                         destructiveButtonTitle: "削除する",
                                         otherButtonTitles: ["再送する"], popoverPresentationControllerBlock: { (popover) in
                                            popover.sourceView = self.view
                                            popover.sourceRect = self.rectOfCellInSuperview(withCell: cell)
        }) {[weak self] (al, index) in
            DispatchQueue.main.async {
                if index == al.destructiveButtonIndex {
                    (self?.dataSource as? MessageDataSource)?.removeFailedMessage(message ?? Message())
                    self?.tableView?.reloadData()
                    self?.tableView?.layoutIfNeeded()
                    (self?.dataSource as? MessageDataSource)?.startUpdate()
                } else if index == al.firstOtherButtonIndex {
                    message?.sendingFaild = false
                    (self?.dataSource as? MessageDataSource)?.removeFailedMessage(message ?? Message())
                    self?.tableView?.reloadData()
                    self?.tableView?.layoutIfNeeded()
                    self?.sendMessage(message ?? Message(), completion: { (error) in

                    })
                }
            }
        }
    }

    private func rectOfCellInSuperview(withCell cell: UITableViewCell) -> CGRect {
        if let tableView = self.tableView,
            let indexPath = tableView.indexPath(for: cell),
            let superView = tableView.superview {
            let rectOfCellInTableView: CGRect = tableView.rectForRow(at: indexPath)
            let rectOfCellInSuperview: CGRect = tableView.convert(rectOfCellInTableView, to: superView)
            return rectOfCellInSuperview
        }
        return CGRect.zero
    }

    public func textMessageCell(cell: TextMessageCell) {

        postView?.dismissKeyboard()

        RMUniversalAlert.showActionSheet(in: self,
                                         withTitle: "文章をコピーしますか?",
                                         message: nil,
                                         cancelButtonTitle: "キャンセル",
                                         destructiveButtonTitle: nil,
                                         otherButtonTitles: ["コピーする"],
                                         popoverPresentationControllerBlock: { (poper) in
                                            poper.sourceView = self.view
                                            poper.sourceRect = self.rectOfCellInSuperview(withCell: cell)
        }) { (alert, index) in
            DispatchQueue.main.async {
                if index == alert.cancelButtonIndex {

                } else {
                    let pb = UIPasteboard.general
                    pb.setValue(cell.message?.text ?? "", forPasteboardType: "public.utf8-plain-text")
                }
            }
        }
    }

    open func changeHeight(_ height: CGFloat) {
        postView!.y = kCommonDeviceHeight - height - (NavigationHeightCalculator.isTethering() ? 20 : 0)
        
        if mensionView?.merchandise != nil && !Utility.isEmpty(mensionView?.merchandise?.id) {
            mensionView?.y = kCommonDeviceHeight - MensionBookView.viewHeight(mensionView?.merchandise) - postView!.height
            tableView?.contentInsetBottom = postView!.height + 10.0 + MensionBookView.viewHeight(mensionView?.merchandise)
            tableView?.scrollIndicatorInsets.bottom = postView!.height + MensionBookView.viewHeight(mensionView?.merchandise)
        } else {
            tableView?.contentInsetBottom = postView!.height + 10.0
            tableView?.scrollIndicatorInsets.bottom = postView!.height
        }
    
        self.scrollToBottomIfContentsHaveAppropriateOffset()
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isAllowUpdate == true && (dataSource?.isMoreDataSourceAvailable ?? false) == true && (dataSource?.count() ?? 0) > 1 && scrollView.contentOffsetY < -NavigationHeightCalculator.navigationHeight() {
            isAllowUpdate = false            
            
            (dataSource as? MessageDataSource)?.getOldMessages()
        }
    }
    
    override func goDetailBook(_ book: Book, completion: (() ->Void)?) {
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.show()

        Book.getBookInfoFromID(book.identifier ?? "") { [weak self] (book, error) in
            if book != nil {
                DetailPageTableViewController.generate(for: book) { (generatedViewController: DetailPageTableViewController?) in
                    guard let viewController = generatedViewController else {
                        SVProgressHUD.dismiss()
                        self?.view.isUserInteractionEnabled = true
                        completion?()
                        return
                    }
                    self?.navigationController?.pushViewController(viewController, animated: true)

                    SVProgressHUD.dismiss()
                    self?.view.isUserInteractionEnabled = true
                    completion?()
                }
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self?.view.isUserInteractionEnabled = true
                    completion?()
                }
            }
        }
    }
}
