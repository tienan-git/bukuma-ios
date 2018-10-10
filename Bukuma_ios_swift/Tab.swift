//
//  Tab.swift
//  Bukuma_ios_swift
//
//  Created by tani on 2017/05/02.
//  Copyright © 2017年 Labit Inc. All rights reserved.
//

import SwiftyJSON

/**
 Tab Object
*/

open class Tab: BaseModelObject {
    var id: String?
    var name: String?
    var url: String?
    
    private static var needFetchingTabs = true
    
    open override func updatePropertyWithJSON(_ json: JSON) {
        id = json["id"].string
        name = json["name"].string
        url = json["url"].string
    }
    
    open class func getTabs(_ completion: @escaping ([Tab]?, Error?) -> Void) {
        ApiClient.sharedClient.get("v1/tabs", parameters: [:]) { (responce, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let tabs = responce["tabs"].array?.map({
                Tab(json: $0)
            })
            completion(tabs, nil)
        }
    }
    
    class func fetchTabsIfNeed() {
        if !needFetchingTabs {
            return
        }
        
        needFetchingTabs = false
        Tab.getTabs { (tabs, error) in
            DispatchQueue.main.async {
                if let error = error {
                    needFetchingTabs = true
                    if error.errorCodeType != .serviceUnavailable {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { fetchTabsIfNeed() })
                    }
                    return
                }
                
                TabManager.sharedManager.homeViewController?.setTabs(tabs, completion: {
                    kAppDelegate.refreshBanners()
                })
            }
        }
    }
}
