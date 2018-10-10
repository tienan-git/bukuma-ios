//
//  RegisterPhoneFooterView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

@objc public protocol RegisterPhoneFooterViewDelegate: NSObjectProtocol {
    func registerPhoneFooterViewTermLinkTapped(_ view: RegisterPhoneFooterView)
    func registerPhoneFooterViewPrivacyLinkTapped(_ view: RegisterPhoneFooterView)
    func registerPhoneFooterViewPhoneTapped(_ view: RegisterPhoneFooterView)
    func registerPhoneFooterViewReqestPhoneTapped(_ view: RegisterPhoneFooterView)
}

class RegisterPhoneTextView: UITextView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        UIMenuController.shared.isMenuVisible = false
        return false
    }
}

open class RegisterPhoneFooterView: UIView {
    
    weak var delegate: RegisterPhoneFooterViewDelegate?
    var textView: RegisterPhoneTextView? = RegisterPhoneTextView()
    var termsRange: NSRange?
    var priRange: NSRange?
    var phoneRange: NSRange?
    var reqestCallRange: NSRange?
    var type: RegisterPhoneNumberViewControllerType?
    
    deinit {
        delegate = nil
        textView = nil
        textView?.delegate = nil
        termsRange = nil
        priRange = nil
        phoneRange = nil
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(delegate: RegisterPhoneFooterViewDelegate, type: RegisterPhoneNumberViewControllerType) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonDeviceHeight))
        
        self.backgroundColor = UIColor.white
        
        self.delegate = delegate
        self.type = type
        
        textView!.frame = self.bounds
        
        textView!.isUserInteractionEnabled = true
        textView!.isEditable = false
        textView!.isSelectable = true
        textView!.isScrollEnabled = false
        textView!.showsVerticalScrollIndicator = false
        textView!.x = 10.0
        textView!.y = 2.0
        textView!.width = kCommonDeviceWidth - (10 * 2)
    
        self.addSubview(textView!)
        
        var text: String?
        var attributedString: NSMutableAttributedString?
        
        if self.type! == .input {
            text = "ブクマ！アカウントを作成するには、電話番号での認証が必要です。ブクマ！の利用規約およびプライバシーポリシーに同意の上、”次へ”のボタンをタップしてください。"
            let termLinkText = "利用規約"
            let priLinkText = "プライバシーポリシー"
            
            _ = text!.range(of: termLinkText)
            _ = text!.range(of: priLinkText)
            
            attributedString = NSMutableAttributedString(string: text!)
            
            termsRange = NSMakeRange(36, 4)
            priRange = NSMakeRange(43, 10)
            
            attributedString!.addAttribute(NSForegroundColorAttributeName, value: kBlackColor54, range: NSMakeRange(0, (text! as NSString).length))
            attributedString!.addAttribute(NSForegroundColorAttributeName, value: kMainGreenColor, range: termsRange!)
            attributedString!.addAttribute(NSForegroundColorAttributeName, value: kMainGreenColor, range: priRange!)
            attributedString!.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: termsRange!)
            attributedString!.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: priRange!)

            let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.0
            paragraphStyle.lineSpacing = 1.0
            
            attributedString!.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString!.length))
            
            textView!.attributedText = attributedString

        } else {
           text = "SMSで確認番号が届くまで1分ほど時間がかかる場合がございます。SMSが届かない場合は、お電話番号をお確かめの上、もう一度電話番号を入力して再度お試しいただくか、音声電話認証をお試しください。\n\n電話番号を再入力 >>\n\n音声電話認証を行う >>"
            let phoneLinkText = "電話番号を再入力 >>"
            _ = text!.range(of: phoneLinkText)
            
            let reqestCallText = "音声電話認証を行う >>"
            _ = text!.range(of: reqestCallText)
            
            attributedString = NSMutableAttributedString(string: text!)
            
            phoneRange = NSMakeRange(98, 11)
            reqestCallRange = NSMakeRange(111, 12)
            
            attributedString!.addAttribute(NSForegroundColorAttributeName, value: kBlackColor54, range: NSMakeRange(0, (text! as NSString).length))
            attributedString!.addAttribute(NSForegroundColorAttributeName, value: kMainGreenColor, range: phoneRange!)
            attributedString!.addAttribute(NSForegroundColorAttributeName, value: kMainGreenColor, range: reqestCallRange!)
            
            let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.0
            paragraphStyle.lineSpacing = 1.0
            
            attributedString!.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString!.length))
            
            textView!.attributedText = attributedString
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.textViewTapped(_:)))
        textView!.addGestureRecognizer(tap)
        textView!.height = attributedString!.getTextHeight(kCommonDeviceWidth) + 30.0
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textViewTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: textView)
        let textPosition = textView!.closestPosition(to: location)
        
        let isSelectedPosition = textView!.offset(from: textView!.beginningOfDocument, to: textPosition!)
        switch self.type! {
        case .input:
            if NSLocationInRange(isSelectedPosition,termsRange!) {
                self.delegate?.registerPhoneFooterViewTermLinkTapped(self)
            } else if NSLocationInRange(isSelectedPosition,priRange!) {
                self.delegate?.registerPhoneFooterViewPrivacyLinkTapped(self)
            }
            break
        case .verify:
            if NSLocationInRange(isSelectedPosition,phoneRange!) {
                self.delegate?.registerPhoneFooterViewPhoneTapped(self)
            }
            
            if NSLocationInRange(isSelectedPosition, reqestCallRange!) {
                self.delegate?.registerPhoneFooterViewReqestPhoneTapped(self)
            }
            break
        }
    }
    
}
