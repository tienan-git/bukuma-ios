//
//  LikeListDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/30.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class LikeListDataSource: BaseDataSource {
    
    override open func cachedData() ->[AnyObject]? {
        return Book.cachedLikedBookList()
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if Me.sharedMe.isRegisterd == false {
            self.completeGetting(nil, shouldRefresh: shouldRefresh, error: nil)
            return
        }
        
        Book.getLikedBook(self.paging(&page)) { (books, error) in
            self.completeGetting(books, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
