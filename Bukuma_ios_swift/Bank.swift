//
//  Bank.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/24.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON 

open class Bank: BaseModelObject {
    var id: String?
    var name: String?
    var nameKana: String?
    var bankName: String?
    var branch: String?
    var accountType: String?
    var number: String?
    
    var firstNameKana: String?
    var lastNameKana: String?
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        id = attributes?["id"].map{String(describing: $0)}
        name = attributes?["name"].map{String(describing: $0)}
        nameKana = attributes?["name_kana"].map{String(describing: $0)}
        bankName = attributes?["bank_name"].map{String(describing: $0)}
        branch = attributes?["branch"].map{String(describing: $0)}
        accountType = attributes?["account_type"].map{String(describing: $0)}
        number = attributes?["number"].map{String(describing: $0)}
    }
    
    open class func registerBankAccount(_ bank: Bank, completion:@escaping (_ bank: Bank?,_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        if Utility.isEmpty(bank.firstNameKana) == false {
            params["name"] = "\(bank.firstNameKana!) \(bank.lastNameKana!)"
            params["name_kana"] = "\(bank.firstNameKana!) \(bank.lastNameKana!)"
        } else {
            params["name"] = bank.name
            params["name_kana"] = bank.nameKana
        }
        params["bank_name"] = bank.bankName
        params["branch"] = bank.branch
        params["account_type"] = bank.accountType
        params["number"] = bank.number

        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/bank_accounts/create",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                            if responceObject?["bank_accounts"] != nil {
                                                let jsonArray = responceObject!["bank_accounts"] as! [AnyObject]
                                                let jsonDic = jsonArray as! [[String: AnyObject]]
                                                var bank: Bank?
                                                _ = jsonDic.map({ (dic) in
                                                    bank = Bank(dictionary: dic)
                                                })
                                                completion(bank, nil)
                                            }
                                            
                                        } else {
                                            completion(nil, error)
                                            DBLog(error)
                                            
                                        }
        }
    }
    
    open class func editBankAccount(_ bank: Bank, completion:@escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        if Utility.isEmpty(bank.firstNameKana) == false {
            params["name"] = "\(bank.firstNameKana!) \(bank.lastNameKana!)"
            params["name_kana"] = "\(bank.firstNameKana!) \(bank.lastNameKana!)"
        } else {
            params["name"] = bank.name
            params["name_kana"] = bank.nameKana
        }
        params["bank_name"] = bank.bankName
        params["branch"] = bank.branch
        params["account_type"] = bank.accountType
        params["number"] = bank.number
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("/v1/bank_accounts/\(bank.idString(bank.id))",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            self.getBankAccountList({ (banks, error) in
                                                if error == nil {
                                                    completion(nil)
                                                    return
                                                }
                                                completion(error)
                                            })
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    
    open class func getBankAccountList(_ completion:@escaping (_ banks: Array<Bank>?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["number"] = 20
        params["page"] = 0
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/bank_accounts",
                                   parameters: params) { (responce, error) in
                                    if error == nil {
                                        DBLog(responce)
                                        
                                        if responce!["bank_accounts"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responce!["bank_accounts"]!).arrayObject!
                                        JSONCache.cacheArray(jsonArray, key: BankListCacheKey)
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let banks: [Bank] = jsonDic.map({ (dic) in
                                            let bank: Bank? = Bank(dictionary: dic)
                                            return bank!
                                        })
                                        
                                        completion(banks, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    open class func getBankAccountFromId(_ id: String, completion:@escaping (_ bank: Bank?, _ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/bank_accounts/\(id)",
                                   parameters: [:]) { (responce, error) in
                                    if error == nil {
                                        DBLog(responce)
                                        let bank: Bank = Bank(dictionary: responce!["bank_account"] as? [String: AnyObject])
                                        completion(bank, nil)
                                        
                                    } else {
                                        DBLog(error)
                                    }
        }
    }
    
    
    open func deleteBankAccount() {
        ApiClient.sharedClient.DELETE("v1/bank_accounts/\(self.idString(id))",
                                      parameters: [:]) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                        } else {
                                            DBLog(error)
                                        }
        }
    }
    
    open func createWithdraw(_ point: Int, completion: @escaping (_ withdraw: Withdraw?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["point"] = point
        
        DBLog(params)
        
        DBLog(self.idString(id))
        
        ApiClient.sharedClient.POST("v1/bank_accounts/\(self.idString(id))/withdraw",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                            let withdraw: Withdraw = Withdraw(dictionary: responceObject?["withdraw_transaction"] as? [String: AnyObject])
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
                                            completion(withdraw, nil)
                                        } else {
                                            SBLog(error!)
                                            completion(nil, error)
                                        }
        }
    }
    
    open class func getWithdrawTransactionsList(_ page: Int, completion: @escaping (_ withdraws: [Withdraw]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 20
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/bank_accounts/withdraw_transactions",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        if responceObject!["withdraw_transactions"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["withdraw_transactions"]!).arrayObject!
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let withdraws: [Withdraw] = jsonDic.map({ (dic) in
                                            let withdraw: Withdraw? = Withdraw(dictionary: dic)
                                            return withdraw!
                                        })
                                        
                                        completion(withdraws, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    open class func cachedBankList() ->Array<Bank>? {
        let cacheList: [Any]? = JSONCache.cachedArrayListWithKey(BankListCacheKey)
        if cacheList == nil {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [Bank] = modelDic.map({ (dic) in
            let model = Bank.init(dictionary: dic)
            model.firstNameKana = self.kanasTapple(model.name!).firstKana
            model.lastNameKana = self.kanasTapple(model.name!).lastKana            
            return model
        })
        return models
    }
    
    open class func cacheBankKanasTapple() ->(firstKana: String?, lastKana: String?) {
        let bank: Bank? = self.cachedBankList()?[0]
        
        if Utility.isEmpty(bank) {
            return (nil,nil)
        }
        return self.kanasTapple(bank!.name!)
    }
    
    class func kanasTapple(_ text: String) -> (firstKana: String?, lastKana: String?)  {
        let startIndex = text.characters.index(of: " ")
        let currentIndex = text.index(text.startIndex, offsetBy: text.distance(from: text.startIndex, to: startIndex!))
        let firstName = text.substring(to:currentIndex)
        
        let range = startIndex!..<text.endIndex
        let lastName = text.substring(with: range)
        
        return (firstName,lastName)
    }
    
    open func isInfomationChanged(_ bank: Bank) ->Bool {
        return self.bankName != bank.bankName ||
            self.accountType != bank.accountType ||
            self.branch != bank.branch ||
            self.number != bank.number ||
            self.firstNameKana != bank.firstNameKana ||
            self.lastNameKana != bank.lastNameKana
    }
}
