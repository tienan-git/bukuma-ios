//
//  MessageTextPostView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/01.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

private let MessageTextPostViewDefaltHeight: CGFloat = UIImage(named: "ic_ui_chat_plus")!.size.height
private let MessageTextPostViewSendButtonWidth: CGFloat = 57.0
private let MessageTextPostViewSendButtonHeight: CGFloat = 34.0
private let MessageTextPostViewTextViewMaxHeight: CGFloat = 90.0
private let MessageTextPostViewMaxNumOfText: Int = 100

@objc public protocol MessageTextPostViewDelegate: NSObjectProtocol {
    func changeHeight(_ newHeight: CGFloat, oldHeight: CGFloat)
    func pushSendButton(_ text: String?, completion:@escaping () ->Void)
    func pushCameraButton(_ completion:@escaping () ->Void)
    func pushMensionButton(_ completion:@escaping () ->Void)
}

open class MessageTextPostView: UIView, UITextViewDelegate {
    
    fileprivate weak var delegate: MessageTextPostViewDelegate?
    open let sendButton: UIButton! = UIButton()
    open let cameraStartButton: UIButton! = UIButton()
    open let textView: UITextView! = UITextView()
    open let mensionButton: UIButton! = UIButton()
    fileprivate var isAlreadySet: Bool?
    fileprivate var hideKeybourdEnabled: Bool?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(delegate: MessageTextPostViewDelegate) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: MessageTextPostViewDefaltHeight))
        self.delegate = delegate
        self.backgroundColor = UIColor.white
        
        let separateView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 0.5))
        separateView.backgroundColor = UIColor.black.withAlphaComponent(0.12)
        self.addSubview(separateView)
        
        sendButton.frame = CGRect(x: kCommonDeviceWidth - MessageTextPostViewSendButtonWidth - 5.0,
                                  y: (MessageTextPostViewDefaltHeight - MessageTextPostViewSendButtonHeight) / 2,
                                  width: MessageTextPostViewSendButtonWidth,
                                  height: MessageTextPostViewSendButtonHeight)
        sendButton.clipsToBounds = true
        sendButton.layer.cornerRadius = 2.0
        sendButton.setBackgroundColor(UIColor.clear, state: .normal)
        sendButton.setTitle("送信", for: .normal)
        sendButton.contentVerticalAlignment = .center
        sendButton.contentHorizontalAlignment = .center
        sendButton.titleLabel!.adjustsFontSizeToFitWidth = true
        sendButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 17)
        sendButton.setTitleColor(UIColor.colorWithDecimal(0, green: 0, blue: 0, alpha: 0.26), for: .disabled)
        sendButton.setTitleColor(kMainGreenColor, for: .normal)
        sendButton.setTitleColor(kMainGreenColor, for: .highlighted)
        sendButton.addTarget(self, action: #selector(self.sendButtonTapped(_:)), for: .touchUpInside)
        sendButton.isEnabled = false
        self.addSubview(sendButton)
        
        mensionButton.frame = CGRect(x: 0,
                                     y: 0,
                                     width: UIImage(named: "ic_ui_chat_plus")!.size.width,
                                     height: MessageTextPostViewDefaltHeight)
        mensionButton.setImage(UIImage(named: "ic_ui_chat_plus"), for: .normal)
        mensionButton.isUserInteractionEnabled = true
        mensionButton.addTarget(self, action: #selector(self.mensionButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(mensionButton)

        cameraStartButton.frame = CGRect(x: mensionButton.right,
                                         y: 0,
                                         width: UIImage(named: "ic_ui_chat_camera")!.size.width,
                                         height: UIImage(named: "ic_ui_chat_camera")!.size.height)
        cameraStartButton.setImage(UIImage(named: "ic_ui_chat_camera"), for: .normal)
        cameraStartButton.isUserInteractionEnabled = true
        cameraStartButton.addTarget(self, action: #selector(self.cameraStartButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(cameraStartButton)
        
        textView.frame = CGRect(x: cameraStartButton.right + 10.0,
                                y: 11.0,
                                width: sendButton.left - cameraStartButton.right - 10.0,
                                height: MessageTextPostViewSendButtonHeight)
        textView.textContainerInset = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
        textView.layer.borderWidth = 0.5
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.delegate = self
        textView.backgroundColor = UIColor.colorWithHex(0xF9F9F9)
        textView.layer.borderColor = UIColor.colorWithHex(0xCECFD1).cgColor
        textView.layer.cornerRadius = 2.0
        textView.autocapitalizationType = .none
        textView.keyboardType = .default
        self.addSubview(textView)

    }
    
    func sendButtonTapped(_ sender: UIButton) {
        if textView.text.characters.count == 0 {
            return
        }
        
        self.isUserInteractionEnabled = false
        weak var me = self
        
        let text: String? = textView.text
        textView.text = nil
        
        if self.delegate!.responds(to: #selector(MessageTextPostViewDelegate.pushSendButton(_:completion:))) {
            self.delegate!.pushSendButton(text, completion: {
                DispatchQueue.main.async {
                    me?.sendButton.isEnabled = false
                    me?.isUserInteractionEnabled = true
                }
            })
        }
    }
    
    func cameraStartButtonTapped(_ sender: UIButton) {
        self.isUserInteractionEnabled = false
        weak var me = self
        if self.delegate!.responds(to: #selector(MessageTextPostViewDelegate.pushCameraButton(_:))) {
            self.delegate?.pushCameraButton({
               DispatchQueue.main.async {
                    me?.isUserInteractionEnabled = true
                }
            })
        }
    }
    
    func mensionButtonTapped(_ sender: UIButton) {
        self.isUserInteractionEnabled = false
        weak var me = self
        if self.delegate!.responds(to: #selector(MessageTextPostViewDelegate.pushMensionButton(_:))) {
            self.delegate?.pushMensionButton({
                DispatchQueue.main.async {
                    me?.isUserInteractionEnabled = true
                }
            })
        }
    }
    
    // ================================================================================
    // MARK:- UITextViewDelegaete

    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let str: NSMutableString = textView.text.mutableCopy() as! NSMutableString
        str.replaceCharacters(in: range, with: text)
        
        self.changeTextViewHeight(textView)
        
        if str.length > MessageTextPostViewMaxNumOfText {
            return false
        }
        return true
    }
    
    open func textViewDidChange(_ textView: UITextView) {
         sendButton.isEnabled = textView.text.length > 0
    }
    
    fileprivate func changeTextViewHeight(_ textView: UITextView) {
        UIView.animate(withDuration:0.1, animations: {
            
            let newContentSize: CGSize =  textView.contentSize
            if newContentSize.height > MessageTextPostViewTextViewMaxHeight {
                return
            }
            
            let lastHeight: CGFloat = self.textView.height + 11.0 * 2
            textView.height = newContentSize.height
            textView.contentOffsetY = 0.0
            self.height = self.textView.height + 11.0 * 2
            self.cameraStartButton.bottom = self.height
            self.mensionButton.bottom = self.height
            
            self.sendButton.bottom = self.height - 11.0
            
            if self.isAlreadySet == false {
                self.sendButton.bottom = self.height - 11.0
                self.isAlreadySet = true
            }
            
            self.delegate?.changeHeight(self.height, oldHeight: lastHeight)
        })
    }
    
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if hideKeybourdEnabled == true {
            hideKeybourdEnabled = false
            return true
        }
        return false
    }
    
    open func showKeyboard() {
        textView.center.y = self.center.y
        sendButton.bottom = self.bottom - 11.0
        cameraStartButton.bottom = self.bottom
        self.mensionButton.bottom = self.height
    }
    
    open func dismissKeyboard() {
        hideKeybourdEnabled = true
        textView.resignFirstResponder()
    }
    
}
