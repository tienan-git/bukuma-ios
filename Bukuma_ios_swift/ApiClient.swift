//
//  BKMApiClient.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/10.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class ApiClient: BaseApiClient {
    override open class func baseURL() ->String? {
        #if DEBUG
            return "http://stg.bukuma.io/"
        #elseif STAGING
            return "http://stg.bukuma.io/"
        #else
            return "https://api.bukuma.io/"
        #endif
    }
    
    override open class func apiKey() ->String? {
        return "98c63d8f9214a4dafdb4d75e180b88619441281c52a4ffc086fca252f5b2b811"
    }
}
