//
//  DeleteAccountReasonCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/20/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

class DeleteAccountReasonCell: UITableViewCell, NibProtocol {
    typealias NibT = DeleteAccountReasonCell

    private var itemDepth: Int = 0

    @IBOutlet private weak var selectedImageView: UIImageView!
    @IBOutlet private weak var reasonText: UILabel!
    @IBOutlet private weak var leftOffset: NSLayoutConstraint!

    func setup(withReason reason: DeleteAccountReasonProtocol) {
        if reason is DeleteAccountReasonHaveChildren {
            self.selectedImageView.image = UIImage(named: "img_closed")
            self.selectedImageView.highlightedImage = UIImage(named: "img_opened")
        } else {
            self.selectedImageView.image = UIImage(named: "img_not_select")
            self.selectedImageView.highlightedImage = UIImage(named: "img_selected")
        }

        self.reasonText.text = reason.itemTitle
        self.reasonText.sizeToFit()

        self.itemDepth = reason.itemDepth

        var cellSize = self.frame.size
        cellSize.height = max(self.selectedImageView.frame.size.height, self.reasonText.frame.size.height, DeleteAccountReasonCell.defaultCellHeight)
        self.frame.size = cellSize
    }

    private let defaultReasonLeft: CGFloat = 10.0

    func leftPosition() -> CGFloat {
        return self.defaultReasonLeft + (self.selectedImageView.frame.size.width * CGFloat(self.itemDepth))
    }

    override open func layoutSubviews() {
        self.leftOffset.constant = self.leftPosition()
        
        super.layoutSubviews()
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.selectedImageView.isHighlighted = selected
    }

    private static let defaultCellHeight: CGFloat = 44.0

    static func cellHeight(withReason reason: DeleteAccountReasonProtocol?) -> CGFloat {
        if let reason = reason {
            if let cell = DeleteAccountReasonCell.fromNib() {
                cell.setup(withReason: reason)
                return max(cell.selectedImageView.frame.size.height, cell.reasonText.frame.size.height, self.defaultCellHeight)
            } else {
                return self.defaultCellHeight
            }
        } else {
            return self.defaultCellHeight
        }
    }
}
