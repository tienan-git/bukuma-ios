//
//  ExhibitingBookListDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/04/26.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class ExhibitingBookListDataSource: BaseDataSource {
    
    var user: User? {
        didSet {
            _ = user.map {
                dataSource = Merchandise.cachedMensionMerchandiseList($0.identifier ?? "") ?? Array()
            }
        }
    }
    
    override open func cachedData() ->[AnyObject]? {
        return nil
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if Me.sharedMe.isRegisterd == false || user?.identifier == nil {
            self.completeGetting(nil, shouldRefresh: shouldRefresh, error: nil)
            return
        }
        
        Merchandise.getMerchandiseInfoFromUserId(self.user!.identifier!,
                                                 page: self.paging(&self.page)) { (merch, error) in
                                                    self.completeGetting(merch, shouldRefresh: shouldRefresh, error: error)
                                                    
        }
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
