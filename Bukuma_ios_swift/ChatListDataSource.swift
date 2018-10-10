//
//  ChatRoomDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/04/29.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


import SwiftyJSON

let ChatRoomUserBlockKey = "ChatRoomUserBlockKey"

open class ChatListDataSource: BaseDataSource {
    
    required public init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteBlockedUserRoom(_:)), name: NSNotification.Name(rawValue: ChatRoomUserBlockKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteRoom(_:)), name: NSNotification.Name(rawValue: ChatRoomDeleteNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshFromNotification(_:)), name: NSNotification.Name(rawValue: ChatRoomDataSourceRefreshKey), object: nil)
    }
    
    override open func cachedData() -> [AnyObject]? {
        return ChatRoom.cachedRooms()
    }
    
    var fromTimeStump: Double? {
        get {
             return ChatRealtimeUpdater.sharedUpdater.chatRoomLastUpdateDateTimeStamp
        }
        set(newValue) {
        }
    }
    
    func deleteRoom(_ notification: Foundation.Notification) {
        let room: ChatRoom = notification.object as! ChatRoom
        for r in self.dataSource! as! Array<ChatRoom> {
            if r.id == room.id {
                self.dataSource!.removeObject(r)
            }
        }
        self.updateDatasourceByRefreshDataSource(true)
    }
    
    func deleteBlockedUserRoom(_ notification: Foundation.Notification) {
        let blockedUserId: String = notification.object as! String
        let rooms: [ChatRoom]? = ChatRoom.cachedRooms()
        
        DBLog(blockedUserId)
        
        let removableRoom: ChatRoom? = rooms?.filter({ (room) in
            DBLog(room.chatUser?.identifier)
            
            return room.chatUser?.identifier == blockedUserId
        }).first
        removableRoom?.deleteChatRoom({ (error) in
            DispatchQueue.main.async {
                self.delegate?.completeRequest()
            }
        })
    }
    
    func refreshFromNotification(_ notification: Foundation.Notification) {
        self.refreshDataSource(true)
    }
    
    open func refreshDataSource(_ isRefreshFirstPage: Bool) {
        if isRefreshing == true {
            return
        }
        page = 0
        isMoreDataSourceAvailable = false
        isRefreshing = true
        ChatRoom.getRoomsList(isRefreshFirstPage ? nil : fromTimeStump,
                               shouldRefresh: true) { (latestPostUpdate, rooms, error) in
                                self.completeGetting(rooms, shouldRefresh: true, error: error)
        }
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if shouldRefresh == true {
            ChatRoom.getRoomsList(nil,
                                  shouldRefresh: shouldRefresh,
                                  completion: { (latestPostUpdate, rooms, error) in
                                    self.completeGetting(rooms, shouldRefresh: shouldRefresh, error: error)
            })
            return
        }
        ChatRoom.getRoomsList(fromTimeStump,
                              shouldRefresh: shouldRefresh) { (latestPostUpdate, rooms, error) in
                                self.completeGetting(rooms, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
