//
//  InviteDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/30.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class InviteDataSource: BaseDataSource {
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if Me.sharedMe.isRegisterd == false {
            completeGetting(nil, shouldRefresh: shouldRefresh, error: nil)
            return
        }
        Invite.getInviteList { (invite, error) in
            self.completeGetting(invite, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
    
    override open func update() {
        isMoreDataSourceAvailable = false
    }
}
