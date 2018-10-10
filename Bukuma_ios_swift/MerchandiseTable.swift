//
//  MerchandiseTable.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/14.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class MerchandiseTable: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("merchandise_id", type: .text, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 5
    }
}

open class AddMerchandiseBookId: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("merchandise_book_id", type: .text, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 6
    }
}

open class AddMerchandiseImagePath: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("merchandise_book_imgUrl", type: .text, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 7
    }
}

open class AddMerchandiseBookTitle: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("merchandise_book_title", type: .text, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 8
    }
}

open class AddMerchandisePrice: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("merchandise_price", type: .text, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 9
    }
}
