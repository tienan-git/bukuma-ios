//
//  TwitterClient.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/23.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Accounts
import Social

// Twitterに連携という話があり、Classを作ったが、結局連携の話はなくなった。
//
private let TwitterClientConsumerKey: String = "dGSsfIvbxGLmhWU1e8Ico7Agb"
private let TwitterClientSecretKey: String = "Gctn6xQS9wBLeb3SaH8cKsxyy6yft2cOetyafD6itzG8c745Ep"

open class TwitterClient: NSObject {
    
    fileprivate class func showLoginErrorAlert(_ viewController: BaseViewController) {
        viewController.simpleAlert("iPhoneの設定画面からTwitterのアカウントが設定されているか、アクセスが許可されているか確認してください",
                                        message: nil,
                                        cancelTitle: "確認しました",
                                        completion: nil)
    }
    
    fileprivate class func showCustomErrorAlert(_ viewController: BaseViewController, errorMessage: String) {
        viewController.simpleAlert(errorMessage,
                                        message: nil,
                                        cancelTitle: "確認しました",
                                        completion: nil)
    }
    
    class func getAccounts(_ viewController: BaseViewController, completion: @escaping (_ accounts: [AnyObject]?, _ userNames: [AnyObject]?) ->Void) {
//        let accountStore: ACAccountStore = ACAccountStore()
//        _: ACAccountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
//        accountStore.requestAccessToAccounts(with: tyTwitter,
//                                                     options: nil) { (granted: Bool, error: NSError?) in
//                                                        DispatchQueue.main.async(execute: { 
//                                                            if !granted || error != nil {
//                                                                self.showLoginErrorAlert(viewController)
//                                                                completion(accounts: nil, userNames: nil)
//                                                                return
//                                                            }
//                                                            
//                                                            if granted {
//                                                                let accountsArray: [AnyObject]? = accountStore.accounts(with: tyTwitter)
//                                                                if accountsArray == nil || accountsArray?.count == 0 {
//                                                                    self.showLoginErrorAlert(viewController)
//                                                                    completion(accounts: nil, userNames: nil)
//                                                                    return
//                                                                }
//                                                                
//                                                                var accounts: [AnyObject] = Array()
//                                                                var names: [AnyObject] = Array()
//                                                                
//                                                                for account in accountsArray! {
//                                                                    accounts.append(account)
//                                                                    names.append(account.username)
//                                                                }
//                                                                completion(accounts: accounts, userNames: names)
//                                                            }
//                                                        })
        
        }
    }
    
    func postTweet(_ viewController: BaseViewController, twitterID: String, tweet: String, completion: @escaping (_ error: Error?) ->Void) {
//        self.getConnecedTwitterAccount(viewController,
//                                       twitterID: twitterID) { (account) in
//                                        DispatchQueue.main.async(execute: { 
//                                            if account == nil {
//                                                self.showLoginErrorAlert(viewController)
//                                                return
//                                            }
//                                            
//                                            let path: String = "https://api.twitter.com/1.1/statuses/update.json"
//                                            let url: URL = URL(string: path)!
//                                            let params: [String: AnyObject] = ["status": tweet as AnyObject]
//                                            
//                                            self.request(.POST,
//                                                account: account ?? ACAccount(),
//                                                url: url,
//                                                params: params,
//                                                completion: { (responce, error) in
//                                                    if error != nil {
//                                                        let costomError: Error = Error(domain: ErrorDomain, code: error!.code, userInfo: error!.userInfo)
//                                                        completion(costomError)
//                                                        return
//                                                    }
//                                                    completion(nil)
//                                                    //shared for twitter
//                                            })
//                                        })
//        }
    }
    
    func getConnecedTwitterAccount(_ viewController: BaseViewController, twitterID: String, completion: @escaping (_ account: ACAccount?) ->Void) {
//        TwitterClient.getAccounts(viewController) { (accounts, userNames) in
//            if accounts?.count > 0 {
//                for account in accounts! {
//                    if let properties = account.value(forKey: "properties") as? [String:String],
//                        let userId = properties["user_id"] {
//                        if twitterID == userId {
//                            completion(account as? ACAccount)
//                            break
//                        }
//                    }
//                }
//                return
//            }
//            completion(nil)
//        }
    }
    
    fileprivate func request(_ type: SLRequestMethod, account: ACAccount, url: URL, params: [String: AnyObject], completion: @escaping (_ responce: [String: AnyObject]?, _ error: NSError?) ->Void) {
        let reqest: SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter,
                                          requestMethod: type,
                                          url: url,
                                          parameters: params)
        reqest.account = account
//        reqest.perform { (responseData: Data?, urlResponse: HTTPURLResponse?, error: NSError?) in
//            DispatchQueue.main.async(execute: { 
//                if responseData != nil {
//                    let statusCode: Int? = urlResponse?.statusCode
//                    if statusCode >= 200 && statusCode < 300 {
//                    
//                        do {
//                            let response: [[String: AnyObject]]? = try! JSONSerialization.jsonObject(with: responseData!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? [[String : AnyObject]]
//                            DBLog(response)
//                            let res = response?[0]
//                            completion(responce: res, error: nil)
//                        }
//                        return
//                    }
//                    
//                    completion(responce: nil, error: error)
//                }
//            })
//        }
    }

    
//    func showActionSheetToChooseTwitterAccount(_ viewController: BaseViewController, completion: @escaping (_ account: ACAccount?) ->Void) {
//        self.getAccounts(viewController) { (accounts, userNames) in
//            if accounts?.count == 0 || accounts == nil {
//                completion(nil)
//                return
//            }
//            DispatchQueue.main.async(execute: {
//                RMUniversalAlert.showActionSheetInViewController(viewController: viewController,
//                                                                 title: "コネクトするTwitterアカウントを選択してください",
//                    message: nil,
//                    cancelButtonTitle: "キャンセル",
//                    destructiveButtonTitle: nil,
//                    otherButtonTitles: userNames,
//                    popoverPresentationControllerBlock: { (popover) in
//                        popover.sourceView = viewController.view
//                        popover.sourceRect = CGRect(x: viewController.view.center.x, y: viewController.view.center.y, width: 1, height: 1)
//                    }, tapBlock: { (al, index) in
//                        if index == al.cancelButtonIndex {
//                            completion(account: nil)
//                            return
//                        }
//                        completion(account: accounts?[index - 2] as? ACAccount)
//                })
//            })
//        }
//    }

