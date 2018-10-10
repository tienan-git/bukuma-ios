//
//  Category.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

/**
 Category Object
*/


open class Category: BaseModelObject {
    var categoryId: String? //root category id
    var id: String?
    var categoryName: String?
    var subCategoriesCount: Int? = 0
    var subCategories: [Category]?
    var tempName: String?
    
    private static var needFetchingCategories = true
    
    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        super.updatePropertyWithAttributes(attributes)
        id = attributes?["id"].map{String(describing: $0)}
        categoryId = attributes?["category_id"].map{String(describing: $0)}
        categoryName = attributes?["name"].map{String(describing: $0)}
        
        subCategoriesCount = attributes?["categories_count"] as? Int
        subCategories = Array()
        
        let count: Int = subCategoriesCount ?? 0
        
        let subCategoriesArray: [AnyObject]? = attributes?["categories"] as? [AnyObject]
        
        if count > 0 {
            var i: Int = 0
            for _ in subCategoriesArray as! [[String: AnyObject]] {
                let dic: [String: AnyObject] = subCategoriesArray![i] as! [String : AnyObject]
                let category: Category? = Category(dictionary: dic["category"] as? [String: AnyObject])
                subCategories?.append(category!)
                i += 1
            }
        }
    }
    
    func updateProperty(_ newCategory: Category) {
        categoryId = newCategory.categoryId
        id = newCategory.id
        categoryName = newCategory.categoryName
        subCategoriesCount = newCategory.subCategoriesCount
        subCategories = newCategory.subCategories
    }

    /**
     Category List取得
     */

    open class func getCategories(_ completion: ((_ categories:Array<Category>?, _ error: Error?) ->Void)? = nil) {
        ApiClient.sharedClient.GET("v1/categories",
                                   parameters: [:]) { (responce, error) in
                                    if error == nil {
                                        DBLog(responce)
                                        
                                        let jsonArray = SwiftyJSON.JSON(responce!["categories"]!).arrayObject!

                                        JSONCache.cacheArray(jsonArray, key: CategoryListCacheKey)
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        
                                        var categories: [Category] = Array()
                                        
                                        _ = jsonDic.map({ (dic) in
                                            let category: Category? = Category(dictionary: dic)
                                            if category?.id == 1.string() {
                                                categories.append(category!)
                                                for c in category!.subCategories!.enumerated() {
                                                    DBLog("---------------Category Order \(c.offset) Categort Name \(String(describing: c.element.categoryName))")
                                                    categories.append(c.element)
                                                }
                                            }
                                        })
                                        
                                        completion?(categories, nil)

                                    } else {
                                        DBLog(error)
                                        completion?(nil, error)
                                    }
        }
    }
    
    static var cachedCategoryList: [Category]?
    static var categoryExpectSynthesis: [Category]?
    
    /**
     総合を除いたカテゴリかどうか
     */
    open class func cachedCategory(_ useSynthesis: Bool) ->[Category]? {
        
        if Category.cachedCategoryList != nil {
            if useSynthesis == true {
                return cachedCategoryList
            }

            if Category.categoryExpectSynthesis == nil {
                Category.categoryExpectSynthesis = Category.cachedCategoryList!
                let category: Category? = Category.categoryExpectSynthesis?.filter {return $0.categoryId == "1"}.first
                
                if let synthesisCategory = category {
                    categoryExpectSynthesis?.removeObject(synthesisCategory)
                }
            }
            return categoryExpectSynthesis
        }
        
        let cacheList: [Any]? = JSONCache.cachedArrayListWithKey(CategoryListCacheKey)
        if cacheList == nil {
            return nil
        }
        
        let jsonDic = cacheList as! [[String: AnyObject]]
        var categories: [Category] = Array()
        _ = jsonDic.map({ (dic) in
            let category: Category? = Category(dictionary: dic)
            if category?.id == 1.string() {
                categories.append(category!)
                for c in category!.subCategories!.enumerated() {
                    //DBLog("---------------Category Order \(c.offset) Categort Name \(c.element.categoryName)")
                    categories.append(c.element)
                }
            }
        })
        Category.cachedCategoryList = categories
        return categories
    }
    
    // for search collection View
    /**
    カテゴリページで使われている
     v1.5からはローカルソートからserverからのソートに変更している
     */
    class func sortedCategory() ->[Category] {
        guard let cachedCategories = self.cachedCategory(false) else {
            return []
        }
        return cachedCategories
        
//        guard let cached = cachedCategories else { return [] }
//        let novel = cached["小説・エッセイ"]
//        let human = cached["人文・思想"]
//        let society = cached["社会・政治"]
//        let nonFic = cached["ノンフィクション"]
//        let history = cached["歴史・地理"]
//        let business = cached["ビジネス・経済"]
//        let investment = cached["投資・金融"]
//        let conputer = cached["IT・コンピュータ"]
//        let life = cached["美容・健康・ダイエット"]
//        let hobby = cached["趣味・実用"]
//        let magazine = cached["雑誌"]
//        let comic = cached["漫画（コミック）"]
//        let ehon = cached["絵本・児童書"]
//        let launguage = cached["語学・学習"]
//        let studty = cached["資格・就職"]
//        let education = cached["教育・受験"]
//        let tech = cached["科学・テクノロジー"]
//        let doctor = cached["医学・薬学"]
//        let sports = cached["スポーツ・アウトドア"]
//        let trip = cached["旅行・マップ"]
//        let design = cached["建築・デザイン"]
//        let music = cached["楽譜"]
//        let entame = cached["エンターテイメント"]
//        let lightNovel = cached["ライトノベル"]
//        let talent = cached["タレント写真集"]
//        let west = cached["洋書"]
//        
//        return [novel, human, society, nonFic, history, business, investment, conputer, life, hobby, magazine, comic,ehon, launguage, studty, education, tech, doctor, sports, trip, design, music, entame , lightNovel, talent, west ]
        
    }
    
    class func fetchCategoriesIfNeed() {
        if !needFetchingCategories {
            return
        }
        
        needFetchingCategories = false
        getCategories { (categories, error) in
            if let error = error {
                needFetchingCategories = true
                if error.errorCodeType != .serviceUnavailable {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { fetchCategoriesIfNeed() })
                }
            }
        }
    }
}

private extension Array where Element: Category {
    
    subscript(categoryName: String) ->Category {
        get {
            var category: Category?
            for element in self.enumerated() {
                if element.element.categoryName == categoryName {
                    category = element.element
                }
            }
            guard let c = category else { fatalError("カテゴリなし") }
            return c
        }
        
    }
        
}
