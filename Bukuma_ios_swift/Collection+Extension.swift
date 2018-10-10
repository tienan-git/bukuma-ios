//
//  Collection+Extension.swift
//  Bukuma_ios_swift
//
//  Created by tani on 2017/05/01.
//  Copyright © 2017年 Labit Inc. All rights reserved.
//

extension Collection where Indices.Iterator.Element == Index {
    
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
