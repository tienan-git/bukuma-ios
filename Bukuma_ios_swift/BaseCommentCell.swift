//
//  BaseCommentCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftTips

@objc public protocol BaseCommentCellDelegate: BaseTableViewCellDelegate {
    func baseCommentCellStartEditing(_ cell: BaseCommentCell)
    func baseCommentCellEdittingText(_ cell: BaseCommentCell, text: String)
}

/**
 
 textViewを保持しているCell
 Review送るときなど
 
 */


open class BaseCommentCell: BaseTableViewCell, UITextViewDelegate {
    
    var commentTextView: PlaceholderTextView! = PlaceholderTextView()
    var wordCountLabel: UILabel! = UILabel()
    var textViewMaxCharactor: Int {
        return 50
    }
    
    var placeholderText: String? {
        get {
            return commentTextView.placeholder
        }
        set(newV) {
            commentTextView.placeholder = newV
        }
    }
    
    override func releaseSubViews() {
        super.releaseSubViews()
        commentTextView?.delegate = nil
        commentTextView = nil
        wordCountLabel = nil
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        commentTextView.delegate = self
        commentTextView.frame = CGRect(x: 0,
                                       y: 0,
                                       width: kCommonDeviceWidth,
                                       height: 70)
        commentTextView.textContainerInset = UIEdgeInsets(top: 10.0,
                                                          left: 12.0,
                                                          bottom: commentTextView.textContainerInset.bottom,
                                                          right: 10.0)
        
        commentTextView.font = UIFont.systemFont(ofSize: 14)
        commentTextView.backgroundColor = UIColor.white
        commentTextView.returnKeyType = .default
        commentTextView.layer.borderColor = UIColor.black.cgColor
        self.contentView.addSubview(commentTextView)
        
        wordCountLabel.frame = CGRect(x: commentTextView.right - 50, y: commentTextView.bottom - 10.0, width: 50, height: 25)
        wordCountLabel.font = UIFont.systemFont(ofSize: 12)
        wordCountLabel.textColor = kGrayColor
        wordCountLabel.text = "\(textViewMaxCharactor - commentTextView.text.characters.count) / \(textViewMaxCharactor)"
        self.contentView.addSubview(wordCountLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 90
    }
    
    // ================================================================================
    // MARK: - textView delegate
    
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        (self.delegate as? BaseCommentCellDelegate)?.baseCommentCellStartEditing(self)
    }
    
    open func textViewDidChange(_ textView: UITextView) {
        wordCountLabel.text = "\(textViewMaxCharactor - commentTextView.text.characters.count) / \(textViewMaxCharactor)"
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
        
        if afterInputText.length > textViewMaxCharactor {
            return false
        }

        (self.delegate as? BaseCommentCellDelegate)?.baseCommentCellEdittingText(self, text: afterInputText as String)
        
        return true
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
    }
}
