//
//  ShippingProgressPriceCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 5/31/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

class ShippingProgressPriceCell: BaseTableViewCell, NibProtocol, ShippingProgressCellProtocol, SalesCommissionProtocol {
    typealias NibT = ShippingProgressPriceCell

    @IBOutlet private weak var price: UILabel!
    @IBOutlet private weak var commission: UILabel!
    @IBOutlet private weak var benefits: UILabel!
    @IBOutlet private weak var commissionFrame: UIView!
    @IBOutlet private weak var benefitsFrame: UIView!

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private func setup() {
    }

    override open class func cellHeightForObject(_ object: AnyObject?)-> CGFloat  {
        if let transaction = object as? Transaction {
            if transaction.isBuyer() == true ||
                ShippingProgressPriceCell.fromNib()?.isInCommission(withDate: transaction.merchandise?.createdAt) == false {
                return 42.5
            }
        }
        return 118.5
    }

    override open var cellModelObject: AnyObject? {
        didSet {
            if let transaction = self.cellModelObject as? Transaction {
                if let price = Int(transaction.merchandise?.price ?? "0") {
                    self.price.text = "¥\(price.toCommaString())"

                    if transaction.isBuyer() == false && self.isInCommission(withDate: transaction.merchandise?.createdAt) {
                        self.commissionFrame.isHidden = false
                        self.benefitsFrame.isHidden = false

                        let commission = self.commission(fromPrice: price)
                        self.commission.text = "¥\(commission.toCommaString())"

                        let benefits = price - commission
                        self.benefits.text = "¥\(benefits.toCommaString())"
                    } else {
                        self.commissionFrame.isHidden = true
                        self.benefitsFrame.isHidden = true
                    }
                    return
                }
            }

            self.price.text = ""
            self.commission.text = ""
            self.benefits.text = ""
        }
    }
}
