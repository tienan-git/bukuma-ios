//
//  ShippingProgressBookInfoCell.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/1/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

class ShippingProgressBookInfoCell: BaseTableViewCell, NibProtocol {
    typealias NibT = ShippingProgressBookInfoCell

    @IBOutlet private weak var fixedImageBox: UIView!
    @IBOutlet private weak var bookImage: UIImageView!
    @IBOutlet private weak var bookTitle: UILabel!
    @IBOutlet private weak var bookAuthor: UILabel!
    @IBOutlet private weak var bookPublisher: UILabel!
    @IBOutlet private weak var shippingInfo: UILabel!
    @IBOutlet private weak var merchandiseStatus: UILabel!
    @IBOutlet private weak var tappableViewMark: UIImageView!
    @IBOutlet private weak var bookTitleGroupBox: UIView!
    @IBOutlet private weak var shippingInfoGroupBox: UIView!

    override open func awakeFromNib() {
        super.awakeFromNib()
    }

    override open class func cellHeightForObject(_ object: AnyObject?)-> CGFloat {
        guard let cell = self.fromNib() else {
            return 0
        }
        // 設定値の不具合か AutoLayout 自体の不具合かの判別はできなかったが、先に充分大きくしておいてから Layout しないとうまくいかなかったためこうしている
        var frame = cell.frame
        frame.size.height = 1000
        cell.frame = frame

        cell.cellModelObject = object
        let cellHeight = cell.shippingInfoGroupBox.frame.maxY
        return UIScreen.is4inchDisplay() ? cellHeight + self.magicNumberFor4inch : cellHeight
    }

    override open var cellModelObject: AnyObject? {
        didSet {
            guard let transaction = self.cellModelObject as? Transaction else {
                return
            }

            self.bookImage.frame.size = self.bookImage.resizedImageSize(self.realImageSize(from: transaction.book),
                                                                        fixedHeight: self.fixedImageBox.frame.size.height,
                                                                        fixedWidth: self.fixedImageBox.frame.size.width)

            if transaction.book?.coverImage?.url != nil {
                self.bookImage.downloadImageWithURL(transaction.book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)
            } else {
                self.bookImage.image = kPlacejolderBookImage
            }

            self.bookTitle.text = transaction.book?.titleText()
            self.bookAuthor.text = transaction.book?.author?.name
            self.bookPublisher.text = transaction.book?.publisher?.name

            self.shippingInfo.attributedText = self.makeShippingInfoString(from: transaction.merchandise)
            self.shippingInfo.sizeToFit()
            self.merchandiseStatus.text = "商品の状態: " + (transaction.merchandise?.statusString() ?? "")
            self.merchandiseStatus.sizeToFit()

            self.layoutIfNeeded()
        }
    }

    private let underShippingInfoMargin: CGFloat = 4.0
    private static let magicNumberFor4inch: CGFloat = 20.0

    override func layoutSubviews() {
        super.layoutSubviews()

        // 4 インチスクリーンでのズレ補正
        var merchandiseStatusFrame = self.merchandiseStatus.frame
        if merchandiseStatusFrame.origin.y < (self.shippingInfo.frame.maxY + self.underShippingInfoMargin) {
            merchandiseStatusFrame.origin.y = self.shippingInfo.frame.maxY + self.underShippingInfoMargin
            self.merchandiseStatus.frame = merchandiseStatusFrame
        }
    }

    private func realImageSize(from bookInfo: Book?)-> CGSize {
        if let imageSize = bookInfo?.imageSize {
            return imageSize
        } else {
            return self.fixedImageBox.frame.size
        }
    }

    private let shippingInfoStringSize: CGFloat = 11

    private func makeShippingInfoString(from merchandise: Merchandise?)-> NSAttributedString {
        guard let merchandise = merchandise else {
            return NSAttributedString()
        }

        let summary = merchandise.shippingSummary(longFormat: false)
        let infoString = NSMutableAttributedString(string: summary.planeString)

        for range in summary.boldRanges {
            infoString.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: self.shippingInfoStringSize)], range: range)
        }
        for range in summary.regularRanges {
            infoString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: self.shippingInfoStringSize)], range: range)
        }

        return infoString
    }
}
