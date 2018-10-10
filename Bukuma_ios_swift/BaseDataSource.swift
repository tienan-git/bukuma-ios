//
//  BKMBaseDataSource.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/08.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

/**
 このClassではtableViewやcollectionViewに使うDataの管理をしています
 HomeDataSource, ActivityDataSourceなどを参考にしてください
 継承先で
 cachedData,updateDatasourceByRefreshDataSourceを設定すれば
 なんかいい感じになるようになってます
 
 */

public let DataSourceShouldRefreshDataSource: String = "DataSourceShouldRefreshDataSource"
public let DataSourceForceRemoveAllMyExistense: String = "DataSourceForceRemoveAllMyExistense"

@objc public protocol BaseDataSourceDelegate{
    func completeRequest() ->Void
    @objc optional func completeRequest(_ dataSource: BaseDataSource) ->Void
    func failedRequest(_ error: Error) ->Void
    @objc optional func failedRequest(_ dataSource: BaseDataSource, error: Error) ->Void
}

open class BaseDataSource: NSObject {
    
    open var dataSource: [AnyObject]? = Array() {
        didSet {
            updatedAt = Date()
        }
    }
    open var isMoreDataSourceAvailable: Bool? = false /// これはpagingをするかどうか。trueなら次のpageをserverへ問い合わせます
    open var updatedAt: Date = Date()
    
    var page: Int = 0
    var isFinishFirstRefresh: Bool = false
    weak var delegate: BaseDataSourceDelegate?
    
    //========================================================================
    // MARK: - setting  子供に処理を書く
    
    open func cachedData() ->[AnyObject]? {
        return nil
    }
    
    open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) ->Void{}
    
    open func removeBlockedUserData(_ userID: String) ->Void{}
    
    //========================================================================
    // MARK: -
    
    deinit {
       NotificationCenter.default.removeObserver(self)
        DBLog("------------dataSource deinit ---------------")
    }
    
    required override public init() {
        super.init()
        if self.cachedData() != nil {
            dataSource?.insert(contentsOf: self.cachedData()!, at: self.count()!)
        } else {
            dataSource? = Array()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.shouldRefreshDataSource(_:)), name: NSNotification.Name(rawValue: DataSourceShouldRefreshDataSource), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeMyExistenseNotification(_:)), name: NSNotification.Name(rawValue: DataSourceForceRemoveAllMyExistense), object: nil)
    }
    
    /// isMoreDataSourceAvailableがtrueの時はpagingをしたい。すなわち、TableLoadMoreCellなどを出したいときなので
    /// countは +1されている
    open func count() ->Int? {
        if dataSource == nil {
            return 0
        }
        
        let correntCount: Int? = isMoreDataSourceAvailable == true ? dataSource!.count + 1 : dataSource!.count
        return correntCount
    }

    open func isOddCount()-> Bool {
        
        if dataSource == nil {
            return false
        }
        
        if dataSource?.count == 1 {
            return true
        }
        
        return dataSource!.count % 2 != 0
    }
    
    /// arrayを全部removeして新しいdataをとってくる時
    ///pulltoRefreshしてとってくる時ですね
    open func refreshDataSource() ->Void {
        if isRefreshing == true {
            return
        }
        page = 0
        isMoreDataSourceAvailable = false
        isRefreshing = true
        self.updateDatasourceByRefreshDataSource(true)
    }
    
    /// そのindexPath.rowのdataですisAllowUpdateがtrueだと。もしTableViewLoadMoreCellが見えてるとき、次のpageを読み込みます
    open func dataAtIndex(_ row: Int, isAllowUpdate: Bool) ->AnyObject? {
        if (dataSource?.count ?? 0) <= row || dataSource?.count == 0 {
            if (isAllowUpdate && dataSource?.count != 0 && isRefreshing == false) {
                self.updateDatasourceByRefreshDataSource(false)
            }
            return nil
        }
        
        return dataSource?[row]
    }
    
    func update() ->Void {/** 子供に処理を書く。なにかアップデートがあったら*/}
    
    func lastData() ->AnyObject! {
        return dataSource?.last
    }
    
    func firstData() ->AnyObject!{
        return dataSource?.first
    }
    
    ///serverから受け取った後、それをarrayに入れてcompleteRequestを呼んであげてます
    ///completeRequestではtableView reloadなどの処理が書かれているかと思います
    open func completeGetting(_ array: [AnyObject]?, shouldRefresh:Bool!, error: Error?) {
        DispatchQueue.main.async(execute: {
            
            self.isRefreshing = false
            
            if let error = error {
                self.delegate?.failedRequest(error)
                self.delegate?.failedRequest?(self, error: error)
                return
            }
            
            if shouldRefresh == true {
                self.dataSource?.removeAll()                
            }
            
            self.isMoreDataSourceAvailable = (array != nil || (array != nil && array?.count != 0))
            
            if array != nil {
                self.dataSource?.insert(contentsOf: array!, at: self.dataSource!.count)
            }
            
            self.update()
            DBLog(self.dataSource?.count)
            
            self.delegate?.completeRequest()
            self.delegate?.completeRequest?(self)
        })
    }
    
    open func paging(_ page: inout Int) ->Int {
        page += 1        
        return page
    }
    
    //========================================================================
    // MARK: - notification
    
    func shouldRefreshDataSource(_ notification: Foundation.Notification){
        self.delegate?.completeRequest()
        self.delegate?.completeRequest?(self)
    }
    
    func removeMyExistenseNotification(_ notification: Foundation.Notification){
        
    }
    
    //========================================================================
    // MARK: - proprty
    open var isRefreshing: Bool? = false {
        didSet {
            if isRefreshing == false {
                isFinishFirstRefresh = true
            }
        }
    }
}
