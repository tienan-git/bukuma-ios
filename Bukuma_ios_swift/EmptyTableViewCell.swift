//
//  EmptyTableViewCell.swift
//  Bukuma_ios_swift
//
//  Created by khara on 9/26/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {
    init(withHeight: CGFloat) {
        super.init(style: .default, reuseIdentifier: "EmptyTableViewCell")

        var size = self.frame.size
        size.height = withHeight
        self.frame.size = size

        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
