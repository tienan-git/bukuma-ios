//
//  TransactionStore.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/01.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class TransactionStore: NSObject {
    var storedTransactions: [String: Transaction] = [:]
    
    open class var shared: TransactionStore {
        struct Static {
            static let instance = TransactionStore()
        }
        return Static.instance
    }
    
    
    open func storeTransaction(_ transaction: Transaction) {
        storedTransactions["\(String(describing: transaction.id))"] = transaction
    }
    
    open func storedTransaction(_ identifier: String) ->Transaction? {
        return storedTransactions["\(identifier)"]
    }
}
