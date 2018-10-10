//
//  AdressDataSource.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/18.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class AdressDataSource: BaseDataSource {
    
    override open func cachedData() ->[AnyObject]? {
        return nil
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        Adress.getAdressList { (adresses, error) in
            self.completeGetting(adresses, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override open func update() {
        isMoreDataSourceAvailable = false
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
