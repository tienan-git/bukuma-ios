//
//  ColumnDefinition.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/10.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

public enum ColumnDefinitionType: Int {
    case create
    case add
}

open class ColumnDefinition: NSObject {
    
    var name: String?
    var type: ColumnDefinitionType?
    var columnType: TableDefinitionColumnType?
    var opitions: [String: AnyObject]?
    
    public init(name: String, type: ColumnDefinitionType, columnType: TableDefinitionColumnType, opions: [String: AnyObject]) {
        super.init()
        self.name = name
        self.type = type
        self.columnType = columnType
        self.opitions = opions
    }
    
    open func columnTypeString() ->String? {
        if columnType == nil {
            return nil
        }
        switch columnType! {
        case .text:
            return "TEXT"
        case .int:
            return "INTEGER"
        case .double:
            return "DOUBLE"
        case .real:
            return "REAL"
        case .blob:
            return "BLOB"
        case .datetime:
            return "DATETIME"
        case .null:
            return nil
        }
    }

    open func optionsString() ->String? {
        if opitions == nil {
            return ""
        }
        
        let options: NSMutableString = NSMutableString.init(string: "")
        for key in opitions!.keys {
            if key == TableDefinitionTableOptionPrimaryKey {
                if opitions?[TableDefinitionTableOptionPrimaryKey] as? Bool == true {
                    options.append(" \(TableDefinitionTableOptionPrimaryKey)")
                }
            } else if key == TableDefinitionTableOptionAutoIncrement {
                if opitions?[TableDefinitionTableOptionAutoIncrement] as? Bool == true {
                    options.append(" \(TableDefinitionTableOptionAutoIncrement)")
                }
            } else if key == TableDefinitionTableOptionUnique {
                if opitions?[TableDefinitionTableOptionUnique] as? Bool == true {
                    options.append(" \(TableDefinitionTableOptionUnique)")
                }
            } else if key == TableDefinitionTableOptionNull {
                if opitions?[TableDefinitionTableOptionNull] as? Bool == false {
                    options.append(" NOT NULL")
                }
            } else if key == TableDefinitionTableOptionDefault {
                 options.append(" \(TableDefinitionTableOptionDefault) \(opitions![TableDefinitionTableOptionDefault]!)")
            }
        }
        
        DBLog(options)
        
        return String(options)
    }
    
}
