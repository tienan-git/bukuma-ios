//
//  ShippingProgressBoughtDateCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 5/31/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

class ShippingProgressBoughtDateCell: BaseTableViewCell, NibProtocol, ShippingProgressCellProtocol {
    typealias NibT = ShippingProgressBoughtDateCell

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var contents: UILabel!

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private func setup() {
        self.title.text = "購入した日時"
    }

    override open class func cellHeightForObject(_ object: AnyObject?)-> CGFloat  {
        return self.defaultCellHeight
    }

    override open var cellModelObject: AnyObject? {
        didSet {
            if let transaction = self.cellModelObject as? Transaction {
                if let date = transaction.date as Date? {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
                    self.contents.text = dateFormatter.string(from: date)
                    return
                }
            }

            self.contents.text = self.defaultContentsString
        }
    }
}
