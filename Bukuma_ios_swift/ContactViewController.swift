//
//  ContactViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/04.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import LUKeychainAccess

private let ktopics: [String] = ["取引について","取引キャンセルについて","購入について", "不適切なユーザー","不適切な商品","ユーザーとのトラブル","その他"]

public enum ReportType: Int {
    case none
    case book
    case user
    case itemTransaction
    case itemTransactionCancel
    case merchandise
}

open class ContactViewController: AAMFeedbackViewController {
    
    fileprivate let kContactinfo = "bukuma.contact@gmail.com"
    var opponentUser: User?
    var user: User?
    var book: Book?
    var merchandise: Merchandise?
    var itemTransaction: Transaction?
    var type: ReportType?
    var userId: String {
        return (Me.sharedMe.isRegisterd == true ? Me.sharedMe.identifier : "未登録") ?? "未登録"
    }
    var userName: String {
        return (Me.sharedMe.isRegisterd == true ? Me.sharedMe.nickName : "未登録") ?? "未登録"
    }
    var emptyErrorString: String {
        return "詳細を入力してください"
    }
    
    var UUID: String {
        let uuid: String = LUKeychainAccess.standard().string(forKey: MeUUIDKey) ?? ""
        return uuid
    }
    
    required public init(topics: [String]) {
        super.init(topics: topics)
        self.toRecipients = [kContactinfo]
    }
    
    required public convenience init(type: ReportType, object: BaseModelObject?) {
        self.init(topics: ktopics)
        self.type = type
        self.generateReportbleObject(self.type!, object: object)
    }
    
    public convenience init(objects: [BaseModelObject?]) {
        self.init(topics: ktopics)
        
        for object in objects {
            if object is Book {
                book = object as? Book
            } else if object is Merchandise {
                merchandise = object as? Merchandise
            } else if object is User {
                opponentUser = object as? User
            } else if object is Transaction {
                itemTransaction = object as? Transaction
            }
        }
    }
    
    func generateReportbleObject(_ type: ReportType, object: BaseModelObject?) {
        switch type {
        case .book:
            book = object as? Book
            break
        case .user:
           opponentUser = object as? User
            break
        case .merchandise:
            merchandise = object as? Merchandise
            break
        case .itemTransaction, .itemTransactionCancel:
            itemTransaction = object as? Transaction
            break
        default:
            break
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func initializeNavigationLayout() {
        super.initializeNavigationLayout()
        self.navigationBarTitle = "お問い合わせ"
        self.title = "お問い合わせ"
    }
    
    override open func nextDidPress() {
        descriptionTextView?.resignFirstResponder()
        
        if Utility.isEmpty(descriptionTextView?.text) {
             self.simpleAlert(nil, message: emptyErrorString, cancelTitle: "OK", completion: nil)
            return
        }
        
        let picker: MailComposeViewController? = MailComposeViewController()
                
        var body = self.feedbackBody()
        
        if opponentUser != nil {
            body.append("\n\nUserID:\n\(userId)\n\nUserName:\n\(userName)\n\nOponentID\n\(opponentUser?.identifier ?? "")\n\nOponentName:\n\(opponentUser?.nickName ?? "")")
        } else {
            body.append("\n\nUserID:\n\(userId)\n\nUserName:\n\(userName)")
        }
        
        if book != nil {
            body.append("\n\nBookID:\n\(book?.identifier ?? "")\n\nBookTitle:\n\(book?.titleText() ?? ""))")
        }
        
        if merchandise != nil {
            body.append("\n\nMerchandiseID:\n\(merchandise?.id ?? "")")
        }
        
        if itemTransaction != nil {
            body.append("\n\nItemTransactionID:\n\(itemTransaction?.id ?? "")\n\nUniqueId:\n\(itemTransaction?.contactId ?? "")")
        }
        
        body.append("\n\nUUID:\n\(UUID)")
        
        picker?.mailComposeDelegate = self
        picker?.setToRecipients(toRecipients)
        picker?.setCcRecipients(ccRecipients)
        picker?.setBccRecipients(bccRecipients)
        picker?.setSubject(self.feedbackSubject())
        picker?.setMessageBody(body as String, isHTML: false)
        
        if picker == nil {
            return
        }
        self.present(picker!, animated: true, completion: nil)
    }
}
