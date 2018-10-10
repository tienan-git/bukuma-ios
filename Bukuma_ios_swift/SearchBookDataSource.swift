
//
//  SeachCategoryDataSource.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/15.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

let SearchBookDataSourceStartCreatingSearchOrderKey = "SearchBookDataSourceStartCreatingSearchOrderKey"
let SearchBookDataSourceFinishCreatingSearchOrderKey = "SearchBookDataSourceFinishCreatingSearchOrderKey"
let SearchBookDataSourceNoBooksFromSearchOrderKey = "SearchBookDataSourceNoBooksFromSearchOrderKey"
let SearchBookDataSourceShouldShowLoadMoreView = "SearchBookDataSourceShouldShowLoadMoreView"

open class SearchBookDataSource: BaseDataSource {
    
    var FinishSearching: Bool = false
    var searchText: String?
    var shouldGetFromAmazon: Bool = false
    var isCreatingSearchOrder: Bool = false
    
    func setNewSearchText(_ newText: String?, completion: (() ->Void)?) {
        searchText = newText
        ApiClient.sharedClient.cancel()
        if searchText == nil || searchText == "" {
            self.cancelTimer()
        }
        completion?()
    }
    
    var timer: Timer?

    override open func cachedData() ->[AnyObject]? {
        return nil
    }
    
    deinit {
        searchText = nil
        self.cancelTimer()
    }
    
    func cancelTimer() {
        SearchBookDataSource.retryCount = 0
        timer?.invalidate()
        timer = nil
    }
    
    func paging(_ page: inout Int, enablePaging: Bool) -> Int {
        if enablePaging == true {
            return super.paging(&page)
        }
        return page
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if shouldRefresh == true {
            
        }
        self.getFromOurServer()
    }
    
    func getFromOurServerAndAmazonOrRakuten() {
        if Utility.isEmpty(self.searchText) || self.searchText?.isEmpty == true || self.searchText == "" || self.searchText == " " {
            self.completeGetting(nil, shouldRefresh: true, error: nil)
            return
        }
        
        if (self.dataSource?.count ?? 0) < 50 && isFinishFirstRefresh {
            page = 0
            self.getFromAmazonOrRakuten()
            return
        }
        
        DBLog(self.page)
        
        Book.searchBook(self.searchText,
                        type: .keyword,
                        page: self.paging(&page, enablePaging: true)) { (books, error) in
                            if books == nil || Utility.isEmpty(books?[0].title) == true && error == nil {
                                self.getFromAmazonOrRakuten()
                                return
                            }
                            self.completeGetting(books, shouldRefresh: false, error: error)
        }
    }
    
    func getFromOurServer() {
        
        if Utility.isEmpty(self.searchText) || self.searchText?.isEmpty == true || self.searchText == "" || self.searchText == " " {
            self.completeGetting(nil, shouldRefresh: true, error: nil)
            return
        }
        
        Book.searchBook(self.searchText,
                        type: .keyword,
                        page: 1) { (books, error) in
                            self.completeGetting(books, shouldRefresh: true, error: error)
        }
    }
    
    func getFromAmazonOrRakuten() {
        if Utility.isEmpty(self.searchText) || self.searchText?.isEmpty == true || self.searchText == "" || self.searchText == " " {
            self.completeGetting(nil, shouldRefresh: true, error: nil)
            return
        }

        self.FinishSearching = false
        isCreatingSearchOrder = true
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: SearchBookDataSourceStartCreatingSearchOrderKey), object: nil)
        
        Book.createSearchOrder(self.searchText!, type: .keyword, completion: { (order, error) in
            if order?.isFinish == true && error == nil {
                self.cancelTimer()
                self.FinishSearching = true
                DBLog(self.page)
                
                Book.searchBook(self.searchText, type: .keyword, page: self.paging(&self.page, enablePaging: true), completion: { (books, error) in
                    self.completeGetting(books, shouldRefresh: false, error: error)
                })
            } else {
                if order == nil {
                    self.completeGetting(nil, shouldRefresh: false, error: error)
                    return
                }
                Book.getSearchOrderStatusFromId(order!, completion: { (order, error) in
                    if order?.isFinish == true {
                        self.FinishSearching = true
                        DBLog(self.page)
                        
                        Book.searchBook(self.searchText, type: .keyword, page: self.paging(&self.page, enablePaging: true), completion: { (books, error) in
                            self.completeGetting(books, shouldRefresh: false, error: error)
                        })
                    } else {
                        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.repeatReqestOrder(_:)), userInfo: order, repeats: true)
                       // RunLoop.currentRunLoop().addTimer(self.timer ?? Timer(), forMode: RunLoopMode.defaultRunLoopMode)
                        self.timer?.fire()
                    }
                })
            }
        })
    }

    override func update() {
        isMoreDataSourceAvailable = false
    }
    
    static var retryCount: Int = 0
    static var isRetry: Bool = false
    func repeatReqestOrder(_ timer: Timer?) {
        if let order = timer?.userInfo as? SearchOrder {
            Book.getSearchOrderStatusFromId(order, completion: {[weak self] (order, error) in
                if order?.isFinish == true {
                    self?.FinishSearching = true
                    SearchBookDataSource.isRetry = false
                    self?.cancelTimer()
                    
                    Book.searchBook(order?.keyword, type: .keyword, page: self?.paging(&self!.page, enablePaging: true), completion: {[weak self] (books, error) in
                        if error != nil {
                            self?.cancelTimer()
                            self?.FinishSearching = true

                        }
                        if books != nil {
                            self?.cancelTimer()
                            self?.FinishSearching = true
                        }
                        self?.completeGetting(books, shouldRefresh: false, error: error)
                        })
                } else {
                    SearchBookDataSource.retryCount += 1
                    SearchBookDataSource.isRetry = true
                    if SearchBookDataSource.retryCount > 4 {
                        Book.searchBook(order?.keyword, type: .keyword, page: self?.paging(&self!.page, enablePaging: true), completion: {[weak self] (books, error) in
                            DispatchQueue.main.async {
                                SearchBookDataSource.isRetry = false
                                self?.cancelTimer()
                                self?.FinishSearching = true

                                if books == nil {
                                    self?.completeGetting(books, shouldRefresh: false, error: error)
                                    return
                                }
                                
                                self?.completeGetting(books, shouldRefresh: false, error: error)
                            }
                            })
                    }
                }
                })
        }
    }
    
    override open func completeGetting(_ array: [AnyObject]?, shouldRefresh: Bool!, error: Error?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: SearchBookDataSourceFinishCreatingSearchOrderKey), object: nil)

            if self.page == 0 && shouldRefresh == true {
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: SearchBookDataSourceShouldShowLoadMoreView), object: nil)
                super.completeGetting(array, shouldRefresh: shouldRefresh, error: error)
                return
            }
            
            if (self.dataSource?.count ?? 0) < 50 && self.page == 1 {
                if array != nil && array?.count == self.dataSource?.count && self.isCreatingSearchOrder == true {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: SearchBookDataSourceNoBooksFromSearchOrderKey), object: shouldRefresh)
                }
                super.completeGetting(array, shouldRefresh: true, error: error)
            } else {
                super.completeGetting(array, shouldRefresh: shouldRefresh, error: error)
            }
            if (array == nil || array?.count == 0) && self.isCreatingSearchOrder == true {
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: SearchBookDataSourceNoBooksFromSearchOrderKey), object: shouldRefresh)

                            }
            if self.isCreatingSearchOrder == true {
                self.isCreatingSearchOrder = false
            }
        }
    }

    // MARK: - Suggest

    func getSuggestWords(withKeyword keyword: String, completion: ((_ gotSuggests: Bool)-> Void)?) {
        Book.suggestWords(withKeyword: keyword) { [weak self] (_ suggestWords: [String]?, _ error: Error?) in
            if error == nil {
                if let words = suggestWords {
                    if words.count > 0 {
                        self?.completeGetting(suggestWords as [AnyObject]?, shouldRefresh: true, error: error)
                        completion?(true)
                        return
                    }
                }
                self?.completeGetting(nil, shouldRefresh: true, error: error)
            }
            completion?((self?.dataSource?.count ?? 0) > 0)
        }
    }

    func clearSuggestWords() {
        self.completeGetting(nil, shouldRefresh: true, error: nil)
    }
}
