//
//  HomeDataSource.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/08.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class HomeDataSource: BaseDataSource {
    
    open var tabIndex: Int?
    open var category: Category?
    open var url: String?
    open var title: String?
    
    override open func cachedData() ->[AnyObject]? {
        return nil
    }

    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if let url = url {
            let path = url.replacingOccurrences(of: "^/", with: "", options: .regularExpression, range: nil)
            getBooks(url: path, shouldRefresh: shouldRefresh)
            return
        }
        
        if let categoryId = category?.id {
            getBooks(categoryId: categoryId, shouldRefresh: shouldRefresh)
            return
        }
        
        self.completeGetting(nil, shouldRefresh: false, error: nil)
        isRefreshing = false
    }
    
    private func getBooks(url: String, shouldRefresh: Bool) {
        Book.getBookInfoFromUrl(paging(&page), url: url, completion: { [weak self] (books, title, error) in
            self?.title = title
            self?.completeGetting(books, shouldRefresh: shouldRefresh, error: error)
        })
    }
    
    private func getBooks(categoryId: String, shouldRefresh: Bool) {
        Book.getBookInfoFromRootCategoryID(paging(&page), categoryId: categoryId, completion: {
            [weak self] (books, error) in
            self?.completeGetting(books, shouldRefresh: shouldRefresh, error: error)
        })
    }
}
