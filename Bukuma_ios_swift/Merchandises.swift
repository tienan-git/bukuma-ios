//
//  Merchandises.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/21.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

/**
 本の詳細pageへ行くとき
 このMerchandisesを使っています
 本が持っているMerchandiseの情報をあらかじめ取得してから
 画面遷移しないと
 変なanimationが出て
 気持ち悪かったので
 あらかじめ取得して管理することを目的に作られたClassです
 */
open class Merchandises: NSObject {
    
    var dataSource: [Merchandise]?
    var lowestMerchandise: Merchandise?
    var otherMerchandises: [Merchandise]?
    var allMerchandiseCount: Int = 0
    
    override public init() {
        super.init()
    }
    
    open func getMerchandises(_ book: Book?, completion: @escaping (_ err: Error?)->Void) {
        guard let bookId = book?.identifier else {
            completion(nil)
            return
        }

        Merchandise.getMerchandiseFromBook(bookId, page: 1) { [weak self] (merchandises: [Merchandise]?, err: Error?) in
            guard err == nil else {
                completion(err)
                return
            }

            self?.dataSource = merchandises
            self?.lowestMerchandise = book?.lowestMerchandise
            self?.otherMerchandises = self?.createOtherMerchandises(merchandises, lowest: self?.lowestMerchandise)
            completion(nil)
        }
    }

    func moreMerchandises(for book: Book, dataPage page: Int, result completion: @escaping (_ moreMerchandises: [Merchandise]?, _ err: Error?)-> Void) {
        guard let bookId = book.identifier else {
            completion(nil, nil)
            return
        }

        Merchandise.getMerchandiseFromBook(bookId, page: page) { [weak self] (merchandises: [Merchandise]?, err: Error?) in
            guard err == nil else {
                completion(nil, err)
                return
            }
            guard let moreMerchandises = merchandises else {
                completion(nil, nil)
                return
            }

            self?.dataSource?.append(contentsOf: moreMerchandises)
            completion(moreMerchandises, nil)
        }
    }
    
    func createLowestMerchandise(_ merchandises: [Merchandise]?) ->Merchandise? {
        if merchandises?.count == 0 || merchandises == nil {
            return nil
        }
        
        var prices: [Int] = Array()
        for merchandise in merchandises! {
            prices.append(merchandise.price!.int())
        }
        
        let lowestPrice: Int =  prices.min() ?? 0
        
        let lowestMerchandise: Merchandise = merchandises!.filter { (merchandise) -> Bool in
            return merchandise.price!.int() == lowestPrice
            }.first!
        return lowestMerchandise
    }
    
    open func createOtherMerchandises(_ merchandises: [Merchandise]?, lowest: Merchandise?) ->[Merchandise]? {
        if merchandises?.count == 0 || merchandises == nil {
            return nil
        }
        
        var mers = merchandises
        mers!.enumerated().forEach { (index, mer) in
            if mer == lowest {
                mers!.remove(at: index)
            }
        }
        
        return mers
    }

    open func isSellerBeing() ->Bool {
        return count() != 0
    }
    
    open func count() ->Int {
        if dataSource == nil {
            return 0
        }
        return dataSource!.count
    }
}
