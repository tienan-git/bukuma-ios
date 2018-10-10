//
//  MessageDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/04/29.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyTimer
import Alamofire

public protocol MessageDataSourceDelegate: BaseDataSourceDelegate {
    func updateOnlyPlaceholderView()
}

open class MessageDataSource: BaseDataSource {
    var timer: Timer?
    var updateTask: Alamofire.Request?
    var isUpdating: Bool?
    var isFinishing: Bool?
    var room: ChatRoom? {
        didSet {
            
            if Message.cachedMessagesList(room!.id!) != nil {
                dataSource = Message.cachedMessagesList(room!.id!)                 
            } else {
                dataSource? = Array()
            }
            
            let lastMessage: Message? = self.dataSource?.last as? Message
            isMoreDataSourceAvailable = !(lastMessage != nil && lastMessage?.isOldest == 1)
            
            let firstMessage: Message? = self.dataSource?.first as? Message
            if firstMessage != nil {
               firstMessage!.read()
            }
            self.getNewMessages()
        }
    }
    
    func finishUpdate() {
        isFinishing = true
        self.stopUpdate()
    }
    
    func stopUpdate() {
        timer?.invalidate()
        timer = nil
    }
    
    func addMessage(_ message: Message) {
       self.dataSource?.insert(message, at: 0)
    }
    
    func removeFailedMessage(_ faildMessage: Message) {
        for message in self.dataSource!.reversed() {
            if (message as! Message).id == faildMessage.id {
                self.dataSource?.removeObject(message as! Message)
            }
        }
    }
    
    func startUpdate() {
        if isFinishing == true || timer?.isValid == true {
            return
        }
        
        timer = Timer.every(5.0, {[weak self] in
            self?.getNewMessages()
        })
    }
    
    func getNewMessages() {
        self.getMessages(true, specifiedId: "0")
    }
    
    func getOldMessages() {
        self.getMessages(false, specifiedId: "0")
    }
    
    func getNewMessages(_ specifiedId: String) {
        self.getMessages(true, specifiedId: specifiedId)
    }
    
    override open func count() -> Int? {
        return self.dataSource?.count
    }
    
    override open func dataAtIndex(_ row: NSInteger, isAllowUpdate: Bool) -> AnyObject? {
        let num: Int = self.count()! - row - 1
        return self.dataSource?[num]
    }
    
    func maxObjectNumberPerPage() -> Int {
        return  100
    }
    
    fileprivate func getMessages(_ isNew: Bool, specifiedId: String) {
        if isUpdating == true {
            return
        }
        
        isUpdating = true
        weak var newestMessage: Message? = (self.dataSource?.count ?? 0) > 0 ? (self.dataSource?.first as? Message) : nil
        weak var oldestMessage: Message? = (self.dataSource?.count ?? 0) > 0 ? (self.dataSource?.last as? Message) : nil
        
        DBLog(newestMessage)
        
        DBLog(oldestMessage)
        
        var fromId: String? = "-1"
        if isNew == true {
            fromId = specifiedId != "0" ? specifiedId : newestMessage?.id
        } else {
            fromId = "-1"
        }
        
        if fromId == nil {
            fromId = "0"
        }
        
        Message.getMessages(fromId!,
                            toId: isNew == true ? "-1" : oldestMessage!.idString(oldestMessage!.id),
                            page: 0,
                            numOfMessages: self.maxObjectNumberPerPage(),
                            roomIdentifier: self.room!.id!) {[weak self] (messages, error) in
                                DBLog(messages)
                                
                                self?.isUpdating = false
                                if error != nil {
                                    self?.delegate?.failedRequest(error!)
                                    return
                                }
                                
                                if messages?.count == 0 || messages == nil {
                                    if isNew == false {
                                        self?.isMoreDataSourceAvailable = false
                                        let message: Message? = self?.dataSource?.last as? Message
                                        if message != nil {
                                            message?.isOldest = 1
                                           _ = Message.saveAll([message!])
                                        }
                                        
                                        self?.delegate?.completeRequest()
                                        
                                    } else {
                                        (self?.delegate as? MessageDataSourceDelegate)?.updateOnlyPlaceholderView()
                                    }
                                }
                                
                                //被ったメッセージ挿入しない
                                if isNew == true {
                                    var shouldInsert: Bool = true
                                    if messages == nil {
                                        return
                                    }
                                    
                                    for message in messages!.reversed() {
                                       _ = (self?.dataSource as? [Message]).map({ (messages) in
                                            messages.map({ (m) in
                                                if m.chatOrder == message.chatOrder {
                                                    shouldInsert = false
                                                    return
                                                }
                                            })
                                        })
                                        
                                        if shouldInsert {
                                            self?.dataSource?.insert(message, at: 0)
                                        }
                                        shouldInsert = true
                                    }
                                } else {
                                    var shouldInsert: Bool = true
                                    if let mes = messages {
                                        for message in mes.reversed() {
                                            for m in (self!.dataSource as! [Message]) {
                                                if m.chatOrder == message.chatOrder {
                                                    shouldInsert = false
                                                    break
                                                }
                                            }
                                            
                                            if shouldInsert {
                                                self!.dataSource?.append(message)
                                            }
                                            shouldInsert = true
                                        }

                                        self?.isMoreDataSourceAvailable = messages?.count == self!.maxObjectNumberPerPage()
                                        
                                        if self?.isMoreDataSourceAvailable == false {
                                            let message: Message? = self?.dataSource?.first as? Message
                                            if message != nil {
                                                message!.isOldest = 1
                                                _ = Message.saveAll([message!])
                                            }
                                        }
                                    }
                                }
                                
                                if (self?.dataSource?.count ?? 0) > 0 {
                                    let message: Message = self!.dataSource!.first as! Message
                                    message.read()
                                }
                                
                                self?.delegate?.completeRequest()

        }
    }
    
    override open func completeGetting(_ array: [AnyObject]?, shouldRefresh: Bool!, error: Error?) {
        if error != nil {
            self.delegate?.failedRequest(error!)
            return
        }
        
        if array != nil {
            self.dataSource?.insert(contentsOf: array!, at: self.dataSource!.count)
        }
        
        if (self.dataSource?.count ?? 0) > 0 {
            let message: Message = self.dataSource!.first as! Message
            message.read()
        }
        
        self.delegate?.completeRequest()
    }
    
    func cancelUpdate() {
        self.finishUpdate()
    

    }
}
