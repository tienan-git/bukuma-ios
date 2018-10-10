//
//  ChatRoom.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/01.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

let ChatRoomListCacheKey: String = "ChatRoomListCacheKey"
let ChatRoomDeleteNotification: String = "ChatRoomDeleteNotification"

open class ChatRoom: BaseModelObject {
    
    var id: String? /// id
    var lastMessage: String? /// last message のtext
    var message: Message? /// last message
    var chatUser: User? /// chatしているユーザー
    var members: [User]? ///自分とchatしているユーザー
    var lastUpdateDate: NSDate?
    var timeStump: Double?
    var numberOfUnreadCount: Int? = 0
    static var sumUnReadCount: Int? = 0
    
    var isClosed: Bool { ///相手がchatを退出したかどうか
        if members == nil {
            return false
        }
        if (members?.count ?? 0) < 2 {
            return true
        }
        return false
    }
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        id = attributes?["id"].map{String(describing: $0)}
        numberOfUnreadCount = attributes?["unread_count"] as? Int
        
        attributes?["updated_at"].map{ lastUpdateDate = String(describing: $0).int().double().date() }
        attributes?["updated_at"].map { timeStump = String(describing: $0).int().double()}
        
        let membersArray = attributes?["members"] as? [AnyObject]
        
        members = membersArray.map { (members) in
            let dic = members as! [[String: [String: AnyObject]]]
            let users: [User] = dic.map({ (member) in
                let user: User = User(dictionary: member["member"])
                if user.identifier != Me.sharedMe.identifier {
                    chatUser = user
                }
                return user
            })
            return users
        }
        
        message = Message(attributes: attributes?["last_message"] as? [String: AnyObject], roomIdentifier: id)
        
        lastMessage = message?.text.map{$0}
        
        if message?.messageType == .text {
            lastMessage = message?.text
        } else if message?.messageType == .image {
            lastMessage = "✓画像を送信しました"
        }
    }
    
    public convenience init(DBAttributes: [String: AnyObject]?) {
        self.init(dictionary: nil)
        
        id = DBAttributes?["id"].map{String(describing: $0)}
        numberOfUnreadCount = DBAttributes?["num_unread"] as? Int
        
        DBAttributes?["last_message_updated_at"].map{ lastUpdateDate = String(describing: $0).int().double().date() }
        DBAttributes?["last_message_updated_at"].map { timeStump = String(describing: $0).int().double()}
        
        
        lastMessage = DBAttributes?["last_message_text"] as? String
        message = Message()
        message?.id =  DBAttributes?["last_message_id"] as? String
        message?.messageType = MessageType(rawValue:  DBAttributes?["last_message_type"] as? Int ?? 0)
        
        message?.itemTrasaction = Transaction()
        message?.itemTrasaction?.type = TransactionListType(rawValue: DBAttributes?["last_message_tranasction_type"] as? Int ?? 0)
        
        members = []
        let chatUser: User = User()
        chatUser.identifier = DBAttributes?["user_id"] as? String
        chatUser.nickName =  DBAttributes?["user_name"] as? String
        self.chatUser = chatUser
        members?.append(chatUser)
        members?.append(Me.sharedMe)
    
        DBAttributes?["user_icon_url"].map { chatUser.photo?.imageURL =  URL(string: String(describing: $0)) }
        
    }
    
    open func deleteChatRoom(_ completion: ((_ error: Error?) -> Void)?) {
        guard let id = self.id else {
            let error: Error = Error(domain: ErrorDomain, code: 0, userInfo: nil)
            error.errorDespription = "roomIdentifierがありません"
            completion?(error)
            return
        }
        
        ApiClient.sharedClient.DELETE("v1/chat_rooms/\(id)",
                                    parameters: [:]) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: ChatRoomDeleteNotification), object: self)
                                            ChatRoom.deleteRoomCache(fromId: id)
                                            
                                            completion?(nil)
                                            
                                        } else {
                                            DBLog(error)
                                            completion?(error)
                                        }
        }
    }
    
    open class func getRoomsList(_ timeStump: Double?, shouldRefresh: Bool, completion: @escaping (_ latestPostUpdate: Double, _ rooms: [ChatRoom]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["from_timestamp"] = timeStump
        params["number"] = 100
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/chat_rooms",
                                   parameters: params) { (responceObject, error) in
                                    
                                    if error == nil {
                                        if responceObject!["chat_rooms"] == nil {
                                            completion(ChatRoom.cachedRooms()?.last?.timeStump ?? 0, nil, error)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["chat_rooms"]!).arrayObject!
                                        
                                        DBLog(jsonArray)
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        
                                        var latestPostUpdate: Double?
                                        var firstPostUpdate: Double?
                                        var count: Int = 0
                                        let rooms: [ChatRoom] = jsonDic.map({ (dic) in
                                            let room: ChatRoom? = ChatRoom(dictionary: dic)
                                            count += room?.numberOfUnreadCount ?? 0
                                            return room!
                                        })
                                        
                                        ChatRoom.sumUnReadCount = count
                                        
                                        self.save(all: rooms)
                                        
                                        latestPostUpdate = rooms.last?.timeStump
                                        
                                        ChatRealtimeUpdater.updateLastChatRoomGettingDate(latestPostUpdate!)
                                       
                                        if shouldRefresh == true {
                                            firstPostUpdate = rooms.first?.timeStump
                                            ChatRealtimeUpdater.updateFirstChatRoomGettingDate(firstPostUpdate!)
                                        }
                                        
                                        completion(latestPostUpdate!, rooms, nil)
                                    } else {
                                        DBLog(error)
                                        completion(ChatRoom.cachedRooms()?.last?.timeStump ?? 0, nil, error)
                                    }
        }
    }
    
    open class func createChatRoom(_ user: User?, completion:@escaping (_ room: ChatRoom?, _ error: Error?) ->Void) {
        if user == nil || user?.identifier == nil {
            completion(nil, Error(domain: "error.invalid_parameter", code: -1, userInfo: nil))
            return
        }
        let params: [String: Any] = ["with_user_id" : user!.identifier!]
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/chat_rooms/new",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            let room: ChatRoom = ChatRoom()
                                            room.id = responceObject?["room_id"].map{String(describing: $0)}
                                            room.chatUser = user
                                            
                                            AnaliticsManager.sendAction("create_chat_room",
                                                                        actionName: "create_chat_room",
                                                                        label: "",
                                                                        value: 1,
                                                                        dic: [:])
                                            
                                            completion(room, nil)
                                        } else {
                                            DBLog(error)
                                            completion(nil, error)
                                        }
        }
    }
    
    open func reportChatRoom(_ completion:@escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.POST("v1/chat_rooms/\(String(describing: id))/report",
                                    parameters: [:]) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            completion(nil)
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    
    open class func updateCacheChatRoomList(_ completion:@escaping (_ error: Error?) ->Void) {
        self.getRoomsList(nil,
                          shouldRefresh: true) { (latestPostUpdate, rooms, error) in
                            completion(error)
        }
    }
    
    open class func searchRoomFromRoomID(_ roomId: String?) ->ChatRoom? {
        if Utility.isEmpty(roomId) {
            return nil
        }
        
        let cacheList: [ChatRoom]? = self.cachedRooms()
        
        let chatRoom: ChatRoom? = cacheList?.filter({ (room) -> Bool in
            return room.id == roomId
        }).first
        return chatRoom
    }
    
    open class func searchRoomFromUserID(_ userId: String?) ->ChatRoom? {
        if Utility.isEmpty(userId) {
            return nil
        }
        
        let cacheList: [ChatRoom]? = self.cachedRooms()
        
        let chatRoom: ChatRoom? = cacheList?.filter({ (room) -> Bool in
            return room.chatUser?.identifier == userId
        }).first
        return chatRoom
    }
    
    @discardableResult class func save(all rooms: [ChatRoom]) ->Bool {
        var sqls: [String] = []
        var args: [Any] = []
        
        for room in rooms {
            
            let roomID: String = room.id ?? "-1"
            
            let chatUserID: String = room.chatUser?.identifier ?? "-1"
            let chatUserName: String = room.chatUser?.nickName ?? "-1"
            let chatUserImageURL: String = room.chatUser?.photo?.imageURL?.absoluteString ?? "-1"
            
            let lastMessageID: String = room.message?.id ?? "-1"
            let lastMessageText: String = ChatListCell.lastMessageText(room)
            let lastMessageType: MessageType = room.message?.messageType ?? MessageType(rawValue: 0)!
            let lastMessageTransactionType: TransactionListType = room.message?.itemTrasaction?.type ?? TransactionListType(rawValue: 0)!
            let lastMessageUpdate: NSDate = room.lastUpdateDate ?? NSDate()
            
            let unread: Int = room.numberOfUnreadCount ?? 0
            
            let sql: String = "INSERT OR REPLACE INTO \(chatsLists) (id, user_id, user_name, user_icon_url, last_message_id, last_message_text, last_message_type, last_message_tranasction_type, last_message_updated_at, num_unread) VALUES (?,?,?,?,?,?,?,?,?,?)"
            sqls.append(sql)
            
            args.append([roomID, chatUserID, chatUserName, chatUserImageURL, lastMessageID, lastMessageText, lastMessageType.rawValue, lastMessageTransactionType.rawValue, lastMessageUpdate, unread])
        }
        
        return FMDBManager.sharedManager.executeUpdateAll(sqls, args: args)
    }
    
    open class func cachedRooms() ->[ChatRoom]? {
        let membersSql: String = "SELECT * FROM \(chatsLists) ORDER BY last_message_updated_at DESC LIMIT ? OFFSET ?"
        
        let localChats: [AnyObject]? = FMDBManager.sharedManager.executeQuery(membersSql, args: [100 as AnyObject, 0 as AnyObject])
        guard let locals = localChats else {
            return nil
        }
        guard let localChatsDic = locals as? [[String: AnyObject]] else {
            return nil
        }

        let chats: [ChatRoom] = localChatsDic.map { (dic) in
            let chat: ChatRoom = ChatRoom(DBAttributes: dic)
            return chat
        }
        return chats
    }
    
    @discardableResult open class func deleteRoomCache() ->Bool {
        let sql: String = "DELETE FROM \(chatsLists)"
        return FMDBManager.sharedManager.executeUpdate(sql, args: [])
    }
    
    @discardableResult open class func deleteRoomCache(fromId id: String) ->Bool {
        let sql: String = "DELETE FROM \(chatsLists) where id = ?"
        return FMDBManager.sharedManager.executeUpdate(sql, args: [id as AnyObject])
    }

}
