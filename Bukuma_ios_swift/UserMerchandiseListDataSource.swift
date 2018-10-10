//
//  UserMerchandiseListDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/26.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class UserMerchandiseListDataSource: ExhibitingBookListDataSource {
    
    override var user: User? {
        didSet {
            _ = user.map {
                dataSource = Merchandise.cachedSellingMerchandiseList($0.identifier ?? "") ?? Array()
            }
        }
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if Me.sharedMe.isRegisterd == false || user?.identifier == nil {
            self.completeGetting(nil, shouldRefresh: shouldRefresh, error: nil)
            return
        }
        
        Merchandise.getSellingMerchandiseInfoFromUserId(user!.identifier!,
                                                        page: self.paging(&page)) { (merch, error) in
                                                            self.completeGetting(merch, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    var shouldShowMerchandiseList: Bool {
        if count() == 0  || count() == nil || dataSource == nil {
            return false
        }
        return true
    }
}
