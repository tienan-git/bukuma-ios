//
//  SearchHistoryCache.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/13.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

let SearchHistoryCacheInfoKey: String = "SearchHistoryCacheInfoKey"

open class SearchHistoryCache: NSObject {
    
    var histories: Array<String>? = []
    var isMoreShowNext: Bool = false
    var shouldShowLoadMore: Bool {
        if canLoadNextPage(0) == true {
            if canLoadNextPage(1) == true {
                if isMoreShowNext == true {
                    return false
                }
            }
            if isMoreShowNext == true {
                return false
            }
            return true
        }
        return false
    }
    
    open class var shared: SearchHistoryCache {
        struct Static {
            static let instance = SearchHistoryCache()
        }
        return Static.instance
    }
    
    override public init() {
        super.init()
        
        histories = JSONCache.cachedArrayListWithKey(SearchHistoryCacheInfoKey) as? [String] ?? []
        DBLog("SearchHistoryCacheInfoKey: \(String(describing: histories))")
    }
    
    open func addHistory(_ string: String?) {
        let history: String? = string?.trimmingCharacters(in: CharacterSet.whitespaces).uppercased()
        if Utility.isEmpty(history) {
            return
        }
        
        if histories?.contains(history!) == true {
            return
        }
        
        //  save < 100
        if count() < 100 {
            histories?.insert(history!, at: 0)
        }

        self.save()
    }
    
    fileprivate func save() {
        JSONCache.cacheArray(histories!, key: SearchHistoryCacheInfoKey)
    }
    
    open func historyName(_ index: Int) ->String? {
        if (histories?.count ?? 0) <= index {
            return nil
        }
        
        return (histories?.filter{String(describing: $0) != ""}[index]).flatMap{String(describing: $0)}
    }
    
    open func count() ->Int {
        return  (histories?.filter{String(describing: $0) != ""})?.count ?? 0
    }
    
    open func countMax5() ->Int {
        if count() > 5 {
            return 5
        }
        return count()
    }
    
    open func latest5Histories() -> [String]{
        var array: [String] = []
        for i in 0 ... 4 {
            if count() > i && count() > 0 {
                array.append(histories![i])
            }
        }
        return array
    }
    
    fileprivate func latest5Count() ->Int {
        return latest5Histories().count
    }
    
    fileprivate func canLoadNextPage(_ page: Int) ->Bool {
        // page = 0 is ~ 5, page 1 is ~ 50, page 2 is ~ 100
        if page == 0 {
            if count() <= 5 {
                return false
            }
            if count() > 5 && count() <= 50 {
                return true
            }
        }
        if page == 1 {
            if count() > 50 {
                return true
            }
            return false
        }
        if page == 2 {
            return false
        }
        return  false
    }

    func showableCount() ->Int {
        if canLoadNextPage(0) == true {
            if canLoadNextPage(1) == true {
                if isMoreShowNext == true {
                    return count()
                }
                return 50
            } else {
                if isMoreShowNext == true {
                    return count()
                }
                return latest5Count()
            }
        } else {
            return latest5Count()
        }
    }

    func deleteHistoryAtRow(_ row: Int) {
        if count() > row - 1 {
            histories?.remove(at: row - 1)
        }
        
        self.save()
    }
    
    open func deleteHistoryCache() {
        histories?.removeAll()
        
        let defs = UserDefaults.standard
        defs.removeObject(forKey: SearchHistoryCacheInfoKey)
        defs.synchronize()
        
    }
}
