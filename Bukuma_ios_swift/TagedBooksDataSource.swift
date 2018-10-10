//
//  TagedBooksDataSource.swift
//  Bukuma_ios_swift
//
//  Created by khara on 7/10/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

class TagedBooksDataSource: BaseDataSource {
    var tag: Tag?

    override open func cachedData() -> [AnyObject]? {
        return nil
    }

    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if !shouldRefresh {
            return
        }

        self.tag?.getBooks() { [weak self] (_ books: [Book]?, _ error: Error?) in
            self?.completeGetting(books, shouldRefresh: true, error: error)
        }
    }
}
