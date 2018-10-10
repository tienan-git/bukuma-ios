//
//  AddChatOrder.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/10.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class AddChatOrder: NNMigrationDelegate {
    
    @objc open static func execute() -> Bool {
        return Migration.addColumnTo(chatsTableName, completion: { (table) in
            table.column("chat_order", type: .double, options: [:])
        })
    }
    
    @objc open static func version() ->Int {
        return 3
    }
}
