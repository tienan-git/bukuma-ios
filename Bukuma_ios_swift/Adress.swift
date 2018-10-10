//
//  Adress.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/16.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

public struct PostalInfo {
    var id: String?
    var code: String?
    var prefecture: String?
    var city: String?
    var area: String?
    var adress: Adress?
    
    init(dic: [String: AnyObject]?) {
        id = dic?["id"].map{String(describing: $0)}
        code = dic?["code"].map{String(describing: $0)}
        prefecture = dic?["prefecture"].map{String(describing: $0)}
        city = dic?["city"].map{String(describing: $0)}
        area = dic?["area"].map{String(describing: $0)}
        adress = self.adressFromPostalCode()
    }
    
    func adressFromPostalCode() -> Adress {
        let adress: Adress = Adress()
        adress.postalCode = code
        adress.prefecture = prefecture
        adress.city = city
        adress.houseNumberAdressLine = area
        return adress
    }
}

/**
 Adress Object
 
 */

open class Adress: BaseModelObject {
    var id: String?
    var name: String?
    var houseNumberAdressLine: String?
    var buildingNameAdressLine: String?
    var city: String?
    var prefecture: String?
    var postalCode: String?
    var country: String?
    var personName: String?
    var personFirstName: String?
    var personLastName: String?
    var personNameKana: String?
    var personFirstKana: String?
    var personLastKana: String?
    var personPhone: Phone? = Phone()
    var isDefaultAdress: Bool?
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        id = attributes?["id"].map{String(describing: $0)}
        name = attributes?["name"].map{String(describing: $0)}
        personName = attributes?["person_name"].map{String(describing: $0)}
        personNameKana = attributes?["person_name_kana"].map{String(describing: $0)}
        houseNumberAdressLine = attributes?["address_1"].map{String(describing: $0)}
        buildingNameAdressLine = attributes?["address_2"].map{String(describing: $0)}
        city = attributes?["city"].map{String(describing: $0)}
        postalCode = attributes?["postal_code"].map{String(describing: $0)}
        prefecture = attributes?["prefecture"].map{String(describing: $0)}
        country = attributes?["country"].map{String(describing: $0)}
        personPhone = Phone(currentPhoneNumber: attributes?["telephone"].map{String(describing: $0)}, confirmPhoneNumber: nil, newPhoneNumber: nil, codeFromSMS: nil)
        isDefaultAdress = attributes?["default"] as? Bool
    }
    
    ///同じ住所の情報かどうか
    class func isSameAdressInfo(_ tempAdress: Adress) ->Bool{
        let adresses: [Adress]? = self.cachedAdressList()
        
        if adresses == nil {
            return false
        }
        
        for adress in adresses! {
            if adress.name == tempAdress.personFirstName! + tempAdress.personLastName!  + tempAdress.postalCode! + tempAdress.prefecture! + tempAdress.city! + tempAdress.houseNumberAdressLine! + Me.sharedMe.identifier! {
                return true
            }
        }
        return false
    }
    ///住所を登録
    open class func registerAdress(_ adress: Adress, completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]

        params["person_name"] = adress.personFirstName! + adress.personLastName!
        params["person_name_kana"] = adress.personFirstKana! + adress.personLastKana!
        params["postal_code"] = adress.postalCode
        params["prefecture"] = adress.prefecture
        params["country"] = "ja"
        params["city"] = adress.city
        params["address_1"] = adress.houseNumberAdressLine
        params["address_2"] = adress.buildingNameAdressLine
        params["telephone"] = adress.personPhone?.currentPhoneNumber
        
        if adress.isDefaultAdress == true {
            params["default"] = 1
        } else {
            params["default"] = 0
        }
//        params["name"] = adress.personFirstName! + adress.personLastName!  + adress.postalCode! + adress.prefecture! + adress.city! + adress.houseNumberAdressLine! + Me.sharedMe.identifier!
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/addresses/create",
                                    parameters: params) { (responce, error) in
                                        if error == nil {
                                            DBLog(responce)

                                            Adress.getAdressList({ (adresses, error) in
                                                if error == nil {
                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MeMyInfoUpdateKey), object: nil)
                                                    completion(nil)
                                                } else {
                                                    completion(error)
                                                }
                                            })
                                        } else {
                                            DBLog(error)
                                            
                                            completion(error)
                                        }
        }
    }
    
    /// 住所を編集(APIとしてはあるが、機能として組み込まれていない。)
    open class func editAdress(_ adress: Adress, completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        
        params["person_name"] =  Utility.isEmpty(adress.personName) ? adress.personFirstName! + adress.personLastName! : adress.personName
        params["person_name_kana"] = Utility.isEmpty(adress.personNameKana) ? adress.personFirstKana! + adress.personLastKana! : adress.personNameKana
        params["postal_code"] = adress.postalCode
        params["prefecture"] = adress.prefecture
        params["country"] = "ja"
        params["city"] = adress.city
        params["address_1"] = adress.houseNumberAdressLine
        params["address_2"] = adress.buildingNameAdressLine
        params["telephone"] = adress.personPhone?.currentPhoneNumber
        if adress.isDefaultAdress == true {
            params["default"] = 1
        } else {
            params["default"] = 0
        }
        params["name"] = adress.name
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/addresses/\(adress.id!)",
                                    parameters: params) {(responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            Adress.getAdressList({ (adresses, error) in
                                                completion(nil)
                                            })
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    ///登録したAdressリストを取得
    open class func getAdressList(_ completion: ((_ adresses: [Adress]?, _ error: Error?) ->Void)?) {
        ApiClient.sharedClient.GET("v1/addresses",
                                    parameters: [:]) { (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            if responce!["user_addresses"] == nil {
                                                if completion != nil {
                                                    completion!(nil, nil)
                                                }
                                                return
                                            }
                                            
                                            let jsonArray = SwiftyJSON.JSON(responce!["user_addresses"]!).arrayObject!
                                            JSONCache.cacheArray(jsonArray, key: AdressListCacheKey)
                                            let jsonDic = jsonArray as! [[String: AnyObject]]
                                            let addresses: [Adress] = jsonDic.map({ (dic) in
                                                let adress: Adress? = Adress(dictionary: dic)
                                                return adress!
                                            })
                                            if completion != nil {
                                                completion!(addresses, nil)
                                            }
                                            
                                        } else {
                                            DBLog(error)
                                            if completion != nil {
                                                completion!(nil, error)
                                            }
                                        }
        }
    }
    ///IDを送って、Adressの情報を取得
    open func getAdressFromId(_ adressId:String?, completion: @escaping (_ adress: Adress?, _ error: Error?) ->Void) {
        ApiClient.sharedClient.POST("v1/addresses/\(adressId!)",
                                    parameters: [:]) { (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            
                                            let jsonDic = SwiftyJSON.JSON(responce!["address"]!).dictionaryObject!
                                            let adress: Adress? = Adress(dictionary: jsonDic as [String : AnyObject]?)
                                            completion(adress, nil)
                                            
                                        } else {
                                            DBLog(error)
                                            completion(nil, error)
                                            
                                        }
        }
    }
    ///adressを削除する
    open func deleteAdress(_ completion: @escaping (_ error: Error?) ->Void) {
        ApiClient.sharedClient.DELETE("v1/addresses/\(self.id!)",
                                      parameters: [:]) { (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            
                                            completion(nil)
                                        } else {
                                            
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    ///郵便番号検索
    open class func searchAdressFromPostalCode(_ code: String?, completion:@escaping (_ postalInfo: PostalInfo?, _ error: Error?) ->Void) {
        if code!.isIntOnly() == false {
            completion(nil, nil)
            return
        }
        
        ApiClient.sharedClient.GET("v1/postal_codes/\(code!)",
                                    parameters: [:]) { (responce, error) in
                                        if error == nil {
                                            DBLog(responce)
                                            
                                            let postalInfo: PostalInfo = PostalInfo(dic: responce!["postal_code"] as? [String: AnyObject])
                                            completion(postalInfo, nil)
                                            
                                        } else {
                                            DBLog(error)
                                            completion(nil, error)
                                        }
        }
    }
    
    open class func cachedAdressList() ->[Adress]? {
        return self.cachedModelObjects(AdressListCacheKey, modelClass: Adress.self) as? [Adress]
    }
    
    open class func defaultAdress() ->Adress? {
        let array: [Adress]? = Adress.cachedAdressList()
        let defaultAdress: Adress? = array?.filter({ (adress) -> Bool in
            return adress.isDefaultAdress == true
        }).first
        
        if defaultAdress != nil {
            return defaultAdress
        }
        
        if defaultAdress == nil && (array?.count ?? 0) > 0 {
            return Adress.cachedAdressList()?[0]
        }
        return nil
    }
    
    open class func defaultAdressPrefecture() ->String? {
        let defaultAdress: Adress? = Adress.defaultAdress()
        if defaultAdress != nil {
            return defaultAdress!.prefecture
        }
        return nil
    }
    
    static var prefectures: [String] = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県",
                                         "埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県",
                                          "岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県",
                                           "鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県",
                                            "佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県","海外"]
}
