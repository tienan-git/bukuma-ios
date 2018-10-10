//
//  NewsDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/06.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class NewsDataSource: BaseDataSource {
    
    open override func cachedData() -> [AnyObject]? {
        return Announcement.cachedAnnouncements()
    }
    
    open override func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        Announcement.getAnnouncementsList(self.paging(&page)) { (announcements, error) in
            self.completeGetting(announcements, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
