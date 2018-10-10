//
//  BankDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/04/25.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class BankDataSource: BaseDataSource {
    
    override open func cachedData() ->[AnyObject]? {
        return nil
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        Bank.getBankAccountList { (banks, error) in
            self.completeGetting(banks, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
