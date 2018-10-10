//
//  BookStore.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/08.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class BookStore: NSObject {
    fileprivate var storedBooks: [String: Book]?
    
    open class var shared: BookStore {
        struct Static {
            static let instance = BookStore()
        }
        return Static.instance
    }
    
    override public init() {
        super.init()
        storedBooks = [:]
    }
    
    open func storeBook(_ book: Book) {
        storedBooks?["\(String(describing: book.identifier))"] = book
    }
    
    open func storedBook(_ identifier: String) ->Book? {
        return storedBooks?["\(identifier)"]
    }
}
