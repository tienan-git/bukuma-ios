//
//  ChatMensionDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class ChatMensionDataSource: BaseDataSource {
    
    var user: User? {
        didSet {
            _ = user.map {
                if Merchandise.cachedMensionMerchandiseList($0.identifier!) != nil {
                    if dataSource == nil || dataSource?.count == 0 {
                        dataSource =  Merchandise.cachedMensionMerchandiseList($0.identifier!) ?? Array()
                        if (dataSource?.count ?? 0) >= 50 {
                            isMoreDataSourceAvailable = true
                        }
                    }
                }
            }
        }
    }
    
    override open func cachedData() ->[AnyObject]? {
        return nil
    }

    func changeDataSource(_ userId: String) {
        dataSource?.removeAll()
        dataSource =  Merchandise.cachedMensionMerchandiseList(userId) ?? Array()
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if Utility.isEmpty(user?.identifier) {
            completeGetting(nil, shouldRefresh: shouldRefresh, error: nil)
            return
        }
        
        Merchandise.getMerchandiseInfoFromUserId(user?.identifier ?? "",
                                                 page: self.paging(&page)) { (merch, error) in
                                                    self.completeGetting(merch, shouldRefresh: shouldRefresh, error: error)
        }
    }
}
