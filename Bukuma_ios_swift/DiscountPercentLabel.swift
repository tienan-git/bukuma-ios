//
//  DiscountPercentLabel.swift
//  Bukuma_ios_swift
//
//  Created by hara on 2017/03/27.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import UIKit

protocol DiscountPercentProtocol {
    func setup()
    func setTextIfNeeded(with text: String)
    func layoutIfNeeded(with baseItem: UILabel)
}

extension DiscountPercentProtocol where Self: UILabel {
    func setup() {
        self.textColor = kPink01Color
        self.font = UIFont.boldSystemFont(ofSize: 11)
        self.textAlignment = .center
    }

    func setTextIfNeeded(with text: String) {
        if self.isHidden == false {
            self.text = text
            self.sizeToFit() // サイズ調整し layoutSubviews を誘発させる
        }
    }

    // layoutSubviews の最後に追加する
    func layoutIfNeeded(with baseItem: UILabel) {
        let distanceOfBaseAndDiscount: CGFloat = UIScreen.is4inchDisplay() ? 2 : 6

        if self.isHidden == false {
            var frame = self.frame
            frame.origin.x = baseItem.frame.maxX + distanceOfBaseAndDiscount
            frame.origin.y = (baseItem.frame.maxY + baseItem.font.descender) - self.frame.size.height // フォントサイズに依存しない下端揃え
            self.frame = frame
        }
    }
}

class DiscountPercentLabel: UILabel, DiscountPercentProtocol {
}
