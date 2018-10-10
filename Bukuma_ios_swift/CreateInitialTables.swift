//
//  CreateInitialTables.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/10.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class CreateInitialTables: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        var result: Bool = true
        
        result = Migration.createTable(chatsTableName, completion: { (table) in
            table.column("id", type: .text, options: [TableDefinitionTableOptionPrimaryKey: true as AnyObject])
            table.column("room_id", type: .text, options: [:])
            table.column("type", type: .int, options: [:])
            table.column("text", type: .text, options: [:])
            table.column("image_path", type: .text, options: [:])
            table.column("user_id", type: .text, options: [:])
            table.column("created_at", type: .datetime, options: [:])
        })
        
        return result
    }
    
    @objc open static func version() -> Int {
        return 1
    }
}
