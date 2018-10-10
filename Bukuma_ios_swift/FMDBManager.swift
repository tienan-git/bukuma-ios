//
//  FMDBManager.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/09.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import FMDB

open class FMDBManager: NSObject {
    
    var db: FMDatabase?
    
    open class var sharedManager: FMDBManager {
        struct Static {
            static let instance = FMDBManager()
        }
        return Static.instance
    }
    
    override public init() {
        super.init()
        self.initlizeDB()
       _ = self.addSkipBackupAttributeToItemAtURL(URL(fileURLWithPath: type(of: self).dbPass()))
    }
    
    func initlizeDB() {
        db = FMDatabase(path: type(of: self).dbPass())
        #if DEBUG
        db?.logsErrors = true
        db?.traceExecution = true
        #endif
        
        let sql: String = "CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY);"
        db?.open()
        do  {            
            try db?.executeUpdate(sql, values: Array())
        } catch {
            DBLog("db initlize error\(error)")
        }
        db?.close()
    }
    
    fileprivate func addSkipBackupAttributeToItemAtURL(_ url: Foundation.URL) ->Bool {
        assert(FileManager.default.fileExists(atPath: url.path))
        var success: Bool?
        do {
            
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try (url as NSURL).setResourceValue(NSNumber(value: true), forKey: URLResourceKey.isExcludedFromBackupKey)
            success = true
            
        } catch {
            success = false
        }
        return success!
    }
    
    @discardableResult open func migrate() ->Bool {
        return Migration.migrate()
    }
    
    class func dbPass() ->String {
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documents.appendingPathComponent("project.db")
        return fileURL.path 
    }
    
    open func executeQuery(_ sql: String, args: [AnyObject]) ->[AnyObject]? {
        if db?.open() == false {
            return nil
        }
        
        var retval: [AnyObject] = []
        let result: FMResultSet? = db?.executeQuery(sql, withArgumentsIn: args)
        if result == nil {
            return nil
        }
        
        while result!.next() {
            retval.append(result!.resultDictionary as AnyObject)
        }
        
        db?.close()
        return retval
    }
    
    open func executeUpdate(_ sql: String, args: [AnyObject]) ->Bool {
        if db?.open() == false {
            return false
        }
        
        db?.beginTransaction()
        var result: Bool = false
        result = db?.executeUpdate(sql, withArgumentsIn: args) ?? false
        
        DBLog(sql)
        
        if result == false {
            DBLog("Error \(String(describing: db?.lastErrorCode())) \(String(describing: db?.lastErrorMessage()))")
            db?.rollback()
            db?.close()
            return false
        }
        db?.commit()
        db?.close()
        return true
    }
    
    open func executeUpdateAll(_ sqls: [String], args: [Any]) ->Bool {
        if db?.open() == false {
            return false
        }
        db?.beginTransaction()
        
        if db == nil {
            return false
        }
        
        var result: Bool = false
        for i in 0 ..< sqls.count {
            result = db!.executeUpdate(sqls[i], withArgumentsIn: args[i] as! [Any])
            if result == false {
                break
            }
        }
        
        if result == false {
            DBLog("Error \(String(describing: db?.lastErrorCode())) \(String(describing: db?.lastErrorMessage()))")
            db?.rollback()
            db?.close()
            return false
        }
        db?.commit()
        db?.close()
        return true
    }
}
