//
//  TagCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/30/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

protocol TagCellDelegate: class {
    func tappedLikes(withTagData tagData: Tag) -> Bool // true: タップ有効, false: タップ無効
}

class TagCell: UITableViewCell, NibProtocol, TableViewCellProtocol {
    typealias NibT = TagCell
    typealias DataTypeT = Tag

    weak var delegate: TagCellDelegate?

    @IBOutlet private weak var tagNames: UILabel!
    @IBOutlet private weak var numberOfLikes: UILabel!
    @IBOutlet private weak var addTagImage: UIImageView!

    private var tagData: Tag?

    private let tagNameFormat: String = "%@（%d件）"

    func setup(with data: Tag?) {
        self.tagData = data

        self.tagNames.text = String(format: self.tagNameFormat, data?.displayName ?? "", data?.numberOfBooks ?? 0)
        self.setLikesColor(asLiked: data?.isVoted == true)
        self.setNumberOfLikes(is: data?.numberOfVotes ?? 0)

        self.numberOfLikes.isUserInteractionEnabled = true
        let tapHandler = UITapGestureRecognizer(target: self, action: #selector(self.tappedLikes(_:)))
        self.numberOfLikes.addGestureRecognizer(tapHandler)
    }

    private let likesFont = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
    private let likesTextColor = UIColor.white
    private let likesFillColor = UIColor(red: 251/255, green: 98/255, blue: 118/255, alpha: 1.0)
    private let likesFrameSize = CGFloat(0)
    private let likesFrameColor = UIColor.white.cgColor

    private let yetLikesFont = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
    private let yetLikesTextColor = UIColor(red: 255/255, green: 86/255, blue: 117/255, alpha: 1.0)
    private let yetLikesFillColor = UIColor.white
    private let yetLikesFrameSize = CGFloat(1.0)
    private let yetLikesFrameColor = UIColor(red: 255/255, green: 86/255, blue: 117/255, alpha: 1.0).cgColor

    private func setLikesColor(asLiked liked: Bool) {
        if liked {
            self.numberOfLikes.font = self.likesFont
            self.numberOfLikes.textColor = self.likesTextColor

            self.numberOfLikes.backgroundColor = self.likesFillColor

            self.numberOfLikes.layer.borderWidth = self.likesFrameSize
            self.numberOfLikes.layer.borderColor = self.likesFrameColor

            self.addTagImage.isHidden = true
        } else {
            self.numberOfLikes.font = self.yetLikesFont
            self.numberOfLikes.textColor = self.yetLikesTextColor

            self.numberOfLikes.backgroundColor = self.yetLikesFillColor

            self.numberOfLikes.layer.borderWidth = self.yetLikesFrameSize
            self.numberOfLikes.layer.borderColor = self.yetLikesFrameColor

            self.addTagImage.isHidden = false
        }
    }

    private let minNumberOfLikesSize = CGSize(width: 24.0, height: 24.0)
    private let numberOfLikesMargin = CGFloat(14.0)
    private let maxNumberOfLikes = Int(1000)

    private func setNumberOfLikes(is numberOfLikes: Int) {
        self.numberOfLikes.text = numberOfLikes > self.maxNumberOfLikes ? String(self.maxNumberOfLikes) + "+" : String(numberOfLikes)

        self.numberOfLikes.sizeToFit()
        var viewSize = self.numberOfLikes.frame.size
        if viewSize.width < self.minNumberOfLikesSize.width {
            viewSize.width = self.minNumberOfLikesSize.width
        }
        if viewSize.height < self.minNumberOfLikesSize.height {
            viewSize.height = self.minNumberOfLikesSize.height
        }
        self.numberOfLikes.frame.size = viewSize

        self.numberOfLikes.setNeedsLayout()
    }

    private static let defaultCellHeight = CGFloat(44.0)

    static func cellHeight(with data: Tag?) -> CGFloat {
        let cell = TagCell.fromNib()
        cell?.setup(with: data)
        return cell?.frame.size.height ?? self.defaultCellHeight
    }

    func tappedLikes(_ sender: Any) {
        guard let tagData = self.tagData else {
            return
        }

        if self.delegate?.tappedLikes(withTagData: tagData) == true {
            self.setLikesColor(asLiked: tagData.isVoted)
            self.setNumberOfLikes(is: tagData.numberOfVotes)
        }
    }
}
