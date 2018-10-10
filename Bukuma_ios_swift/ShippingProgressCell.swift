//
//  ShippingProgressCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 5/31/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

protocol ShippingProgressCellProtocol {
    static var defaultCellHeight: CGFloat { get }
    var defaultContentsString: String { get }
}

extension ShippingProgressCellProtocol {
    static var defaultCellHeight: CGFloat { get {
        return 44
        }}
    var defaultContentsString: String { get {
        return "まだ購入されていません"
        }}
}
