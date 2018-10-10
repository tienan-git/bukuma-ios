//
//  UserTimeLineDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/03.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class UserTimeLineDataSource: BaseDataSource {
    
    var user: User? {
        didSet {
            if Me.sharedMe.isMine(user?.identifier ?? "-1") == true {
                dataSource = Review.cachedReviewList() ?? Array()
                if (dataSource?.count ?? 0) >= 50 {
                    isMoreDataSourceAvailable = true
                }
            }
        }
    }
    
    open override func cachedData() -> [AnyObject]? {
        return nil
    }
    
    open override func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if Utility.isEmpty(user?.identifier) {
            self.completeGetting(nil, shouldRefresh: shouldRefresh, error: nil)
            return
        }
        Review.getReviewList(self.paging(&page),
                             userId: user!.identifier!) { (reviews, error) in
                                self.completeGetting(reviews, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
