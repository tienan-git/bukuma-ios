//
//  TableDefinition.swift
//
//
//  Created by 千葉大志 on 2016/06/10.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

public enum TableDefinitionColumnType: Int {
    case text
    case int
    case double
    case real
    case blob
    case datetime
    case null = -1
}

public enum TableDefinitionSQLType: Int {
    case createTable
    case addColumn
    case dropTable
}

public let TableDefinitionTableOptionPrimaryKey: String = "PRIMARY KEY"
public let TableDefinitionTableOptionAutoIncrement: String = "AUTOINCREMENT"
public let TableDefinitionTableOptionUnique: String = "UNIQUE"
public let TableDefinitionTableOptionNull: String = "NULL"
public let TableDefinitionTableOptionDefault: String = "DEFAULT"

open class TableDefinition: NSObject {
    
    fileprivate var definitions: [ColumnDefinition]?
    fileprivate var tableName: String?
    fileprivate var sqlType: TableDefinitionSQLType?
    
    public init(tableName: String, type: TableDefinitionSQLType) {
        super.init()
        self.tableName = tableName
        self.sqlType = type
        definitions = []
    }
    
    open func column(_ columnName: String, type: TableDefinitionColumnType, options: [String: AnyObject]) {
        if sqlType == nil {
            return
        }
        var detailType: ColumnDefinitionType = ColumnDefinitionType(rawValue: 0)!
        switch sqlType! {
        case .createTable:
            detailType = .create
        case .addColumn:
            detailType = .add
        default:
            break
        }
        
        let detail: ColumnDefinition = ColumnDefinition(name: columnName,
                                                        type: detailType,
                                                        columnType: type,
                                                        opions: options)
        definitions?.append(detail)
    }
    
    open func buildSQL() ->String? {
        if sqlType == nil {
            return nil
        }
        switch sqlType! {
        case .createTable:
            return self.buildSQLForCreateTable()
        case .addColumn:
            return self.buildSQLForAlterTable()
        case .dropTable:
            return self.buildSQLForDropTable()
        }
    }
    
    fileprivate func buildSQLForCreateTable() ->String {
        let sql: NSMutableString = NSMutableString.init(string: "CREATE TABLE IF NOT EXISTS \(tableName!)")
        sql.append(" (")
        
        var index: Int = 0
        for colunm in definitions! {
            sql.append("\(colunm.name!) \(colunm.columnTypeString()!)\(colunm.optionsString()!)")
            if index < definitions!.count - 1 {
                sql.append(",")
            }
            index += 1
        }
        sql.append(");")
        return sql as String
    }
    
    fileprivate func buildSQLForAlterTable() ->String {
        let sql: NSMutableString = NSMutableString.init(string: "")
        for colunm in definitions! {
            sql.append("ALTER TABLE \(tableName!) ADD \(colunm.name!) \(colunm.columnTypeString()!)\(colunm.optionsString()!)")
        }
        return sql as String
    }
    
    fileprivate func buildSQLForDropTable() ->String {
        return "DROP TABLE \(tableName!)"
    }
}
