//
//  DetailHomeDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/02.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class DetailHomeDataSource: BaseDataSource {
    
    var book: Book?
    
    open override func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if book?.identifier == nil {
            self.completeGetting(nil, shouldRefresh: shouldRefresh, error: nil)
            return
        }
        
        Merchandise.getMerchandiseFromBook(book!.identifier!,
                                           page: self.paging(&page)) { (merch, error) in
                                            self.completeGetting(merch, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override open func update() {
        isMoreDataSourceAvailable = false
    }
    
    open func lowestMerchandise() ->Merchandise {
        if count() == 0 {
            let merchandise: Merchandise = Merchandise()
            merchandise.id = "-1"
            merchandise.book = book
            return merchandise
        }
        
        let merchandises: [Merchandise] = dataSource as! [Merchandise]
        
        var prices: [Int] = Array()
        for merchandise in merchandises {
            prices.append(merchandise.price!.int())
        }
        
        let lowestPrice: Int =  prices.min() ?? 0
        
        let lowestMerchandise: Merchandise = merchandises.filter { (merchandise) -> Bool in
            return merchandise.price!.int() == lowestPrice
        }.first!
        return lowestMerchandise
    }
    
    open func otherMerchandises() ->[Merchandise]? {
        if count() == 0 {
            return nil
        }
        
        var merchandises: [Merchandise] = dataSource as! [Merchandise]
        
        merchandises.enumerated().forEach { (index, mer) in
            if mer == self.lowestMerchandise() {
                merchandises.remove(at: index)
            }
        }

        return merchandises
    }
    
    open func isSellerBeing() ->Bool {
        return count() ?? 0 != 0
    }
}
