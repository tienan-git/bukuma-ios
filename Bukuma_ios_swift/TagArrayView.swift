//
//  TagArrayView.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/29/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

class TagArrayView: UITextView {
    static let horizontalMargin: CGFloat = 14.0
    static let topMargin: CGFloat = 8.0
    static let bottomMargin: CGFloat = 16.0

    private var tags: [Tag]?

    init(with frame: CGRect, and tags: [Tag]?) {
        super.init(frame: frame, textContainer: nil)

        self.tags = tags
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let displayFont: UIFont = UIFont.systemFont(ofSize: 13)
    private let displayTextColor: UIColor = UIColor(red: 255/255, green: 86/255, blue: 117/255, alpha: 1.0)
    private var alignCenter: NSParagraphStyle {
        get {
            let textAlignment = NSMutableParagraphStyle()
            textAlignment.alignment = .center
            return textAlignment
        }
    }

    private func setup() {
        self.isEditable = false
        self.isSelectable = true
        self.dataDetectorTypes = .link
        self.linkTextAttributes = [NSForegroundColorAttributeName: self.displayTextColor]
        self.attributedText = self.tagArrayText()
    }

    private let maxNumberOfTags = Int(5 - 1)
    private let separatorString = "  "

    private func tagArrayText() -> NSAttributedString {
        let tagArrayText = NSMutableAttributedString()

        if let tags = self.tags {
            var range = NSRange(location: 0, length: 0)

            for (index, tag) in tags.enumerated() {
                if index != 0 {
                    tagArrayText.append(NSAttributedString(string: self.separatorString))
                    range.location += self.separatorString.length
                }
                tagArrayText.append(NSAttributedString(string: tag.displayName))

                range.length = tag.displayName.length
                tagArrayText.addAttributes([NSLinkAttributeName: "hash:\(tag.id!)"], range: range) // タグの復元が容易なように ID を渡す
                range.location += range.length

                if index == self.maxNumberOfTags {
                    break
                }
            }
            tagArrayText.addAttributes([NSFontAttributeName: self.displayFont,
                                        NSForegroundColorAttributeName: self.displayTextColor,
                                        NSParagraphStyleAttributeName: self.alignCenter],
                                       range: NSRange(location: 0, length: tagArrayText.length))
        }

        return tagArrayText
    }
}
