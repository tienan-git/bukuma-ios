//
//  MessagePostView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/01.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol MessagePostViewDelegate: NSObjectProtocol {
    func sendTetxt(_ text: String?, completion:@escaping (_ error: Error?) ->Void)
    func showCameraMenu(_ completion:@escaping () ->Void)
    func showMensionList(_ completion:@escaping () ->Void)
    func changeHeight(_ height: CGFloat)
}

open class MessagePostView: UIView, MessageTextPostViewDelegate {
    
    open var textPostView: MessageTextPostView?
    fileprivate weak var delegate: MessagePostViewDelegate?
    
    open var isShowingKeyboard: Bool? {
        get {
            return textPostView?.textView.isFirstResponder
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(delegate: MessagePostViewDelegate) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 0))
        
        self.delegate = delegate
        textPostView = MessageTextPostView.init(delegate: self)
        textPostView!.y = 0
        self.addSubview(textPostView!)
        
        self.height = textPostView!.height
        
        NotificationCenter.default.addObserver(self,selector:#selector(self.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(self.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    open func dismissKeyboard() {
        textPostView?.dismissKeyboard()
    }
    
    open func showKeyboard() {
        textPostView?.showKeyboard()
    }
    
    // ================================================================================
    // MARK:- messageTextPostViewDelegate
    
    open func changeHeight(_ newHeight: CGFloat, oldHeight: CGFloat) {
        self.height += newHeight - oldHeight
        textPostView?.y = 0
        if self.delegate!.responds(to: #selector(MessagePostViewDelegate.changeHeight(_:))) {
            self.delegate!.changeHeight(self.height)
        }
    }
    
    open func pushSendButton(_ text: String?, completion: @escaping () -> Void) {
        if self.delegate!.responds(to: #selector(MessagePostViewDelegate.sendTetxt(_:completion:))) {
            self.delegate!.sendTetxt(text, completion: { (error) in
                DispatchQueue.main.async(execute: {
                    completion()
                })
            })
        }
    }
    
    open func pushCameraButton(_ completion: @escaping () -> Void) {
        if self.delegate!.responds(to: #selector(MessagePostViewDelegate.showCameraMenu(_:))) {
            self.delegate!.showCameraMenu(completion)
        }
    }
    
    open func pushMensionButton(_ completion: @escaping () ->Void) {
        if self.delegate!.responds(to: #selector(MessagePostViewDelegate.showMensionList(_:))) {
            self.delegate!.showMensionList(completion)
        }
    }
    
    // ================================================================================
    // MARK:- keyboard
    
    func keyboardDidShow(_ notification: Foundation.Notification) {
        let keyboardFrame: CGRect = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration: Float = ((notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        let animationCurve: UInt = ((notification as NSNotification).userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue
        
        UIView.animate(withDuration: TimeInterval(duration),
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.init(rawValue: animationCurve),
                                   animations: {
                                    self.height = keyboardFrame.size.height + self.textPostView!.height
                                    if self.delegate!.responds(to: #selector(MessagePostViewDelegate.changeHeight(_:))) {
                                        self.delegate!.changeHeight(self.height)
                                    }
                                    self.textPostView!.showKeyboard()
            }, completion: nil)
    }
    
    func keyboardDidHide(_ notification: Foundation.Notification) {
        let duration: Float = ((notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        let animationCurve: UInt = ((notification as NSNotification).userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue
        
        UIView.animate(withDuration: TimeInterval(duration),
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.init(rawValue: animationCurve),
                                   animations: {
                                    self.height = self.textPostView!.height
                                    if self.delegate!.responds(to: #selector(MessagePostViewDelegate.changeHeight(_:))) {
                                        self.delegate!.changeHeight(self.height)
                                    }
            }, completion: nil)
    }
    
    
}
