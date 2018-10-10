//
//  BaseModelObject.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/04/29.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

/**
 このprojectで使う全てのModelはBaseModelObjectを継承している
 updatePropertyWithAttributes()はdictionaryからModelを生成するときに使う
 主に、生成されるのはJSONを受け取った後か、キャッシュから生成する時かである

 */

import SwiftyJSON

public protocol BaseModelObjectProtocol {
    func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?)
}

open class BaseModelObject: NSObject, BaseModelObjectProtocol {
    
    override public init() {
        super.init()
    }
    
    required public init(dictionary: [String : AnyObject]?) {
        super.init()
        self.updatePropertyWithAttributes(dictionary)
    }
    
    public init(json: SwiftyJSON.JSON) {
        super.init()
        self.updatePropertyWithJSON(json)
    }
    
    open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {}
    
    open func updatePropertyWithJSON(_ json: SwiftyJSON.JSON) {}
    
    open class func cachedModelObjects(_ key: String!, modelClass: AnyClass) ->[BaseModelObject]? {
        let cacheList: [Any]? = JSONCache.cachedArrayListWithKey(key)
        if cacheList == nil {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [BaseModelObject] = modelDic.map({ (dic) in
            let registerModelClass = modelClass as! BaseModelObject.Type
            let model = registerModelClass.init(dictionary: dic)
            return model
        })
        return models
    }
    
    //passが例えば v1/users/Opional(5)のようにならないようにかつid == nilの時に落ちないように 、map,flatMapでは解決できなかったので一旦こっちで
    func idString(_ id: String?) ->String {
        if id != nil {
            return id!
        }
        return ""
    }
    
}
