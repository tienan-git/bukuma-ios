//
//  SearchMerchandiseDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/25.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


class SearchMerchandiseDataSource: BaseDataSource {
    
    var searchText: String?
    
    func setNewSearchText(_ newText: String?) {
        searchText = newText
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if Utility.isEmpty(self.searchText) || self.searchText?.isEmpty == true || self.searchText == "" || self.searchText == " " {
            self.completeGetting(nil, shouldRefresh: true, error: nil)
            return
        }
        
        Book.searchBook(self.searchText,
                        type: .keyword,
                        page: self.paging(&page)) { (books, error) in
                            self.completeGetting(books, shouldRefresh: shouldRefresh, error: error)
        }
    }
}
