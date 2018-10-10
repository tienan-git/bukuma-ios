//
//  TransactionTable.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/21.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class TransactionTable: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("item_transaction_id", type: .text, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 10
    }
    
}

open class AddTransactionId: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("item_transaction_status", type: .int, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 11
    }
}

open class AddTransactionBookImageUrl: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("item_transaction_imgUrl", type: .text, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 12
    }
    
}

open class AddTransactionBookTitle: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("item_transaction_title", type: .text, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 13
    }
    
}

open class AddTransactionBookPrice: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("item_transaction_price", type: .text, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 14
    }
}

open class AddTransactionMerchandiseId: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("item_transaction_merchandise_id", type: .text, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 15
    }
    
}
