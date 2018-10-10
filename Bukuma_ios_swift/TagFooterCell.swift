//
//  TagFooterCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/30/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

class TagFooterCell: UITableViewCell, NibProtocol, TableViewCellProtocol {
    typealias NibT = TagFooterCell
    typealias DataTypeT = Any

    @IBOutlet private weak var cellTitle: UILabel!

    private let titleString: String = "もっと見る"

    func setup(with data: Any? = nil) {
        self.cellTitle.text = self.titleString
    }

    static func cellHeight(with data: Any? = nil) -> CGFloat {
        return 44.0
    }
}
