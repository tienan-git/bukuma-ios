//
//  ShippingProgressReviewCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/01.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftTips

protocol TriangleShapeProtocol {
    func makeTriangleShape()
    func triangleApexes(in rect: CGRect)-> [CGPoint]
}

extension TriangleShapeProtocol where Self: UIView {
    func makeTriangleShape() {
        let path = UIBezierPath()

        let triangleApexes = self.triangleApexes(in: self.bounds)
        path.move(to: triangleApexes[0])
        path.addLine(to: triangleApexes[1])
        path.addLine(to: triangleApexes[2])
        path.addLine(to: triangleApexes[0])

        path.close()

        self.backgroundColor?.setFill()
        path.fill()

        let shape = CAShapeLayer()
        shape.path = path.cgPath
        self.layer.mask = shape
    }

    func triangleApexes(in rect: CGRect)-> [CGPoint] {
        let apexes = [CGPoint(x: rect.midX, y: rect.minY),
                      CGPoint(x: rect.minX, y: rect.maxY),
                      CGPoint(x: rect.maxX, y: rect.maxY)]
        return apexes
    }
}

class TriangleView: UIView, TriangleShapeProtocol {
    
}


protocol ShippingProgressReviewCellDelegate: BaseTableViewCellDelegate {
    func shippingProgressReviewCellDidBeginEditing(_ textView: UITextView)
    func shippingProgressReviewCellTextViewDidChange(_ text: String)
    func shippingProgressReviewCellReviewButtonTapped(_ reviewTag: Int, completion: ()-> Void)
    func shippingProgressReviewCellSendButtonTapped(_ cell: ShippingProgressReviewCell, completion: @escaping ()-> Void)
    func shippingProgressReviewCellInquireToSupportButtonTapped(_ completion: @escaping ()-> Void)
}

class ShippingProgressReviewCell: BaseTableViewCell, UITextViewDelegate, NibProtocol {
    typealias NibT = ShippingProgressReviewCell

    @IBOutlet private weak var reviewButtonGroupView: UIView!
    @IBOutlet private weak var goodReviewButton: UIButton!
    @IBOutlet private weak var averageReviewButton: UIButton!
    @IBOutlet private weak var badReviewButton: UIButton!

    @IBOutlet private weak var inquireToSupprtGroupView: UIView!
    @IBOutlet private weak var triangleView: TriangleView!
    @IBOutlet private weak var inquireButtonBackgroundView: UIView!
    @IBOutlet private weak var inquireToSupportMessage: UILabel!
    @IBOutlet private weak var inquireToSupportButton: UIButton!
    @IBOutlet private weak var inquireToSupprtGroupViewTopConstraint: NSLayoutConstraint!

    @IBOutlet private weak var reviewCommentGroupView: UIView!
    @IBOutlet weak var reviewCommentView: PlaceholderTextView!
    @IBOutlet private weak var wordCountLabel: UILabel!
    @IBOutlet private weak var sendReviewButton: UIButton!

    @IBAction private func tappedReviewButton(_ sender: UIButton) {
        for reviewButton in self.reviewButtons {
            reviewButton.isSelected = false
        }
        sender.isSelected = true

        self.didSelectGoodReview(sender.tag == 0)
        self.setDefaultComment(sender.tag)

        if let delegate = self.delegate as? ShippingProgressReviewCellDelegate {
            sender.isUserInteractionEnabled = false
            delegate.shippingProgressReviewCellReviewButtonTapped(ReviewType(rawValue: 0)!.typeFromTag(sender.tag)) {
                DispatchQueue.main.async {
                    sender.isUserInteractionEnabled = true
                }
            }
        }
    }

    @IBAction private func tappedInquireToSupportButton(_ sender: UIButton) {
        if let delegate = self.delegate as? ShippingProgressReviewCellDelegate {
            sender.isUserInteractionEnabled = false
            delegate.shippingProgressReviewCellInquireToSupportButtonTapped() {
                DispatchQueue.main.async {
                    sender.isUserInteractionEnabled = true
                }
            }
        }
    }

    @IBAction private func tappedSendReviewButton(_ sender: UIButton) {
        if let delegate = self.delegate as? ShippingProgressReviewCellDelegate {
            sender.isUserInteractionEnabled = false
            delegate.shippingProgressReviewCellSendButtonTapped(self) { () in
                DispatchQueue.main.async {
                    sender.isUserInteractionEnabled = true
                }
            }
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private func setup() {
        self.setupReviewButtonGroupView()
        self.setupInquireToSupprtGroupView()
        self.setupReviewCommentGroupView()
    }

    private var reviewButtons: [UIButton]!

    private func setupReviewButtonGroupView() {
        self.reviewButtons = [self.goodReviewButton, self.averageReviewButton, self.badReviewButton]
        self.tappedReviewButton(self.goodReviewButton)
    }

    private let suggestionMessageText = "何かお困りのことがありましたか？\nお気軽にご相談、お問い合わせください。"
    private let inquireToSupportText = "事務局へ問い合わせる"

    private func setupInquireToSupprtGroupView() {
        self.inquireToSupportMessage.text = self.suggestionMessageText

        let buttonFrameColor = UIColor(red: 239/255, green: 118/255, blue: 122/255, alpha: 1)
        self.inquireToSupportButton.addFrame(frameThickness: 1, frameColor: buttonFrameColor, frameCorner: 4)
        self.inquireToSupportButton.setTitle(self.inquireToSupportText, for: .normal)

        self.triangleView.makeTriangleShape()
        self.inquireButtonBackgroundView.layer.cornerRadius = 4
    }

    private let reviewCommentViewMaxCharactor: Int = 200
    private let sendReviewButtonText = "送信"

    private func setupReviewCommentGroupView() {
        let frameColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        self.reviewCommentView.addFrame(frameThickness: 0.5, frameColor: frameColor, frameCorner: 4)
        self.reviewCommentView.placeholderTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.26)
        self.reviewCommentView.textContainerInset = UIEdgeInsets(top: 10.0,
                                                                 left: 10.0,
                                                                 bottom: 25.0,
                                                                 right: 5.0)

        self.wordCountLabel.text = "\(self.reviewCommentViewMaxCharactor - self.reviewCommentView.text.characters.count)/\(self.reviewCommentViewMaxCharactor)"

        self.sendReviewButton.setTitle(self.sendReviewButtonText, for: .normal)
    }

    private static let inquireToSupprtGroupViewHeight: CGFloat = 144
    private static let wholeCellHeight: CGFloat = 429
    private static var cellHeight: CGFloat = ShippingProgressReviewCell.wholeCellHeight - ShippingProgressReviewCell.inquireToSupprtGroupViewHeight

    private func didSelectGoodReview(_ isGoodReview: Bool) {
        self.inquireToSupprtGroupViewTopConstraint.constant = isGoodReview ? -(self.inquireToSupprtGroupView.frame.size.height) : 0

        var frame = self.inquireToSupprtGroupView.frame
        frame.origin.y = isGoodReview ? self.reviewButtonGroupView.frame.maxY - frame.size.height : self.reviewButtonGroupView.frame.maxY
        self.inquireToSupprtGroupView.frame = frame

        ShippingProgressReviewCell.cellHeight = isGoodReview ? ShippingProgressReviewCell.wholeCellHeight - ShippingProgressReviewCell.inquireToSupprtGroupViewHeight : ShippingProgressReviewCell.wholeCellHeight
    }

    private func setDefaultComment(_ tag: Int) {
        var shouldChangeDefaultValue: Bool = false
        if !Utility.isEmpty(self.reviewCommentView.text) {
            if self.reviewCommentView.placeholder == "【とても良い取引でした】ありがとうございました。とても良い取引ができました。またご縁がありましたら宜しくお願いします。" {
                shouldChangeDefaultValue = true
            } else if self.reviewCommentView.placeholder == "【無事に取引を終えました】ありがとうございました。" {
                shouldChangeDefaultValue = true
            } else if self.reviewCommentView.placeholder == "【少し不安な取引でした】少し不安な取引でした。トラブルや問題がありました。" {
                shouldChangeDefaultValue = true
            } else {
                shouldChangeDefaultValue = false
            }
        } else {
            shouldChangeDefaultValue = true
        }
        if shouldChangeDefaultValue == false {
            return
        }

        switch tag {
        case 0:
            self.reviewCommentView.placeholder = "【とても良い取引でした】ありがとうございました。とても良い取引ができました。またご縁がありましたら宜しくお願いします。"
            break
        case 1:
            self.reviewCommentView.placeholder = "【無事に取引を終えました】ありがとうございました。"
            break
        case 2:
            self.reviewCommentView.placeholder = "【少し不安な取引でした】少し不安な取引でした。トラブルや問題がありました。"
            break
        default:
            break
        }
    }

    func dismissKeyBoard() {
        self.reviewCommentView.resignFirstResponder()
    }

    override open class func cellHeightForObject(_ object: AnyObject?)-> CGFloat {
        return self.cellHeight
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }

    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }

    override open var cellModelObject: AnyObject? {
        didSet {
            guard let transaction = self.cellModelObject as? Transaction else { return }
            if transaction.isBuyer()! {
                self.sendReviewButton.setTitle("レビューを書いて受取連絡する", for: .normal)
            } else {
                self.sendReviewButton.setTitle("レビューを書いて取引を完了する", for: .normal)
            }
        }
    }

    // ================================================================================
    // MARK: - textView delegate

    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }

    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let delegate = self.delegate as? ShippingProgressReviewCellDelegate {
            delegate.shippingProgressReviewCellDidBeginEditing(textView)
        }
        return true
    }

    open func textViewDidBeginEditing(_ textView: UITextView) {
        if let delegate = self.delegate as? ShippingProgressReviewCellDelegate {
            delegate.shippingProgressReviewCellDidBeginEditing(textView)
        }
    }

    open func textViewDidChange(_ textView: UITextView) {
        self.wordCountLabel.text = "\(self.reviewCommentViewMaxCharactor - textView.text.characters.count)/\(self.reviewCommentViewMaxCharactor)"
    }

    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var afterInputText: NSMutableString = textView.text!.mutableCopy() as! NSMutableString
        if text == "" {//back space の処理
            var string: String = ""
            if afterInputText.length == 0 {
                string = ""
            } else {
                string = afterInputText.substring(to: afterInputText.length - 1)
            }
            let mutableString: NSMutableString = NSMutableString(string: string)
            afterInputText = mutableString
        } else {
            afterInputText.replaceCharacters(in: range, with: text)
        }

        if let delegate = self.delegate as? ShippingProgressReviewCellDelegate {
            delegate.shippingProgressReviewCellTextViewDidChange(afterInputText as String)
        }

        return true
    }
}
