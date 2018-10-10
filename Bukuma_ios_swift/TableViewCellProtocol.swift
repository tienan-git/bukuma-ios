//
//  TableViewCellProtocol.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/30/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

protocol TableViewCellProtocol {
    associatedtype DataTypeT

    func setup(with data: DataTypeT?)
    static func cellHeight(with data: DataTypeT?) -> CGFloat
}
