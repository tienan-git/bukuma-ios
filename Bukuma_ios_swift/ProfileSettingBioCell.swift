//
//  ProfileSettingBioCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class ProfileSettingBioCell: BaseCommentCell {
    
    fileprivate let profilebioMaxCharactor: Int = 400
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        self.delegate = delegate
        
        //commentTextView.useMenuController = true
        commentTextView.text = Utility.isEmpty(Me.sharedMe.bio) ? "" : Me.sharedMe.bio
        wordCountLabel.text = "\(profilebioMaxCharactor - commentTextView.text.characters.count) / \(profilebioMaxCharactor)"
        
        wordCountLabel.frame = CGRect(x: commentTextView.right - 70, y: commentTextView.bottom - 10.0, width: 70, height: 25)
        
        placeholderText = "何かコメントがある場合はどうぞ"
    }
    
    override open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
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
        
        if afterInputText.length > profilebioMaxCharactor {
            return false
        }
        
        (self.delegate as? BaseCommentCellDelegate)?.baseCommentCellEdittingText(self, text: afterInputText as String)
        return true
    }
    
    override open func textViewDidChange(_ textView: UITextView) {
        wordCountLabel.text = "\(profilebioMaxCharactor - commentTextView.text.characters.count) / \(profilebioMaxCharactor)"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
       return 90
    }
}
