//
//  BoughtBookListDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/02.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class BoughtBookListDataSource: BaseDataSource {
    
    override open func cachedData() -> [AnyObject]? {        
        return Transaction.cachedBoughtItemTransaction()
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if Me.sharedMe.isRegisterd == false {
            completeGetting(nil, shouldRefresh: shouldRefresh, error: nil)
            return
        }
        
        Transaction.getBoughtItemTransactionList(self.paging(&page)) { (transactions, error) in
            self.completeGetting(transactions, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
