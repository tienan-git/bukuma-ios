//
//  AddressAndNameCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 5/25/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

protocol AddressAndNameDataSource {
    var addressStyle: [String: Any] { get }
    var nameStyle: [String: Any] { get }
}

extension AddressAndNameDataSource {
    var addressStyle: [String: Any] { get {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        return [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14),
                NSParagraphStyleAttributeName: paragraphStyle]
        }}
    var nameStyle: [String: Any] { get {
        return [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]
        }}
}

class AddressAndNameCell: BaseTableViewCell, NibProtocol, AddressAndNameDataSource {
    typealias NibT = AddressAndNameCell

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    @IBOutlet private weak var addressAndNameGroup: UIView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!

    private static let emptyAddressString = "未設定"
    private static let emptyNameString = "未設定"

    private func setup() {
        self.addressLabel.attributedText = NSAttributedString(string: AddressAndNameCell.emptyAddressString, attributes: self.addressStyle)
        self.nameLabel.attributedText = NSAttributedString(string: AddressAndNameCell.emptyNameString, attributes: self.nameStyle)
    }

    private class func addressAndNameStrings(from address: Adress?)-> (addressString: String, nameString: String) {
        var addressString = AddressAndNameCell.emptyAddressString
        var nameString = AddressAndNameCell.emptyNameString

        if let address = address {
            if Utility.isEmpty(address.id) == false {
                addressString = "〒\(address.postalCode!)\n\(address.prefecture!)\(address.city!)\(address.houseNumberAdressLine!)"
                nameString = "\(address.personName!) 様"

                if Utility.isEmpty(address.buildingNameAdressLine) == false {
                    addressString = addressString + "\n\(address.buildingNameAdressLine!)"
                }
                if Utility.isEmpty(address.personPhone?.currentPhoneNumber) == false {
                    addressString = addressString + "\n\(address.personPhone!.currentPhoneNumber!)"
                }
            }
        }

        return (addressString, nameString)
    }

    private static let minCellHeight: CGFloat = 50
    private static let cellTopMargin: CGFloat = 4
    private static let cellBottomMargin: CGFloat = 18
    private static let addressAndNameSpace: CGFloat = 4

    override open class func cellHeightForObject(_ object: AnyObject?)-> CGFloat {
        guard let cell = self.fromNib() else {
            return self.minCellHeight
        }
        cell.cellModelObject = object

        // 詳細不明だが、このタイミングでセル全体の高さがうまく計算できないようなので、値の取れるパーツから高さを計算
        let addressHeight = cell.addressLabel.frame.size.height
        let nameHeight = cell.nameLabel.frame.size.height
        let cellHeight = self.cellTopMargin + addressHeight + self.addressAndNameSpace + nameHeight + self.cellBottomMargin
        return cellHeight > self.minCellHeight ? cellHeight : self.minCellHeight
    }

    override open var cellModelObject: AnyObject? {
        didSet {
            let address = self.cellModelObject as? Adress

            let strings = AddressAndNameCell.addressAndNameStrings(from: address)
            self.addressLabel.attributedText = NSAttributedString(string: strings.addressString, attributes: self.addressStyle)
            self.addressLabel.sizeToFit()
            self.nameLabel.attributedText = NSAttributedString(string: strings.nameString, attributes: self.nameStyle)
            self.nameLabel.sizeToFit()

            self.layoutIfNeeded()
        }
    }

    func pastableText()-> String {
        return (self.addressLabel.text ?? "") + "\n" + (self.nameLabel.text ?? "")
    }
}
