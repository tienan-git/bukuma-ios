//
//  Migration.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/10.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

let MigrationException: String = "jp.nanameue.Migration.exception"

func classesConformingToNNMigration() ->[AnyClass] {
    let classes = objc_getClassList()
    var ret = [AnyClass]()
    
    for cls in classes {
        if class_conformsToProtocol(cls, NNMigrationDelegate.self) {
            ret.append(cls)
        }
    }
    
    let migrations = ret.sorted { (obj1, obj2) -> Bool in
        let int: Int = obj1.version()
        let int2: Int = obj2.version()
        
        return NSNumber.init(value: int as Int).compare(NSNumber.init(value: int2 as Int)) == .orderedAscending
    }
    
    return migrations
}

func objc_getClassList() -> [AnyClass] {
    let expectedClassCount = objc_getClassList(nil, 0)
    let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
    let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass?>(allClasses)
    let actualClassCount:Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
    
    var classes = [AnyClass]()
    for i in 0 ..< actualClassCount {
        if let currentClass: AnyClass = allClasses[Int(i)] {
            classes.append(currentClass)
        }
    }
    
    allClasses.deallocate(capacity: Int(expectedClassCount))
    return classes
}

//NNMigrationDelegateに準拠しているクラスでexecuteとversionを指定することで、migrateされる
//CreateInitialTables, AddOldestMessageFlag, MerchandiseTableなどのclassを参照

@objc public protocol NNMigrationDelegate {
    static func execute() ->Bool
    static func version() ->Int
}

open class Migration: NSObject {
    
    @discardableResult open class func migrate() ->Bool {
        let classes: [AnyClass] = classesConformingToNNMigration()
        let currentVersion: Int = self.currentSchemaVersion()
        DBLog(currentVersion)
        
        for migrationClass in classes {
            
            if migrationClass.version() <= currentVersion {
                continue
            }
            
            if migrationClass.execute() == false {
                return false
            }
            
            if self.insertSchemaVersion(migrationClass.version()) == false {
                return false
            }
        }
        return true
    }
    
    open class func createTable(_ tableName: String, completion: (_ table: TableDefinition) ->Void) ->Bool {
        let table: TableDefinition = TableDefinition(tableName: tableName, type: .createTable)
        completion(table)
        return FMDBManager.sharedManager.executeUpdate(table.buildSQL()!, args: [])
    }
    
    open class func addColumnTo(_ tableName: String, completion: (_ table: TableDefinition) ->Void) ->Bool {
        let table: TableDefinition = TableDefinition(tableName: tableName, type: .addColumn)
        completion(table)
        return FMDBManager.sharedManager.executeUpdate(table.buildSQL()!, args: [])
    }
    
    open class func dropTable(_ tableName: String, completion: (_ table: TableDefinition) ->Void) ->Bool {
        let table: TableDefinition = TableDefinition(tableName: tableName, type: .dropTable)
        completion(table)
        return FMDBManager.sharedManager.executeUpdate(table.buildSQL()!, args: [])
    }
    
    fileprivate class func insertSchemaVersion(_ version: Int) ->Bool {
        return FMDBManager.sharedManager.executeUpdate("INSERT INTO schema_migrations VALUES (?)", args: [version as AnyObject])
    }
    
    fileprivate class func currentSchemaVersion() ->Int {
        let result = FMDBManager.sharedManager.executeQuery("SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 20;", args: [])
        if result?.count == 0 || result == nil {
            return 0
        }
        
        DBLog(result)
        
        let versions = result!.sorted { (obj1, obj2) -> Bool in
            let int: Int = obj1["version"]?.map{String(describing: $0).int()} ?? 0
            let int2: Int = obj2["version"]?.map{String(describing: $0).int()} ?? 0
            
             return NSNumber.init(value: int as Int).compare(NSNumber.init(value: int2 as Int)) == .orderedAscending
        }
        
        return versions.last?["version"]?.map{String(describing: $0).int()} ?? 0
    }
}
