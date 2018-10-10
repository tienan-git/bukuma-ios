//
//  LabelAndImageCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/2/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

class LabelAndImageCell: BaseTableViewCell, NibProtocol {
    typealias NibT = LabelAndImageCell

    @IBOutlet private weak var titleItem: UILabel!
    @IBOutlet private weak var imageItem: UIImageView!

    private static let defaultCellHeight: CGFloat = 44

    override open class func cellHeightForObject(_ object: AnyObject?)-> CGFloat {
        return self.defaultCellHeight
    }

    override open var cellModelObject: AnyObject?  {
        didSet {
            guard let strings = self.cellModelObject as? (titleText: String, imageName: String) else {
                return
            }

            self.titleItem.text = strings.titleText
            self.imageItem.image = UIImage(named: strings.imageName)
        }
    }
}
