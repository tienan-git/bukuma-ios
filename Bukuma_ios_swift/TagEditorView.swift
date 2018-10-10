//
//  TagEditorView.swift
//  Bukuma_ios_swift
//
//  Created by khara on 7/11/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

// MARK: - TagItem

protocol TagItemStyleProtocol {
    var tagItemFillColor: UIColor { get }
    var tagItemFrameCorner: CGFloat { get }
    var tagItemFont: UIFont { get }
    var tagItemTextColor: UIColor { get }
    var tagItemDeleteImage: UIImage? { get }
    var tagItemMargin: CGFloat { get }
}

class TagItem: UIButton {
    static func tagItem(withFrame frame: CGRect) -> TagItem {
        let me = TagItem(type: .custom)
        me.frame = frame
        return me
    }

    static func makeTagString(fromInputString inputString: String) -> String {
        let tagString = inputString.hasPrefix("#") == false ? "#" + inputString : inputString
        return tagString
    }

    private let tagItemMargin = CGFloat(5.0)
    private let tagItemExtraSpace = CGFloat(5.0)

    override open func setTitle(_ title: String?, for state: UIControlState) {
        guard var tagTitle = title else {
            return
        }
        tagTitle = TagItem.makeTagString(fromInputString: tagTitle)
        super.setTitle(tagTitle, for: state)
    }

    var tagString: String? {
        get {
            if let titleString = self.titleLabel?.text {
                if let range = titleString.range(of: "[^#].*", options: .regularExpression) {
                    let tagString = titleString.substring(with: range)
                    return tagString
                }
            }
            return nil
        }
    }

    func adjustPositionAndSize() {
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: self.tagItemMargin, bottom: 0, right: self.tagItemMargin)

        self.titleLabel?.sizeToFit()
        self.sizeToFit()
        var newFrame = self.frame
        newFrame.size.width += self.tagItemExtraSpace
        self.frame = newFrame
        self.positionImageAndText(with: .imageRightTextLeft, space: self.tagItemExtraSpace)
    }
}

// MARK: - TagEditor

protocol TagEditorStyleProtocol {
    var tagEditorFrameSize: CGFloat { get }
    var tagEditorFrameColor: UIColor { get }
    var tagEditorFrameCorner: CGFloat { get }
}

protocol TagEditorProtocol {
    func setup(withTagEditorStyle tagEditorStyle: TagEditorStyleProtocol)
    func makeTagItem(fromTagString tagString: String, withStyle style: TagItemStyleProtocol) -> TagItem
    func addTagItem(_ tagItem: TagItem, withStyle style: TagItemStyleProtocol)
    func tappedDeleteTagItem(_ sender: TagItem)
    func deleteLastTagItem()
}

protocol TagEditorDelegate: class {
    func didEmptyTagItems()
}

class TagEditor: UIScrollView, TagEditorProtocol {
    weak var tagEditorDelegate: TagEditorDelegate?

    @IBOutlet weak var tagsBox: UIView!
    @IBOutlet weak var tagCandidateText: BackSpaceDetectableTextField!

    private var tagItems: [TagItem] = [TagItem]()

    var originalInputWidth: CGFloat = 0

    func setup(withTagEditorStyle tagEditorStyle: TagEditorStyleProtocol) {
        self.layer.borderWidth = tagEditorStyle.tagEditorFrameSize
        self.layer.borderColor = tagEditorStyle.tagEditorFrameColor.cgColor
        self.layer.cornerRadius = tagEditorStyle.tagEditorFrameCorner

        self.originalInputWidth = self.tagCandidateText.frame.size.width
    }

    func makeTagItem(fromTagString tagString: String, withStyle style: TagItemStyleProtocol) -> TagItem {
        let tagItem = TagItem.tagItem(withFrame: self.tagsBox.bounds)

        tagItem.backgroundColor = style.tagItemFillColor
        tagItem.layer.cornerRadius = style.tagItemFrameCorner
        tagItem.titleLabel?.font = style.tagItemFont
        tagItem.setTitleColor(style.tagItemTextColor, for: .normal)

        tagItem.setTitle(tagString, for: .normal)
        tagItem.setImage(style.tagItemDeleteImage, for: .normal)

        tagItem.adjustPositionAndSize()

        return tagItem
    }

    private let tagEditorScrollMargin = CGFloat(5.0)

    func addTagItem(_ tagItem: TagItem, withStyle style: TagItemStyleProtocol) {
        var position = tagItem.frame.origin
        position.x = self.tagsBox.frame.maxX + style.tagItemMargin
        tagItem.frame.origin = position

        let addWidth = tagItem.frame.size.width + style.tagItemMargin
        var newSize = self.tagsBox.frame.size
        newSize.width += addWidth
        self.tagsBox.frame.size = newSize

        self.tagsBox.addSubview(tagItem)
        tagItem.tag = self.tagItems.count
        self.tagItems.append(tagItem)

        self.tagCandidateText.text = ""

        var newFrame = self.tagCandidateText.frame
        newFrame.origin.x += addWidth
        newFrame.size.width -= addWidth
        if newFrame.size.width < self.originalInputWidth / 2 {
            newFrame.size.width = self.originalInputWidth / 2
            self.contentSize.width = newFrame.maxX + self.tagEditorScrollMargin
            self.contentOffset.x = self.contentSize.width - self.frame.size.width
        }
        self.tagCandidateText.frame = newFrame

        tagItem.addTarget(self, action: #selector(self.tappedDeleteTagItem(_:)), for: .touchUpInside)
    }

    func tappedDeleteTagItem(_ sender: TagItem) {
        sender.isUserInteractionEnabled = false

        var deleteWidth = CGFloat(0)
        let itemIndex = sender.tag
        if itemIndex > 0 {
            let previousItem = self.tagItems[itemIndex - 1]
            deleteWidth = sender.frame.maxX - previousItem.frame.maxX
        } else {
            deleteWidth = sender.frame.maxX
        }

        sender.removeFromSuperview()
        self.tagItems.remove(at: itemIndex)

        for nextIndex in itemIndex ..< self.tagItems.count {
            var newPosition = self.tagItems[nextIndex].frame.origin
            newPosition.x -= deleteWidth
            self.tagItems[nextIndex].frame.origin = newPosition

            self.tagItems[nextIndex].tag -= 1
        }

        var newSize = self.tagsBox.frame.size
        newSize.width -= deleteWidth
        self.tagsBox.frame.size = newSize

        var newFrame = self.tagCandidateText.frame
        newFrame.origin.x -= deleteWidth
        newFrame.size.width += deleteWidth
        if newFrame.size.width > self.originalInputWidth {
            newFrame.size.width = self.originalInputWidth
            self.contentSize.width = newFrame.maxX
            self.contentOffset.x = 0
        }
        self.tagCandidateText.frame = newFrame

        if self.tagItems.count == 0 {
            self.tagEditorDelegate?.didEmptyTagItems()
        }
    }

    func deleteLastTagItem() {
        if self.tagItems.count > 0 {
            self.tappedDeleteTagItem(self.tagItems.last!)
        }
    }

    var tagStrings: [String]? {
        get {
            let tagStrings = self.tagItems.flatMap { (tagItem) in
                return tagItem.tagString
            }
            return tagStrings
        }
    }
}

// MARK: - TagEditorView

protocol TagEditorViewDelegate: class {
    func tappedAddTagsButton(tagStringsToAdd tagStrings: [String], _ completion: @escaping () -> Void)
}

class TagEditorView: UIView, NibProtocol, TagEditorStyleProtocol {
    typealias NibT = TagEditorView

    weak var delegate: TagEditorViewDelegate?

    @IBOutlet weak var tagEditor: TagEditor!
    @IBOutlet weak var addTagButton: UIButton!

    internal var tagEditorFrameSize: CGFloat { get { return CGFloat(0.5) } }
    internal var tagEditorFrameColor: UIColor { get { return UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0) } }
    internal var tagEditorFrameCorner: CGFloat { get { return CGFloat(3.0) } }

    private let buttonTitle = String("追加")

    static func tagEditorView() -> TagEditorView? {
        let me = TagEditorView.fromNib()
        return me
    }

    override open func awakeFromNib() {
        super.awakeFromNib()

        self.tagEditor.setup(withTagEditorStyle: self)
        self.tagEditor.tagEditorDelegate = self
        self.tagEditor.tagCandidateText.delegate = self as UITextFieldDelegate

        self.addTagButton.setTitle(self.buttonTitle, for: .normal)
        self.addTagButton.isEnabled = false
    }

    override open func becomeFirstResponder() -> Bool {
        return self.tagEditor.tagCandidateText.becomeFirstResponder()
    }

    @IBAction func tappedAddTagButton(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false

        var tagStrings: [String] = []
        if let tagArray = self.tagEditor.tagStrings {
            tagArray.forEach{ tagStrings.append($0) }
        }
        if let input = self.tagEditor.tagCandidateText.text {
            tagStrings.append(input)
        }
        self.delegate?.tappedAddTagsButton(tagStringsToAdd: tagStrings) { () in
            sender.isUserInteractionEnabled = true
        }
    }

    fileprivate let maxTextLength = Int(20)
}

// MARK: - TagEditorView: UITextFieldDelegate

extension TagEditorView: BackSpaceDetectableTextFieldDelegate, TagItemStyleProtocol {
    var tagItemFillColor: UIColor { get { return UIColor(red: 183/255, green: 189/255, blue: 197/255, alpha: 1.0) } }
    var tagItemFrameCorner: CGFloat { get { return CGFloat(4.0) } }
    var tagItemFont: UIFont { get { return UIFont.boldSystemFont(ofSize: 12.0) } }
    var tagItemTextColor: UIColor { get { return UIColor.white } }
    var tagItemDeleteImage: UIImage? { get { return UIImage(named: "ic_tag_delete") } }
    var tagItemMargin: CGFloat { get { return CGFloat(5.0) } }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // スペースキーでタグ生成
        if string == " " {
            if let tagString = self.tagEditor.tagCandidateText.text {
                let tagItem = self.tagEditor.makeTagItem(fromTagString: tagString, withStyle: self)
                self.tagEditor.addTagItem(tagItem, withStyle: self)
                self.addTagButton.isEnabled = true
                return false
            }
        }

        // スペースを含む文字列だったら無視
        if let _ = string.range(of: " ") {
            return false
        }

        // maxTextLength より大きくなってしまうようだったら入力を無視
        let newLength = (textField.text?.length)! - range.length + string.length
        if newLength > self.maxTextLength {
            return false
        }

        if newLength == 0 && self.tagEditor.tagStrings?.count == 0 {
            self.addTagButton.isEnabled = false
        } else {
            self.addTagButton.isEnabled = true
        }

        return true
    }

    func tappedBackSpace(_ textField: UITextField) {
        if let selectedRange = textField.selectedTextRange {
            let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            if cursorPosition == 0 {
                self.tagEditor.deleteLastTagItem()
            }
        }
    }
}

// MARK: - TagEditorView: TagEditorDelegate

extension TagEditorView: TagEditorDelegate {
    func didEmptyTagItems() {
        if self.tagEditor.tagCandidateText.text?.length == 0 {
            self.addTagButton.isEnabled = false
        }
    }
}

// MARK: - BackSpaceDetectableTextField

protocol BackSpaceDetectableTextFieldDelegate: UITextFieldDelegate {
    func tappedBackSpace(_ textField: UITextField)
}

class BackSpaceDetectableTextField: UITextField {
    public override func deleteBackward() {
        super.deleteBackward()

        (self.delegate as? BackSpaceDetectableTextFieldDelegate)?.tappedBackSpace(self)
    }
}
