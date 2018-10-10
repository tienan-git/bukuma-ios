//
//  ExhibitCommentCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/30.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public enum ExhibitCommentCellPlaceholderType: Int {
    case great
    case good
    case normal
    case bad
}

@objc public protocol ExhibitCommentCellDelegate: BaseCommentCellDelegate {
    func exhibitCommentCellEdittingText(_ cell: ExhibitCommentCell, arterInputText: String)
    func exhibitCommentCellEndEditting(_ cell: ExhibitCommentCell)
}

open class ExhibitCommentCell: BaseCommentCell {
    
    var type: ExhibitCommentCellPlaceholderType? {
        didSet {
            _ = type.map { (type) in
                switch type {
                case .great:
                    commentTextView.placeholder = "(例) 購入後カバーを付けて一度読んだのみです。"
                    break
                case .good:
                    commentTextView.placeholder = "(例) 数回読んだだけですので、状態は良いと思います。"
                    break
                case .normal:
                    commentTextView.placeholder = "(例) ところどころ気になる汚れがあり、保管によるヤケや痛みがありますが、中身はキレイです。"
                    break
                case .bad:
                    commentTextView.placeholder = "(例) シミ、日焼け、破れなどありますが、問題なく読めます。"
                    break
                }
            }
        }
    }
    
    override var textViewMaxCharactor: Int {
        return 100
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        selectionStyle = .none
        
        commentTextView.placeholder = "本の詳しい情報を記入すると売れやすくなります。"
        commentTextView.returnKeyType = .done
        
        wordCountLabel.textColor = commentTextView.placeholderTextColor
        wordCountLabel.frame = CGRect(x: commentTextView.right - 60, y: commentTextView.bottom - 10.0, width: 60, height: 25)

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ================================================================================
    // MARK: - textView delegate
    
    open override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
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
        
        if afterInputText.range(of: "\n").length != 0 {
            textView.resignFirstResponder()
            (self.delegate as? ExhibitCommentCellDelegate)?.exhibitCommentCellEndEditting(self)
            return false
        }
        
        if afterInputText.length > textViewMaxCharactor {
            return false
        }
        
        if (self.delegate! as! ExhibitCommentCellDelegate).responds(to: #selector(ExhibitCommentCellDelegate.exhibitCommentCellEdittingText(_:arterInputText:))){
            (self.delegate! as! ExhibitCommentCellDelegate).exhibitCommentCellEdittingText(self, arterInputText: afterInputText as String)
        }
        
        return true
    }
}
