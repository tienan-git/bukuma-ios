//
//  SwiftyJSON+Extension.swift
//  Bukuma_ios_swift
//
//  Created by tani on 2017/06/12.
//  Copyright © 2017年 Labit Inc. All rights reserved.
//

import SwiftyJSON

extension JSON {
    var date: Date? {
        guard let value = self.double, value > 0 else {
            return nil
        }
        return Date(timeIntervalSince1970: value)
    }
}
