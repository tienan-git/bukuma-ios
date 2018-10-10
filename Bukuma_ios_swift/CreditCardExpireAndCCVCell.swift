//
//  CreditCardExpireAndCCVCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

public protocol CreditCardExpireAndCCVCellDelegate: BaseTableViewDelegate {
    func creditCardExpireAndCCVCellPickerValueChanged(_ text: String, year: String, month: String)
    func creditCardExpireAndCCVCellTextFieldDidChange(_ text: String)
    func creditCardExpireAndCCVCellTextFieldShouldReturn(_ cell: CreditCardExpireAndCCVCell)
    func creditCardExpireAndCCVCellTextFieldDidEndEditting(_ cell: CreditCardExpireAndCCVCell)
    func creditCardExpireAndCCVCellCCVTutorialButtonTapped(_ cell: CreditCardExpireAndCCVCell)
}

open class CreditCardExpireAndCCVCell: BaseTextFieldCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var ccvTextField: UITextField?
    fileprivate var pickerView: UIPickerView?
    fileprivate let expireFieldWidth: CGFloat = 170.0
    fileprivate var downArrawImageView: UIImageView?
    fileprivate var bottomLineView2: UIView?
    fileprivate var ccvTutorialButton: UIButton?
    fileprivate var yearComponents: [String] = ["2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028"]
    fileprivate var monthComponents: [String] = ["01", "02","03","04","05","06","07","08","09","10","11","12"]
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        placeholderText = "YYYY / MM"
        
        textField?.x = 30.0
        textField?.viewSize = CGSize(width: expireFieldWidth, height: 20)
        textField?.tag = 2
        textField?.textAlignment = .left
        textField?.tintColor = UIColor.clear
        
        pickerView = UIPickerView()
        pickerView?.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonDeviceWidth / 2)
        pickerView?.y = kCommonDeviceHeight - pickerView!.height
        pickerView?.delegate = self
        pickerView?.dataSource = self
        
        keyboardToolbar = UIToolbar()
        keyboardToolbar!.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 38.0)
        keyboardToolbar!.barStyle = .blackTranslucent
        
        doneBarItem = UIBarButtonItem()
        doneBarItem!.title = "次へ"
        doneBarItem!.tintColor = UIColor.white
        doneBarItem!.style = .done
        doneBarItem!.target = self
        doneBarItem!.action = #selector(doneButtontapped(_:))
        
        keyboardToolbar!.items = [spaceBarItem!, doneBarItem!]
        textField?.inputAccessoryView = keyboardToolbar
        textField?.inputView = pickerView

        downArrawImageView = UIImageView()
        let downImage: UIImage = UIImage(named: "ic_arrow_down")!
        downArrawImageView?.viewSize = downImage.size
        downArrawImageView?.image = downImage
        self.contentView.addSubview(downArrawImageView!)
        
        ccvTextField = UITextField()
        ccvTextField?.delegate = self
        ccvTextField?.viewSize = CGSize(width: kCommonDeviceWidth - 30 * 2 - 20.0 - expireFieldWidth, height: 20)
        ccvTextField?.x = textField!.right + 20.0
        ccvTextField?.font = UIFont.systemFont(ofSize: 15)
        ccvTextField?.textColor = kBlackColor87
        ccvTextField?.textAlignment = .center
        ccvTextField?.tag = 3
        ccvTextField?.returnKeyType = .done
        ccvTextField?.autocapitalizationType = .none
        ccvTextField?.keyboardType = .numberPad
        ccvTextField?.placeholder = "CCV"
        self.contentView.addSubview(ccvTextField!)
        
        bottomLineView2 = UIView()
        bottomLineView2?.backgroundColor = kBorderColor
        bottomLineView2?.viewSize = CGSize(width: ccvTextField!.width, height: 0.5)
        bottomLineView2?.viewOrigin = CGPoint(x: ccvTextField!.x, y: 0)
        self.contentView.addSubview(bottomLineView2!)

        let tutorialImage: UIImage = UIImage(named: "ic_round_question")!
        
        ccvTutorialButton = UIButton()
        ccvTutorialButton?.viewSize = tutorialImage.size
        ccvTutorialButton?.setImage(tutorialImage, for: .normal)
        ccvTutorialButton?.addTarget(self, action: #selector(self.ccvTutorialButtonTapped(_:)), for: .touchUpInside)
        self.contentView.addSubview(ccvTutorialButton!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        textField?.bottom = self.height - 10.0
        ccvTextField?.y = textField!.y
        downArrawImageView?.bottom = self.height
        bottomLineView?.frame = CGRect(x: 30.0, y: self.height - 0.5, width: expireFieldWidth, height: 0.5)
        bottomLineView2?.viewOrigin = CGPoint(x: ccvTextField!.x, y: self.height - 0.5)
        ccvTutorialButton?.bottom = self.height
        ccvTutorialButton?.right = bottomLineView2!.right
        downArrawImageView?.right = bottomLineView!.right
    }
    
    func ccvTutorialButtonTapped(_ sender: UIButton) {
        (self.delegate as? CreditCardExpireAndCCVCellDelegate)?.creditCardExpireAndCCVCellCCVTutorialButtonTapped(self)
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker) {
        let text: String = "\(sender.date.month) / \(sender.date.day) / \(sender.date.year)"
        textField?.text = text
    }
    
    override func doneButtontapped(_ sender: UIBarButtonItem) {
        (delegate as? CreditCardExpireAndCCVCellDelegate)?.creditCardExpireAndCCVCellTextFieldShouldReturn(self)
    }
    
    // ================================================================================
    // MARK: - picker delegate, dataSource
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return yearComponents.count
        }
        return monthComponents.count
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return yearComponents[row]
        }
        return monthComponents[row]
    }
    
    static var year: String = ""
    static var month: String = ""
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            CreditCardExpireAndCCVCell.year = yearComponents[row]
        } else {
            CreditCardExpireAndCCVCell.month = monthComponents[row]
        }
        self.textFieldText = " \(CreditCardExpireAndCCVCell.year) / \(CreditCardExpireAndCCVCell.month)"
        (self.delegate as? CreditCardExpireAndCCVCellDelegate)?.creditCardExpireAndCCVCellPickerValueChanged(self.textFieldText!, year: CreditCardExpireAndCCVCell.year, month: CreditCardExpireAndCCVCell.month)
    }
    
    // ================================================================================
    // MARK: - textFieldDelegate
    
    open override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        (delegate as? CreditCardExpireAndCCVCellDelegate)?.creditCardExpireAndCCVCellTextFieldShouldReturn(self)
        return true
    }
    
    open override func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        (self.delegate as? CreditCardExpireAndCCVCellDelegate)?.creditCardExpireAndCCVCellTextFieldDidEndEditting(self)
        return true
    }
    
    open override func textFieldDidEndEditing(_ textField: UITextField) {}
    
    open override func textFieldDidBeginEditing(_ textField: UITextField) {}
    
    open override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag != 3 {
            return false
        }
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
        
        if afterInputText.length > 3 {
            return false
        }
        (self.delegate as? CreditCardExpireAndCCVCellDelegate)?.creditCardExpireAndCCVCellTextFieldDidChange(afterInputText as String)
        
        return true
    }
}
