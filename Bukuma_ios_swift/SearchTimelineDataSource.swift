//
//  SearchTimelineDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/08.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class SearchTimelineDataSource: BaseDataSource {
    
    open var cateory: Category?
    
    override open func cachedData() ->[AnyObject]? {
        return nil
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if Utility.isEmpty(cateory?.id) {
            self.completeGetting(nil, shouldRefresh: false, error: nil)
            return
        }
        
        Book.getBookInfoFromRootCategoryID(self.paging(&page),
                                           categoryId: cateory!.id!) { (books, error) in
                                            self.completeGetting(books, shouldRefresh: shouldRefresh, error: error)
        }
    }
}
