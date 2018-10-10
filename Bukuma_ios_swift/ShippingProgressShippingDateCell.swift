//
//  ShippingProgressShippingDateCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 5/31/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

class ShippingProgressShippingDateCell: BaseTableViewCell, NibProtocol, ShippingProgressCellProtocol {
    typealias NibT = ShippingProgressShippingDateCell

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var contents: UILabel!
    @IBOutlet private weak var shippingDays: UILabel!

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private func setup() {
        self.title.text = "発送予定日"
    }

    static var defaultCellHeight: CGFloat = 58

    override open class func cellHeightForObject(_ object: AnyObject?)-> CGFloat  {
        return self.defaultCellHeight
    }

    override open var cellModelObject: AnyObject? {
        didSet {
            if let transaction = self.cellModelObject as? Transaction {
                if let date = transaction.date as Date? {
                    let additionalDays = Merchandise.shippingDay(by: transaction.merchandise?.shipInDay ?? 0)
                    let shippingDate = date.dateByAddingDays(additionalDays)

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy年MM月dd日頃"
                    self.contents.text = dateFormatter.string(from: shippingDate)

                    self.shippingDays.text = "発送までの目安 " + Merchandise.shippingDaysRange(by: transaction.merchandise?.shipInDay ?? 0)
                    return
                }
            }

            self.contents.text = self.defaultContentsString
        }
    }
}
