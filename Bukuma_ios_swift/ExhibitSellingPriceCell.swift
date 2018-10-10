//
//  ExhibitSellingPriceCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/29.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftTips

@objc public protocol ExhibitSellingPriceCellDelegate: BaseTableViewCellDelegate {
    func exhibitPackSellCellSwitchDidChanged(_ cell: ExhibitPackSellCell)
}

open class ExhibitSellingPriceCell: BaseTextFieldCell {
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.contentView.backgroundColor = UIColor.white
        selectionStyle = .none
        self.titleText = "販売価格(送料込み)"
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel!.textColor = kDarkGray03Color
        titleLabel!.x = 15.0
        titleLabel?.textAlignment = .left
        titleLabel!.height = 15.0
        
        let mutable: NSMutableAttributedString = NSMutableAttributedString()
        let string1 =  NSAttributedString(string:"販売価格",
                                          attributes:[NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15),
                                                      NSForegroundColorAttributeName: kDarkGray03Color])
        let string2 =  NSAttributedString(string:"(送料込み)",
                                          attributes:[NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12),
                                                      NSForegroundColorAttributeName: kDarkGray03Color])
        mutable.append(string1)
        mutable.append(string2)
        titleLabel!.attributedText = mutable
        
        textField!.font = UIFont.boldSystemFont(ofSize: 19)
        textField!.textColor = UIColor.clear
        textField!.keyboardType = .numberPad
        textField?.textAlignment = .right
        
        dummyTextLabel = UILabel()
        dummyTextLabel!.font = UIFont.boldSystemFont(ofSize: 19)
        dummyTextLabel!.textColor = UIColor.black
        dummyTextLabel!.frame = textField!.frame
        dummyTextLabel!.textAlignment = .right
        self.contentView.addSubview(dummyTextLabel!)
        
        self.placeholderText = "¥300"
        self.contentView.addSubview(textField!)
        
        textFieldMaxLength = 8
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open var textFieldText: String? {
        didSet {
            self.textField?.text = self.textFieldText
            self.toYenText = self.textFieldText
        }
    }

    private var toYenText: String? {
        didSet {
            if let text = self.toYenText {
                self.dummyTextLabel?.text = self.yenText(fromPrice: text)
            } else {
                self.dummyTextLabel?.text = ""
            }
        }
    }

    private var dummyTextLabel: UILabel?

    private func yenText(fromPrice: String) -> String {
        return fromPrice.characters.count > 0 ? "¥\(Int(fromPrice)!.toCommaString())" : ""
    }

    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 73.5
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        titleLabel!.y = 20.0
        textField!.right = self.width - 15.0
        dummyTextLabel?.frame = textField!.frame
    }
    
    override open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var afterInput = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        if Int(afterInput) == 0 {
            afterInput = ""
        }
        let yenText = self.yenText(fromPrice: afterInput)
        if yenText.characters.count <= self.textFieldMaxLength {
            self.dummyTextLabel?.text = yenText
            (self.delegate as? BaseTextFieldDelegate)?.edittingText(afterInput, type: self.textFieldType)
            if afterInput == "" {
                textField.text = afterInput
                return false
            }
            return true
        } else {
            return false
        }
    }
}
