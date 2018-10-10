//
//  Array+Extension.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public extension Array {
    
    func indexOfObject<T: Equatable>(_ obj: T) -> Int? {
        if self.count > 0 {
            for (i, objectToCompare) in enumerated().self {
                let to = objectToCompare as! T
                if obj == to {
                    return i
                }
            }
        }
        return nil
    }

    func equalObject<T: Equatable>(_ obj: T) -> T? {
        if self.count > 0 {
            for (objectToCompare) in enumerated().self {
                let to = objectToCompare as! T
                if obj == to {
                    return obj
                }
            }
        }
        return nil
    }

    mutating func removeObject<T: Equatable>(_ obj: T) {
        if self.count > 0 {
            for (i, objectToCompare) in enumerated().self {
                let to = objectToCompare as! T
                if obj == to {
                    self.remove(at: i)
                }
            }
        }
    }
}
