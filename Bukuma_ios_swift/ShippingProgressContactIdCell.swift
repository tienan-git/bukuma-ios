//
//  ShippingProgressContactIdCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 5/31/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

class ShippingProgressContactIdCell: BaseTableViewCell, NibProtocol, ShippingProgressCellProtocol {
    typealias NibT = ShippingProgressContactIdCell

    @IBOutlet private weak var title: UILabel!
    @IBOutlet weak var contents: UILabel!

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private func setup() {
        self.title.text = "お問い合わせID"
    }

    override open class func cellHeightForObject(_ object: AnyObject?)-> CGFloat  {
        return self.defaultCellHeight
    }

    override open var cellModelObject: AnyObject? {
        didSet {
            if let transaction = self.cellModelObject as? Transaction {
                if let contactId = transaction.contactId {
                    self.contents.text = contactId
                    return
                }
            }

            self.contents.text = self.defaultContentsString
        }
    }
}
