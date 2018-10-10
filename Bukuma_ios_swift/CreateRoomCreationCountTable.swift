//
//  CreateRoomCreationCountTable.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/10.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class CreateRoomCreationCountTable: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.createTable("created_new_rooms", completion: { (table) in
            table.column("room_id", type: .text, options: [TableDefinitionTableOptionPrimaryKey: true as AnyObject])
            table.column("created_at", type: .datetime, options: [:])
        })
    }
    
    @objc open static func version() -> Int {
        return 4
    }
}
