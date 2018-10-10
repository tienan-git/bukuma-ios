//
//  BaseTextPickerCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/29.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//
import Foundation

/**
 
 textFieldを持ったCell
 登録画面などで使われている
 */


 public protocol BaseTextFieldDelegate: BaseTableViewCellDelegate {
    func baseTextFieldDidBeginEditting(_ textField: UITextField)
    func edittingText<T: SignedNumber>(_ string: String?, type:T?)
    func didSelectTextFieldShouldReturn()
    func baseTextFieldReturnKeyTapped(_ textField: UITextField)
}

open class BaseTextFieldCell: BaseTableViewCell ,UITextFieldDelegate{
    var keyboardToolbar: UIToolbar? = UIToolbar()
    var spaceBarItem: UIBarButtonItem? = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    var doneBarItem: UIBarButtonItem? = UIBarButtonItem()
    var titleLabel: UILabel? = UILabel()
    var textField: UITextField? = UITextField()
    var textFieldMaxLength: Int = 200
    var pasteEnable: Bool = true
    var isRightMargin12: Bool = true
    
    var textFieldType: Int? {
        didSet {
            textField!.tag = textFieldType!
        }
    }
    
    open var titleText: String? {
        didSet {
            titleLabel!.text = self.titleText
            if titleLabel!.text != nil {
                titleLabel!.width = titleLabel!.text!.getTextWidthWithFont(titleLabel!.font, viewHeight: titleLabel!.height)
                textField?.width = kCommonDeviceWidth - titleLabel!.width - 12.0 - 10.0 - (isRightMargin12 ? 12.0 : 15.0)
                textField?.right = kCommonDeviceWidth - (isRightMargin12 ? 12.0 : 15.0)
            }
        }
    }
    
    open var textFieldText: String? {
        didSet {
            textField!.text = self.textFieldText
        }
    }
    
    open var placeholderText: String? {
        didSet {
            textField!.placeholder = self.placeholderText
        }
    }
    
    var keyboardToolbarButtonText: String? {
        didSet {
            doneBarItem!.title = keyboardToolbarButtonText
        }
    }
    
    override func releaseSubViews() {
        super.releaseSubViews()
        titleLabel = nil
        textField = nil
        textField?.delegate = nil
        keyboardToolbar = nil
        doneBarItem = nil
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.contentView.backgroundColor = UIColor.white
        
        titleLabel!.frame = CGRect(x: 12, y: 0, width: 150, height: 20)
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel!.textColor = kDarkGray03Color
        titleLabel!.textAlignment = .right
        titleLabel!.text = self.titleText
        if titleLabel!.text != nil {
            titleLabel?.width =  titleLabel!.text!.getTextWidthWithFont(titleLabel!.font, viewHeight: titleLabel!.height)
        }
        
        self.contentView.addSubview(titleLabel!)
        
        textField!.delegate = self
        textField!.viewSize = CGSize(width: kCommonDeviceWidth - titleLabel!.right, height: 20)
        textField!.viewOrigin = CGPoint(x: kCommonDeviceWidth - textField!.width - 10.0, y: (self.contentView.height - textField!.height) / 2)
        textField!.font = UIFont.systemFont(ofSize: 15)
        textField!.textColor = kBlackColor87
        textField!.textAlignment = .left
        textField!.returnKeyType = .done
        textField!.autocapitalizationType = .none
        self.contentView.addSubview(textField!)
        
        keyboardToolbar!.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 38.0)
        keyboardToolbar!.barStyle = .blackTranslucent
        
        if keyboardToolbarButtonText == nil {
            doneBarItem!.title = "完了"
        }
        doneBarItem!.tintColor = UIColor.white
        doneBarItem!.style = .done
        doneBarItem!.target = self
        doneBarItem!.action = #selector(doneButtontapped(_:))
        
        keyboardToolbar!.items = [spaceBarItem!, doneBarItem!]
        
        self.selectionStyle = .none
    }
    
    func doneButtontapped(_ sender: UIBarButtonItem) {
        if textField!.returnKeyType == .next {
            (delegate as? BaseTextFieldDelegate)?.baseTextFieldReturnKeyTapped(textField!)
        }

        textField!.resignFirstResponder()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        titleLabel!.y = (self.height - titleLabel!.height) / 2
        textField!.y = (self.height - textField!.height) / 2
    }
    
    func textFieldDidBeginEditing() {
        if textField!.keyboardType == .numberPad {
            textField!.inputAccessoryView = keyboardToolbar
        }
    }
    
    // ================================================================================
    // MARK: - textFieldDelegate
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            (delegate as? BaseTextFieldDelegate)?.baseTextFieldReturnKeyTapped(textField)
            return true
        }
        textField.resignFirstResponder()
        return true
    }
    
    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        (self.delegate as? BaseTextFieldDelegate)?.didSelectTextFieldShouldReturn()
        return true
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textFieldDidBeginEditing()
        (self.delegate as? BaseTextFieldDelegate)?.baseTextFieldDidBeginEditting(textField)
    }
        
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.characters.count + 1 <= textFieldMaxLength && range.location == textField.text!.characters.count && string == " " {
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
            afterInputText.replaceCharacters(in: range, with: string)
        }
        
        if afterInputText.length > textFieldMaxLength {
            return false
        }
        (self.delegate as? BaseTextFieldDelegate)?.edittingText(afterInputText as String, type: self.textFieldType)
        
        return true
    }
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return pasteEnable
        }
        
        return super.canPerformAction(action, withSender: sender)
        
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
