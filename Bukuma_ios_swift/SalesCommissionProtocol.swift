//
//  SalesCommissionProtocol.swift
//  Bukuma_ios_swift
//
//  Created by khara on 9/28/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

protocol SalesCommissionProtocol {
    func isInCommission(withDate: Date?) -> Bool
    func commission(fromPrice: Int) -> Int
}

extension SalesCommissionProtocol {
    func isInCommission(withDate: Date? = nil) -> Bool {
        guard let salesCommissionDateString = ExternalServiceManager.salesCommissionDate,
            let salesCommissionDate = self.date(fromString: salesCommissionDateString) else {
                return false
        }
        let date = withDate == nil ? Date() : withDate!
        return salesCommissionDate < date
    }

    private func date(fromString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.date(from: fromString)
    }

    func commission(fromPrice: Int) -> Int {
        let salesCommissionPercent = CGFloat(ExternalServiceManager.salesCommissionPercent)
        let commission = Int(CGFloat(fromPrice) * CGFloat(salesCommissionPercent / 100.0))
        return commission
    }
}
