//
//  ExhibitButtonCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/20.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

@objc public protocol ExhibitButtonCellDelegate : NSObjectProtocol {
    func exhibitButtonTapped(_ cell: ExhibitButtonCell)
}

open class ExhibitButtonCell: ExhibitButtonBaseCell {
    override func setup() {
        super.setup()

        self.exhibitButton.addTarget(self, action: #selector(self.exhibitButtonTapped(_:)), for: .touchUpInside)
    }

    override var buttonTitle: String {
        get { return "出品する" }
    }

    override var buttonColor: UIColor {
        get { return kMainGreenColor }
    }

    func exhibitButtonTapped(_ sender: UIButton) {
        (self.delegate as? ExhibitButtonCellDelegate)?.exhibitButtonTapped(self)
    }
}
