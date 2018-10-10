//
//  EmailLoginFooterView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/06.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public protocol EmailLoginFooterViewDelegate {
    func emailLoginFooterViewForgetPassTapped(_ view: EmailLoginFooterView)
}

class EmailLoginFooterViewTextView: UITextView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        UIMenuController.shared.isMenuVisible = false
        return false
    }
}

open class EmailLoginFooterView: UIView {
    var delegate: EmailLoginFooterViewDelegate?
    var textView: EmailLoginFooterViewTextView? = EmailLoginFooterViewTextView()
    var forgetRange: NSRange?
    
    deinit {
        delegate = nil
        textView = nil
        textView?.delegate = nil
        forgetRange = nil
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(delegate: EmailLoginFooterViewDelegate) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonDeviceHeight))
        
        self.backgroundColor = UIColor.white
        
        self.delegate = delegate
        
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
        
        text = "パスワードを忘れた方はこちら"
        let forgetText = "こちら"
        
        attributedString = NSMutableAttributedString(string: text!)
        
        forgetRange = NSMakeRange(11, forgetText.characters.count)
        
        attributedString!.addAttribute(NSForegroundColorAttributeName, value: kBlackColor54, range: NSMakeRange(0, (text! as NSString).length))
        attributedString!.addAttribute(NSForegroundColorAttributeName, value: kMainGreenColor, range: forgetRange!)
        attributedString!.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: forgetRange!)
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.0
        paragraphStyle.lineSpacing = 1.0
        
        attributedString!.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString!.length))
        
        textView!.attributedText = attributedString
        
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
        
        if NSLocationInRange(isSelectedPosition,forgetRange!) {
            delegate?.emailLoginFooterViewForgetPassTapped(self)
        }
    }
}
