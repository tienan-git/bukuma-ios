//
//  AddressAndNameWithDefaultCheckCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 5/31/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

class AddressAndNameWithDefaultCheckCell: AddressAndNameCell {
    @IBOutlet private weak var defaultAddressMark: UIImageView!

    override open var cellModelObject: AnyObject? {
        didSet {
            let address = self.cellModelObject as? Adress
            self.defaultAddressMark.isHidden = address?.isDefaultAdress == false
        }
    }
}
