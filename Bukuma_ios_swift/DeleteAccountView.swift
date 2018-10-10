//
//  DeleteAccountView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/12/08.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftTips

protocol DeleteAccountViewDelegate {
    func deleteAccountView(didTapDeleteButton view: DeleteAccountView, reasonId inReasonId: Int, reasonText inReasonText: String, userComment inUserComment: String)
    func deleteAccountView(didResize view: DeleteAccountView)
}

class DeleteAccountView: UIView, DeleteAccountReasonSelectorDelegate {
    
    var delegate: DeleteAccountViewDelegate?

    fileprivate weak var reasonSelector: DeleteAccountReasonSelector!
    fileprivate var commentTextView: PlaceholderTextView = PlaceholderTextView()
    fileprivate var wordCountLabel: UILabel = UILabel()
    fileprivate var deleteAccountButton: UIButton!

    fileprivate let textViewMaxCharactor: Int = 250
    
    required init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonDeviceHeight))
        
        self.defaultSetUp()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func defaultSetUp() {
        self.backgroundColor = UIColor.white
        self.isUserInteractionEnabled = true
        
        let titleLabel: UILabel = UILabel()
        titleLabel.frame = CGRect(x: 0,
                                  y: NavigationHeightCalculator.navigationHeight() + 24.0,
                                  width: kCommonDeviceWidth,
                                  height: 20.0)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = kTitleBoldBlackColor
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = "ブクマ！を退会する"
        self.addSubview(titleLabel)
        
        let detailLabel: UILabel = UILabel()
        detailLabel.frame = CGRect(x: 0,
                                   y: titleLabel.bottom + 10.0,
                                   width: kCommonDeviceWidth,
                                   height: 15.0)
        detailLabel.font = UIFont.systemFont(ofSize: 14)
        detailLabel.textColor = kdeltailGrayColor
        detailLabel.textAlignment = NSTextAlignment.center
        detailLabel.text = "ブクマを退会する理由をご選択してください。"
        self.addSubview(detailLabel)
        
        let kumaImage = UIImage(named: "img_cry_bukuma")!
        let kumaImageView: UIImageView = UIImageView()
        kumaImageView.image = kumaImage
        kumaImageView.frame = CGRect(x: (kCommonDeviceWidth - kumaImage.size.width) / 2,
                                     y: detailLabel.bottom + 26.0,
                                     width: kumaImage.size.width,
                                     height: kumaImage.size.height)
        self.addSubview(kumaImageView)

        let selectorFrame = CGRect(x: 30.0, y: kumaImageView.bottom + 29.0, width: self.frame.size.width - 60.0, height: 300.0)
        let reasonSelector = DeleteAccountReasonSelector.init(frame: selectorFrame)
        reasonSelector.delegate = self
        self.addSubview(reasonSelector)
        self.reasonSelector = reasonSelector

        commentTextView.frame = CGRect(x: 30,
                                       y: reasonSelector.frame.maxY + 15.0,
                                       width: kCommonDeviceWidth - 30 * 2,
                                       height: 100)
        commentTextView.textContainerInset = UIEdgeInsets(top: 7.0,
                                                          left: 7.0,
                                                          bottom: commentTextView.textContainerInset.bottom,
                                                          right: 7.0)
        commentTextView.contentInset  = UIEdgeInsets(top: commentTextView.textContainerInset.top,
                                                     left: commentTextView.textContainerInset.left,
                                                     bottom: 25.0,
                                                     right: commentTextView.textContainerInset.right)
        
        commentTextView.font = UIFont.systemFont(ofSize: 13)
        commentTextView.backgroundColor = UIColor.white
        commentTextView.returnKeyType = .default
        commentTextView.layer.borderColor = UIColor.colorWithHex(0x959595).cgColor
        commentTextView.layer.borderWidth = 0.5
        commentTextView.delegate = self
        commentTextView.placeholder = "その他に理由がありましたらご記入ください。"
        commentTextView.placeholderTextColor = UIColor.colorWithHex(0xC8C8C8)
        self.addSubview(commentTextView)
        
        wordCountLabel.frame = CGRect(x: commentTextView.right - 60 - 10.0, y: commentTextView.bottom - 10.0 - 22.0, width: 60, height: 25)
        wordCountLabel.font = UIFont.systemFont(ofSize: 12)
        wordCountLabel.textColor = kdeltailGrayColor
        wordCountLabel.text = "\(textViewMaxCharactor - commentTextView.text.characters.count) / \(textViewMaxCharactor)"
        self.addSubview(wordCountLabel)
        
        let greenImage: UIImage = UIImage(named: "img_stretch_btn")!
        let deleteAccountButton: UIButton = UIButton()
        deleteAccountButton.frame = CGRect(x: 29,
                                           y: commentTextView.bottom + 15.0,
                                           width: kCommonDeviceWidth - 29 * 2,
                                           height: 50.0)
        deleteAccountButton.clipsToBounds = true
        deleteAccountButton.layer.cornerRadius = 6.0
        deleteAccountButton.layer.borderColor = UIColor.clear.cgColor
        deleteAccountButton.setBackgroundColor(kMainGreenColor, state: .normal)
        deleteAccountButton.imageView?.isUserInteractionEnabled = true
        deleteAccountButton.setBackgroundImage(greenImage.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        deleteAccountButton.setTitle("退会する", for: .normal)
        deleteAccountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        deleteAccountButton.setTitleColor(UIColor.white, for: .normal)
        deleteAccountButton.addTarget(self, action: #selector(self.deleteButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        deleteAccountButton.isEnabled = false
        self.addSubview(deleteAccountButton)
        self.deleteAccountButton = deleteAccountButton
        
        self.height = deleteAccountButton.bottom
    }

    func deleteButtonTapped(sender: UIButton) {
        delegate?.deleteAccountView(didTapDeleteButton: self,
                                    reasonId: self.reasonSelector.resultReason?.itemValue ?? 0,
                                    reasonText: self.reasonSelector.resultReason?.itemTitle ?? "",
                                    userComment: self.commentTextView.text)
    }

    // MARK: - DeleteAccountReasonSelectorDelegate

    private var heightGap: CGFloat = 0

    func selectorDidResize(_ newSize: CGSize, _ oldSize: CGSize, with reasonSelector: DeleteAccountReasonSelector) {
        self.heightGap = newSize.height - oldSize.height
        self.layoutIfNeeded()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if self.heightGap != 0 {
            let adjustingViews: [UIView] = [self.commentTextView, self.wordCountLabel, self.deleteAccountButton]
            for adjustingView in adjustingViews {
                var position = adjustingView.frame.origin
                position.y += self.heightGap
                adjustingView.frame.origin = position
            }

            var viewSize = self.frame.size
            viewSize.height = self.deleteAccountButton.frame.maxY
            self.frame.size = viewSize

            self.delegate?.deleteAccountView(didResize: self)

            self.heightGap = 0
        }
    }

    func selectorDidChangeReason(_ selectedReason: DeleteAccountReasonProtocol?, with reasonSelector: DeleteAccountReasonSelector) {
        self.deleteAccountButton.isEnabled = self.isEnableDeleteButton()
    }

    fileprivate func isEnableDeleteButton() -> Bool {
        return self.reasonSelector.resultReason?.itemValue != 0
    }
}

extension DeleteAccountView: UITextViewDelegate {
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }

    open func textViewDidChange(_ textView: UITextView) {
        let commentCount: Int = commentTextView.text.characters.count
        wordCountLabel.text = "\(textViewMaxCharactor - commentCount) / \(textViewMaxCharactor)"
    }

    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text!.characters.count + 1 <= textViewMaxCharactor && range.location == textView.text!.characters.count && text == " " {
            textView.text! = textView.text! + "\u{00a0}"
            return false
        }
        
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

        return afterInputText.length <= textViewMaxCharactor
    }
}
