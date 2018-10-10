//
//  ActivityDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class ActivityDataSource: BaseDataSource {
    
    override open func cachedData() -> [AnyObject]? {
        return Activity.cacheActivity()
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        Activity.getActivityList(self.paging(&page)) { (activities, error) in
            self.completeGetting(activities, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
