//
//  TagHeaderCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/30/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

protocol TagHeaderCellDelegate: class {
    func beginEditTags(completion: ((_ isEditable: Bool) -> Void)?)
    func endEditTags(completion: (() -> Void)?)
}

class TagHeaderCell: UITableViewCell, NibProtocol, TableViewCellProtocol {
    typealias NibT = TagHeaderCell
    typealias DataTypeT = Any

    weak var delegate: TagHeaderCellDelegate?

    @IBOutlet private weak var cellTitle: UILabel!
    @IBOutlet private weak var addTagButton: UIButton!

    private let titleString: String = "タグ一覧"
    private let tagButtonString: String = "＋タグを追加"
    private let tagButtonTitleColor = UIColor(red: 129/255, green: 129/255, blue: 136/255, alpha: 1.0)
    private let tagButtonAddingTitleColor = UIColor(red: 255/255, green: 86/255, blue: 117/255, alpha: 1.0)
    private let tagButtonMargin = CGFloat(16.0)
    private let tagButtonFrameSize = CGFloat(1.0)
    private let tagButtonFrameColor = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1.0)
    private let tagButtonAddingColor = UIColor(red: 255/255, green: 86/255, blue: 117/255, alpha: 1.0)

    func setup(with data: Any? = nil) {
        self.cellTitle.text = self.titleString
        self.addTagButton.setTitle(self.tagButtonString, for: .normal)
        self.addTagButton.setTitleColor(self.tagButtonTitleColor, for: .normal)
        self.addTagButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: self.tagButtonMargin, bottom: 0, right: self.tagButtonMargin)
        self.addTagButton.addFrame(frameThickness: self.tagButtonFrameSize, frameColor: self.tagButtonFrameColor, frameCorner: self.addTagButton.frame.size.height / 2)
    }

    static func cellHeight(with data: Any? = nil) -> CGFloat {
        return 44.0
    }

    var addingTag: Bool = false {
        didSet {
            let frameColor = self.addingTag ? self.tagButtonAddingColor : self.tagButtonFrameColor
            self.addTagButton.layer.borderColor = frameColor.cgColor
            let titleColor = self.addingTag ? self.tagButtonAddingTitleColor : self.tagButtonTitleColor
            self.addTagButton.setTitleColor(titleColor, for: .normal)
        }
    }

    @IBAction func tappedAddTagButton(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false

        if self.addingTag == false {
            self.delegate?.beginEditTags() { (_ isEditable: Bool) in
                if isEditable {
                    self.addingTag = true
                }
                sender.isUserInteractionEnabled = true
            }
        } else {
            self.delegate?.endEditTags() { () in
                self.addingTag = false
                sender.isUserInteractionEnabled = true
            }
        }
    }
}
