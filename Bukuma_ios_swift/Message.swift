//
//  Message.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/01.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

public enum MessageType: Int {
    case text
    case image
    case merchandise
    case transactionStatusUpdate
    
    mutating func typeFromParameter(_ string: String) {
        switch string {
        case "image":
            self = .image
            break
        case "text":
            self = .text
            break
        case "merchandise":
            self = .merchandise
            break
        case "status_update":
            self = .transactionStatusUpdate
            break
        default:
          break
        }
    }
}

/**
 Message Object
 */
open class Message: BaseModelObject {
    var id: String? /// id
    var roomIdentifier: String? ///Messageが属しているChatRoomのID
    var text: String? /// messageのtext
    var date: NSDate? /// いつ送ったか
    var senderIdentifier: String? /// 送った人のuser id
    var image: UIImage? /// messageのimage
    var imageUrl: URL? /// messageのimageURL
    var chatOrder: Double? /// dbから検索する時に使ってる
    var isOldest: Int? = 0 ///一番古いMessageかどうか
    var merchandise: Merchandise? ///messageのMerchandise
    var itemTrasaction: Transaction? /// messageのTransaction
    
    var isMine: Bool? {
        get {
            return Me.sharedMe.identifier == senderIdentifier /// 自分のMessageかどうか
        }
    }
    var messageType: MessageType? /// message
    var sendingFaild: Bool = false
    var sender: User? ///messageを送ったuser
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        
        attributes?["created_at"].map{String(describing: $0)}.flatMap{Int($0)}.flatMap{Double($0)}.map{date = NSDate(timeIntervalSince1970: $0)}
        
        text = attributes?["text"].map{String(describing: $0)}
        id = attributes?["id"].map{String(describing: $0)}
        
        merchandise = Merchandise(dictionary: attributes?["merchandise"] as? [String: AnyObject])
        itemTrasaction = Transaction(dictionary: attributes?["item_transaction"] as? [String: AnyObject])
        itemTrasaction?.type?.typeFromParameter(text)
        
        if Utility.isEmpty(id) == false {
            chatOrder = Double(Int(id!)!)
        }
        
        senderIdentifier = (attributes?["user"] as? [String: AnyObject])?["id"].map{String(describing: $0)}
        let messageType: String? = attributes?["message_type"].map{String(describing: $0)}
        
        if let type = messageType {
            self.messageType = MessageType(rawValue: 0)
            self.messageType?.typeFromParameter(type)
            
            if self.messageType == .image {
                attributes?["attachment"].map{imageUrl = URL(string: String(describing: $0))}
            }
        }
    }

    public convenience init(attributes: [String: AnyObject]?, roomIdentifier: String?) {
        self.init(dictionary: attributes)
        self.roomIdentifier = roomIdentifier
    }

    public convenience init(DBAttributes: [String: AnyObject]?) {
        self.init(dictionary: nil)
        
        id = DBAttributes?["id"].map{String(describing: $0)}
       
        messageType = MessageType(rawValue:  DBAttributes?["type"] as? Int ?? 0)
        
        DBAttributes?["chat_order"].map{chatOrder = Double.init($0 as! Int)}
        roomIdentifier = DBAttributes?["room_id"].map{String(describing: $0)}
        DBAttributes?["created_at"].map{String(describing: $0)}.flatMap{Int($0)}.flatMap{Double($0)}.map{date = NSDate(timeIntervalSince1970: $0)}
        
        senderIdentifier = DBAttributes?["user_id"].map{String(describing: $0)}
        text = DBAttributes?["text"].map{String(describing: $0)}
        isOldest = DBAttributes?["is_oldest_message"] as? Int
        
        if messageType == .image {
            DBAttributes?["image_path"].map{imageUrl = URL(string: String(describing: $0))}
        }
        
        if messageType == .merchandise {
            merchandise = merchandiseFromDB(DBAttributes)
            if merchandise?.book?.title == nil || merchandise?.book?.title == "" {
                Merchandise.getMerchandiseInfo(merchandise?.id ?? "",
                                               completion: { (merc, error) in
                                                self.merchandise?.book = merc?.book
                                               _ =  Message.saveAll([self])
                })
            }
        }
        
        if messageType == .transactionStatusUpdate {
            itemTrasaction = transactionFromDB(DBAttributes)
            
            if itemTrasaction?.merchandise?.book?.title == nil || itemTrasaction?.merchandise?.book?.title == "" {
                Merchandise.getMerchandiseInfo(itemTrasaction?.merchandise?.id ?? "",
                                               completion: { (merc, error) in
                                                self.itemTrasaction?.merchandise = merc
                                                _ =  Message.saveAll([self])
                })
            }
        }
    }
    
    /// merchandiseをDBから取得して生成
    func merchandiseFromDB(_ attributes: [String: AnyObject]?) ->Merchandise? {
        
        if (attributes?["merchandise_id"] as? String) == "-1" || attributes?["merchandise_id"] == nil {
            return nil
        }
        
        let merchandise: Merchandise? = Merchandise()
        merchandise?.id = attributes?["merchandise_id"].map{String(describing: $0)}
        merchandise?.price = attributes?["merchandise_price"].map{String(describing: $0)}
            
        merchandise?.book = Book()
        merchandise?.book?.title = attributes?["merchandise_book_title"].map{String(describing: $0)}
        merchandise?.book?.coverImage = CoverImage()
        _ = attributes?["merchandise_book_imgUrl"].map{ merchandise?.book?.coverImage?.url =  URL(string: String(describing: $0)) }
        merchandise?.book?.identifier = attributes?["merchandise_book_id"].map{String(describing: $0)}
        return merchandise
    }

    /// TransactionをDBから取得して生成
    func transactionFromDB(_ attributes: [String: AnyObject]?) ->Transaction? {
        
        if (attributes?["item_transaction_id"] as? String) == "-1" || attributes?["item_transaction_id"] == nil {
            return nil
        }
                
        let transaction: Transaction? = Transaction()
        transaction?.id = attributes?["item_transaction_id"].map{String(describing: $0)}
        transaction?.type = TransactionListType(rawValue:  attributes?["item_transaction_status"] as? Int ?? 0)
        transaction?.merchandise = Merchandise()
        transaction?.merchandise?.id = attributes?["item_transaction_merchandise_id"].map{String(describing: $0)}
        transaction?.merchandise?.price =  attributes?["item_transaction_price"].map{String(describing: $0)}
        transaction?.merchandise?.book = Book()
        transaction?.merchandise?.book?.title = attributes?["item_transaction_title"].map{String(describing: $0)}
        transaction?.merchandise?.book?.coverImage = CoverImage()
         _ = attributes?["item_transaction_imgUrl"].map{ transaction?.merchandise?.book?.coverImage?.url =  URL(string: String(describing: $0)) }
                
        return transaction
    }
    
    /// textを送るときにparameter
    var textMessageParames: [String: Any] {
        get {
            var params: [String: Any] = [:]
            params["text"] = self.text
            params["message_type"] = "text"
            return params
        }
    }
    
    /// merchandiseを送るときにparameter
    var merchandiseMessageParames: [String: Any] {
        get {
            var params: [String: Any] = [:]
            params["text"] = self.text
            params["message_type"] = "merchandise"
            params["merchandise_id"] = self.merchandise?.id
            return params
        }
    }
    
    /// transactionを送るときにparameter
    var transactionMessageParams: [String: Any] {
        get {
            var params: [String: Any] = [:]
            params["message_type"] = "status_update"
            params["item_transaction_id"] = self.itemTrasaction?.id
            params["text"] = self.text
            return params
        }
    }
    
    ///transaction mensionを送る時、の問題として、
    ///transactionが送ったときと、typeが変わってしまうという問題があります。
    ///例えば、本を購入しましたというmensionを送ったとすると、その時のtypeはseller_prepareですが、発送完了mensionを送ったとき、
    ///typeはseller_shippedとなってしまいます。私たちが表示したいのは、今の状態ではなくて、買ったときのtypeを表示したいので、message
    ///のtextとして、typeを送ってそれで判別している
    func textForTransactionMension(_ transaction: Transaction?) ->String? {
        if transaction == nil {
            return nil
        }
    
        var status: String = ""
                
        if transaction?.type == TransactionListType.initial {
            status = "initial"
        } else if transaction?.type == TransactionListType.sellerPrepareShipping {
            status = "seller_prepare"
        } else if transaction?.type == TransactionListType.sellerShipped {
            status = "seller_shipped"
        } else if transaction?.type == TransactionListType.buyerItemArried {
            status = "buyer_item_arrived"
        } else if transaction?.type == TransactionListType.sellerReviewBuyer {
            status = "seller_review_buyer"
        } else if transaction?.type == TransactionListType.finishedTransaction {
            status = "finished"
        } else if transaction?.type == TransactionListType.cancelled {
            status = "cancelled"
        }
        return status
    }
    
    public convenience init?(message: String?, image: UIImage?, videoLocalUrl: URL?, merchandise: Merchandise?, transaction: Transaction?, roomIdentifier: String?, date: NSDate?, messageType: MessageType?) {
        DBLog(roomIdentifier)
        
        if Utility.isEmpty(roomIdentifier) {
            DBLog("roomIdentifierが空")
            return nil
        }
        self.init(dictionary: nil)
        self.roomIdentifier = roomIdentifier
        self.image = image
        self.messageType = messageType
        self.date = date
        self.text = message
        self.merchandise = merchandise
        self.itemTrasaction = transaction
        self.senderIdentifier = Me.sharedMe.identifier
        
    }
    
    open func sendMessage(_ completion: @escaping (_ id: String?, _ error: Error?) ->Void) {
        
        if Utility.isEmpty(roomIdentifier) {
            completion(nil, nil)
            return
        }
        switch self.messageType! {
        case .text, .merchandise:
            
            var params: [String: Any] = [:]
            
            if self.messageType == .text {
                params = textMessageParames
            } else if self.messageType == .merchandise {
                params = merchandiseMessageParames
            }
            
            DBLog(params)
            
            DBLog(roomIdentifier)
            
            ApiClient.sharedClient.POST("v1/chat_rooms/\(roomIdentifier!)/messages/new",
                                        parameters: params,
                                        completion: { (responceObject, error) in
                                            if error == nil {
                                                DBLog(responceObject)
                                                
                                                if self.messageType == .text {
                                                    AnaliticsManager.sendAction("send_message",
                                                                                actionName: "send_message_text",
                                                                                label: "",
                                                                                value: 1,
                                                                                dic: [:])
                                                } else if self.messageType == .merchandise {
                                                    AnaliticsManager.sendAction("send_message",
                                                                                actionName: "send_message_merchandise",
                                                                                label: "",
                                                                                value: 1,
                                                                                dic: [:])
                                                }
                                                
                                                
                                                completion(responceObject!["id"].map{String(describing: $0)}, nil)
                                            } else {
                                                DBLog(error)
                                                completion(nil, error)
                                            }
            })
            break
        case .image:
            var params: [String: Any] = [:]
            params["message_type"] = "image"
            
            var images: [(name: String, fileName: String, image: UIImage)]? = []
            
            if self.image != nil {
                images?.append((name: "attachment", fileName: "image.jpg", image: self.image!))
            }
            
            ApiClient.sharedClient.POST("v1/chat_rooms/\(roomIdentifier!)/messages/new",
                                        parameters: params,
                                        iconImages: images,
                                        completion: { (responceObject, error) in
                                            if error == nil {
                                                DBLog(responceObject)
                                                AnaliticsManager.sendAction("send_message",
                                                                            actionName: "send_message_image",
                                                                            label: "",
                                                                            value: 1,
                                                                            dic: [:])
                                                completion(responceObject!["id"].map{String(describing: $0)}, nil)
                                                
                                            } else {
                                                DBLog(error)
                                                completion(nil, error)
                                            }
            })

            break
        case .transactionStatusUpdate:
            DBLog(transactionMessageParams)
            
            ApiClient.sharedClient.POST("v1/chat_rooms/\(roomIdentifier!)/messages/new",
                                        parameters: transactionMessageParams,
                                        completion: { (responceObject, error) in
                                            if error == nil {
                                                DBLog(responceObject)
                                                
                                                AnaliticsManager.sendAction("send_message",
                                                                            actionName: "send_message_item_transaction",
                                                                            label: "",
                                                                            value: 1,
                                                                            dic: [:])
                                                completion(responceObject!["id"].map{String(describing: $0)}, nil)
                                            } else {
                                                DBLog(error)
                                                completion(nil, error)
                                            }
            })
            break
        }
    }
    
    open func read() {        
        if Utility.isEmpty(roomIdentifier) {
            return
        }
        
        ApiClient.sharedClient.POST("v1/chat_rooms/\(self.idString(roomIdentifier))/messages/\(self.idString(id))/read",
                                    parameters: self.textMessageParames,
                                    completion: { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                        } else {
                                            DBLog(error)
                                            
                                        }
        })
    }
    
    open class func getMessages(_ fromId: String,
                                  toId: String,
                                  page: Int,
                                  numOfMessages: Int,
                                  roomIdentifier: String,
                                  completion:@escaping (_ messages:[Message]?, _ error: Error?) ->Void) {
        
        var lastMessage: Message?
        if toId != "-1" {
            
            let messages: [Message]? = self.getCachedChatsWithNumOfChats(numOfMessages,
                                                                         roomIdentifier: roomIdentifier,
                                                                         messageId: toId)
            lastMessage = messages?.last
            
            DBLog(lastMessage?.isOldest)
            
            if messages?.count != 0 {
                completion(messages, nil)
                if messages?.count == numOfMessages || lastMessage?.isOldest == 1 {
                    return
                }
            }
        }
        
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = numOfMessages
        
        if fromId != "-1" {
            params["from_id"] = fromId
        }
        
        if toId != "-1" {
            if lastMessage != nil {
                DBLog("lastMessage.id :\(String(describing: lastMessage?.id))")
                params["to_id"] = lastMessage?.id
            } else {
                params["to_id"] = toId 
            }
        }
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/chat_rooms/\(roomIdentifier)/messages",
                                   parameters: params,
                                   completion: { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        if responceObject?["messages"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        var messages: [Message]? = []
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["messages"]!).arrayObject
                                        
                                        for message in jsonArray as! [[String: AnyObject]] {
                                            let message: Message = Message(attributes: message, roomIdentifier: roomIdentifier)
                                            messages!.append(message)
                                        }
                                        
                                        if (messages?.count ?? 0) > 0 {
                                           _ = self.saveAll(messages!)
                                        }
                                        
                                        completion(messages, nil)
                                        
                                    } else {
                                        completion(nil, error)
                                    }
        })
    }
    
    class func isFirstMension(_ roomId: String?, merchandiseId: String?) ->Bool {
        if roomId == nil || merchandiseId == nil {
            return false
        }
        if Message.cachedMessagesList(roomId!) == nil {
            return false
        }
        
        var isFirstMension: Bool = true
        DBLog(Message.cachedMessagesList(roomId!))
        for message in Message.cachedMessagesList(roomId!)! {
            if message.merchandise?.id == merchandiseId {
                isFirstMension = false
            }
        }
        
        return isFirstMension
    }

    open class func getCachedChatsWithNumOfChats(_ numOfChats: Int, roomIdentifier: String, messageId: String) ->[Message]? {
        let membersSql: String = "SELECT * FROM \(chatsTableName) WHERE room_id = ? AND id < ? ORDER BY chat_order DESC LIMIT ? OFFSET ?"
        let localChats: [AnyObject]? = FMDBManager.sharedManager.executeQuery(membersSql, args: [roomIdentifier as AnyObject, messageId as AnyObject, numOfChats as AnyObject, 0 as AnyObject])
        if localChats == nil {
            return nil
        }
        let localChatsDic = localChats as! [[String: AnyObject]]
        let messages: [Message] = localChatsDic.map { (dic) in
            let message: Message = Message(DBAttributes: dic)
            return message
        }
        return messages
    }
    
    open class func cachedMessagesList(_ roomId: String) ->[Message]? {
        let membersSql: String = "SELECT * FROM \(chatsTableName) WHERE room_id = ? ORDER BY chat_order DESC LIMIT ? OFFSET ?"
        
        let localChats: [AnyObject]? = FMDBManager.sharedManager.executeQuery(membersSql, args: [roomId as AnyObject, 100 as AnyObject, 0 as AnyObject])
        if localChats == nil {
            return nil
        }
        let localChatsDic = localChats as! [[String: AnyObject]]
        
        let messages: [Message] = localChatsDic.map { (dic) in
            let message: Message = Message(DBAttributes: dic)
            return message
        }
        return messages
    }
    
    class func saveAll(_ messages: [Message]) ->Bool {
        var sqls: [String] = []
        var args: [Any] = []
        
        for message in messages {
            
            if Utility.isEmpty(message.text) {
                message.text = ""
            }
            
            if message.imageUrl == nil {
                message.imageUrl = URL(string: "")
            }
            
            if Utility.isEmpty(message.date) ||
                Utility.isEmpty(message.roomIdentifier) ||
                (message.messageType == .text && Utility.isEmpty(message.text)) {
                DBLog("save error")
                return false
            }
            
            let messageId: String = message.id ?? "-1"
            let roomId: String = message.roomIdentifier ?? "-1"
            let senderId: String = message.senderIdentifier ?? "-1"
            let messageText: String = message.text ?? ""
            let isOldest: Int = message.isOldest ?? 0
            
            let messageImgUrl: URL = message.imageUrl ?? URL(fileURLWithPath: "")
            
            let merchandiseId: String = message.merchandise?.id ?? "-1"
            let bookTitle: String = message.merchandise?.book?.titleText() ?? "-1"
            let price: String = message.merchandise?.price ?? "-1"
            let bookImgUrl: String = message.merchandise?.book?.coverImage?.url?.absoluteString ?? "-1"
            let bookId: String = message.merchandise?.book?.identifier ?? "-1"
            let itemTransactionId: String = message.itemTrasaction?.id ?? "-1"
            var type: TransactionListType = TransactionListType.initial
            type.typeFromParameter(message.text)
            let itemTransactionStatus: TransactionListType? = type
            
            let itemTransactionImgUrl: URL = message.itemTrasaction?.book?.coverImage?.url ?? URL(fileURLWithPath: "")
            let itemTransactionTitle: String = message.itemTrasaction?.book?.titleText() ?? ""
            let itemTransactionPrice: String = message.itemTrasaction?.merchandise?.price ?? "-1"
            let itemTransactionMerchandiseId: String = message.itemTrasaction?.merchandise?.id ?? "-1"
            
            if message.messageType == nil {
                if merchandiseId != "-1" {
                    message.messageType = .merchandise
                } else if itemTransactionId != "-1" {
                    message.messageType = .transactionStatusUpdate
                } else if (message.text?.length ?? 0) > 0 && itemTransactionId == "-1" {
                    message.messageType = .text
                } else {
                    message.messageType = .image
                }
                
                if (message.imageUrl?.absoluteString.length ?? 0) > 0 {
                    message.messageType = .image
                }
            }

            let sql: String = "INSERT OR REPLACE INTO \(chatsTableName) (id, room_id, user_id, type, text, is_oldest_message, chat_order, image_path, created_at, merchandise_id, merchandise_book_id, merchandise_book_imgUrl, merchandise_book_title, merchandise_price, item_transaction_id, item_transaction_status, item_transaction_imgUrl, item_transaction_title, item_transaction_price, item_transaction_merchandise_id) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
            sqls.append(sql)
                        
            args.append([messageId, roomId, senderId, message.messageType!.rawValue, messageText, isOldest, message.chatOrder!, messageImgUrl.absoluteString, message.date!, merchandiseId,bookId,bookImgUrl,bookTitle,price, itemTransactionId, itemTransactionStatus!.rawValue, itemTransactionImgUrl, itemTransactionTitle, itemTransactionPrice,itemTransactionMerchandiseId])
        }
                
        return FMDBManager.sharedManager.executeUpdateAll(sqls, args: args)
    }
    
    open class func deleteMessagesCache() ->Bool {
        let sql: String = "DELETE FROM \(chatsTableName)"
        return FMDBManager.sharedManager.executeUpdate(sql, args: [])
    }
}
