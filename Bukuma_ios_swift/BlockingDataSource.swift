//
//  BlockingDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class BlockingDataSource: BaseDataSource {
    
    open override func cachedData() -> [AnyObject]? {
        return nil
    }
    
    open override func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        User.getBlockUserList(self.paging(&page)) { (users, error) in
            self.completeGetting(users, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
