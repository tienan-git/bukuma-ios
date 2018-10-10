//
//  DeleteAccountViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/12/08.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert
import SwiftTips

//========================================================================
// MARK: - class宣言

class DeleteAccountViewController: BaseViewController {
    fileprivate var reason: Reason = Reason()
    fileprivate let scrollView: UIScrollView = UIScrollView()
    fileprivate let deleteView: DeleteAccountView = DeleteAccountView()

    fileprivate let minPointBalance: Int = 100

//========================================================================
// MARK: - viewCycle

    override open func initializeNavigationLayout() {
        self.title = "退会理由"
        navigationBarTitle = "退会理由"
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.isNeedKeyboardNotification = true
        self.view.backgroundColor = UIColor.white

        deleteView.delegate = self
        
        scrollView.frame = self.view.bounds
        scrollView.isUserInteractionEnabled = true
        self.view.insertSubview(scrollView, belowSubview: navigationBarView!)
        
        scrollView.addSubview(deleteView)
        scrollView.contentSize = CGSize(width: kCommonDeviceWidth, height: self.scrollHeight())
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: scrollView.contentInsetTop,
                                                        left: scrollView.contentInsetLeft,
                                                        bottom: scrollView.contentInsetBottom,
                                                        right: scrollView.contentInsetRight)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapView(sender:)))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initializeNavigationLayout()
    }
    
    override func keyboardDidShow(_ notification: Foundation.Notification) {
        let keyboardFrame: CGRect = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration: Float = ((notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        let animationCurve: UInt = ((notification as NSNotification).userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue
        
        scrollView.contentSize = CGSize(width: kCommonDeviceWidth, height: self.scrollHeight() + keyboardFrame.size.height)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: scrollView.contentInsetTop,
                                                        left: scrollView.contentInsetLeft,
                                                        bottom: scrollView.contentInsetBottom,
                                                        right: scrollView.contentInsetRight)
        
        UIView.animate(withDuration: TimeInterval(duration),
                       delay: 0.0,
                       options: UIViewAnimationOptions.init(rawValue: animationCurve),
                       animations: {
                        let scrollableHeight = self.scrollHeight() - self.scrollView.frame.size.height
                        self.scrollView.contentOffsetY = (keyboardFrame.size.height + scrollableHeight)
        }, completion: nil)
    }
    
    override func keyboardDidHide(_ notification: Foundation.Notification) {
        let duration: Float = ((notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        let animationCurve: UInt = ((notification as NSNotification).userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue
        
        scrollView.contentSize = CGSize(width: kCommonDeviceWidth, height:self.scrollHeight())
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: scrollView.contentInsetTop,
                                                        left: scrollView.contentInsetLeft,
                                                        bottom: scrollView.contentInsetBottom,
                                                        right: scrollView.contentInsetRight)
        
        UIView.animate(withDuration: TimeInterval(duration),
                       delay: 0.0,
                       options: UIViewAnimationOptions.init(rawValue: animationCurve),
                       animations: {
                        
                        self.scrollView.contentOffsetY = 0
                        
        }, completion: nil)

    }
}

//========================================================================
// MARK: - DeleteAccountViewDelegate Medhod
extension DeleteAccountViewController: DeleteAccountViewDelegate {
    func deleteAccountView(didTapDeleteButton view: DeleteAccountView, reasonId inReasonId: Int, reasonText inReasonText: String, userComment inUserComment: String) {
        if inReasonId == 0 {
            self.simpleAlert("退会理由を選択して下さい。", message: nil, cancelTitle: "OK", completion: nil)
            return
        }

        self.reason.choice = inReasonId
        self.reason.comment = inUserComment
        self.reason.deleteReason = inReasonText

        self.view.endEditing(true)
        self.showAccountDeleteAlert(withPoint: Me.sharedMe.point?.bonusPoint ?? 0)
    }

    func deleteAccountView(didResize view: DeleteAccountView) {
        self.scrollView.contentSize = CGSize(width: kCommonDeviceWidth, height: self.scrollHeight())
    }
}

//========================================================================
// MARK: -　退会処理のメソッド
extension DeleteAccountViewController {
    private func deleteAccount() {
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.show()

        Me.sharedMe.delete(account: reason) { [weak self] (error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self?.view.isUserInteractionEnabled = true

                if error != nil {
                    var errMessage = error?.errorDespription
                    if error?.code == 403 {
                        if error?.errorCodeType == .accessForbidden {
                            errMessage = "取引中の商品があるため退会できません。"
                        }
                    }
                    self?.simpleAlert(nil, message: errMessage, cancelTitle: "OK") {
                        self?.popViewController()
                    }
                    return
                }

                self?.showSuccessAccountDeleteAlert()
            }
        }
    }

    fileprivate func showAccountDeleteAlert(withPoint point: Int) {
        alert(on: self,
              title: "本当に退会しますか？",
              message: "退会すると全てのデータが消えてしまいます。",
              defaultButtonTitle: "キャンセル",
              destructiveButtonTitle: "退会",
              moreSetup: { (_ alert: UIAlertController) in
                if point >= self.minPointBalance {
                    let messageText = NSMutableAttributedString(string: "\n退会すると全てのデータが\n消えてしまいます。\n退会後6ヶ月間、再登録ができなくなり\nますのでご注意ください。\n\n",
                                                                attributes: [NSForegroundColorAttributeName: UIColor.black,
                                                                             NSFontAttributeName: UIFont.systemFont(ofSize: 13)])
                    messageText.append(NSMutableAttributedString(string: "！ポイントが\(point.thousandsSeparator())pt残っています！",
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.red,
                                                                              NSFontAttributeName: UIFont.systemFont(ofSize: 13)]))
                    alert.setValue(messageText, forKey: "attributedMessage")
                }
        }) { [weak self] (_ byDestructive: Bool) in
            if byDestructive {
                DispatchQueue.main.async {
                    self?.deleteAccount()
                }
            }
        }
    }

    private func showSuccessAccountDeleteAlert() {
        RMUniversalAlert.show(in: self,
                              withTitle: "退会しました",
                              message: "いままでご利用ありがとうございました！\nまたのご利用をお待ちしております！",
                              cancelButtonTitle: "OK",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: nil,
                              tap: {[weak self] (alert, buttonIndex) in
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute:  {
                                    self?.popViewController()
                                })
        })
    }
}

//========================================================================
// MARK: - UIGestureRecognizerDelegate
extension DeleteAccountViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UITextView || touch.view is UITextField || touch.view is UIButton {
            return false
        }
        DBLog(touch.view)
        
        return true
    }
}

//========================================================================
// MARK: - Gestureの際に使うmedhod
extension DeleteAccountViewController {
    func tapView(sender: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    fileprivate func scrollHeight() ->CGFloat {
        return self.deleteView.frame.size.height + kCommonStatusBarHeight
    }
}


