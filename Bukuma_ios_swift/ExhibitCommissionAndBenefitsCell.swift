//
//  ExhibitCommissionAndBenefitsCell.swift
//  Bukuma_ios_swift
//
//  Created by khara on 9/25/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import UIKit
import SwiftTips

class ExhibitCommissionAndBenefitsCell: UITableViewCell, NibProtocol, SalesCommissionProtocol {
    typealias NibT = ExhibitCommissionAndBenefitsCell

    @IBOutlet weak var commissionValue: UILabel!
    @IBOutlet weak var benefitsValue: UILabel!

    static var cellHeight: CGFloat {
        return 84
    }

    func reflect(withPrice: Int) {
        if withPrice >= ExternalServiceManager.minPrice {
            let commission = self.commission(fromPrice: withPrice)
            let benefits = withPrice - commission
            self.commissionValue.text = "¥" + commission.toCommaString()
            self.benefitsValue.text = "¥" + benefits.toCommaString()
        } else {
            self.commissionValue.text = "-"
            self.benefitsValue.text = "¥0"
        }
    }
}
