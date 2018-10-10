//
//  Notification.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public enum NotificationType: Int {
    case like
    case update
    case sale
    case transactions
    case message
    case news
    case transactionEmail
    
    func parameterFromType() -> String {
        switch self {
        case .like:
            return "book_like"
        case .update:
            return "book_update"
        case .sale:
            return "book_sale"
        case .transactions:
            return "transactions"
        case .message:
            return "message"
        case .news:
            return "news"
        case .transactionEmail:
            return "transaction_email"
        }
    }
    
    func stringFromType() ->String {
        switch self {
        case .like:
            return "出品している本がいいねされた時"
        case .update:
            return "いいねしている本の最安値が更新された時"
        case .sale:
            return "出品している本の最安値が更新された時"
        case .transactions:
            return "取引が進んだ時"
        case .message:
            return "メッセージが来た時"
        case .news:
            return "運営からのお知らせが来た時"
        case .transactionEmail:
            return "取引メールが来た時"
        }
    }
}

public struct Notification {
    var bookLike: Bool?
    var bookUpdate: Bool?
    var bookSale: Bool?
    var transactions: Bool?
    var message: Bool?
    var news: Bool?
    var transactionEmail: Bool?
    var newsEmail: Bool?
    var notifications: [Bool]?
    
    init() {}
    
    init(dic: [String: AnyObject]?) {
        bookLike = dic?["book_like"] as? Bool
        bookUpdate = dic?["book_update"] as? Bool
        bookSale = dic?["book_sale"] as? Bool
        transactions = dic?["transactions"] as? Bool
        message = dic?["message"] as? Bool
        news = dic?["news"] as? Bool
        transactionEmail = dic?["transaction_email"] as? Bool
        newsEmail = dic?["news_email"] as? Bool
        
        notifications = [bookLike!, bookUpdate!, bookSale!, transactions!, message!, news!, transactionEmail!, newsEmail!]
    }
    
    func notificationsAtIndex(_ index: Int) -> Bool? {
        if index < 0 || index > (notifications?.count)!{
            return nil
        }
        return notifications?[index]
    }
    
//    func notificationsCount() -> Int {
//        return 8
//    }
    
    func remoteNotificationCount() ->Int {
        return 6
    }
    
    func emailNotificationCount() ->Int {
        return 1
    }
}
