//
//  TransfarTextFieldCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class TransfarTextFieldCell: BaseTextFieldCell {
    
    var dummyTextLabel: UILabel?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)

        textField?.textColor = UIColor.clear
        textFieldMaxLength = 6
        
        dummyTextLabel = UILabel()
        dummyTextLabel!.font = textField!.font
        dummyTextLabel!.textColor = kBlackColor87
        dummyTextLabel!.frame = textField!.frame
        dummyTextLabel!.textAlignment = .right
        self.contentView.addSubview(dummyTextLabel!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override open func layoutSubviews() {
        super.layoutSubviews()
        dummyTextLabel?.frame = textField!.frame
    }
    
    override open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.characters.count + 1 <= textFieldMaxLength && range.location == textField.text!.characters.count && string == "" {
            textField.text! = textField.text! + "\u{00a0}"
            return false
        }
        
        var afterInputText: NSMutableString = textField.text!.mutableCopy() as! NSMutableString
        
        if string == "" {//back space の処理
            var string: String = ""
            if afterInputText.length == 0 {
                string = ""
            } else {
                string = afterInputText.substring(to: afterInputText.length - 1)
            }

            let mutableString: NSMutableString = NSMutableString(string: string)
            afterInputText = mutableString
        } else {
            afterInputText.replaceCharacters(in: range, with: string.int().thousandsSeparator())
        }
        
        var thousandsSeparatorString: String = afterInputText.intValue().thousandsSeparator()
        thousandsSeparatorString.insert("¥", at: thousandsSeparatorString.startIndex)
        
        if thousandsSeparatorString == "¥0" {
            thousandsSeparatorString = ""
        }
        
        dummyTextLabel?.text = thousandsSeparatorString
        (self.delegate as? BaseTextFieldDelegate)?.edittingText(afterInputText as String, type: self.textFieldType)
        
        return thousandsSeparatorString.length <= textFieldMaxLength
    }

}
