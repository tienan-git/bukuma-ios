//
//  ChatListMigration.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/12/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class CreateChatListsInitialTables: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        var result: Bool = true
        
        result = Migration.createTable(chatsLists, completion: { (table) in
            table.column("id", type: .text, options: [TableDefinitionTableOptionPrimaryKey: true as AnyObject])
            table.column("user_id", type: .text, options: [:])
            table.column("user_name", type: .text, options: [:])
            table.column("user_icon_url", type: .text, options: [:])
            table.column("last_message_id", type: .text, options: [:])
            table.column("last_message_text", type: .text, options: [:])
            table.column("last_message_type", type: .int, options: [:])
            table.column("last_message_tranasction_type", type: .int, options: [:])
            table.column("last_message_updated_at", type: .datetime, options: [:])
            table.column("num_unread", type: .int, options: [:])
        })
        
        return result
    }
    
    @objc open static func version() -> Int {
        return 16
    }
}
