//
//  Book.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SwiftyJSON

public enum PriceStringType: Int {
    case yenMark
    case yenKanji
}

public enum SearchOrderType {
    case keyword
    case isbn
}

open class SearchOrder: NSObject {
    var id: String?
    var keyword: String?
    var orderType: SearchOrderType?
    var isFinish: Bool?
    
    public init(dic: [String: AnyObject]?) {
        id = dic?["id"].map{String(describing: $0)}
        keyword = dic?["keyword"].map{String(describing: $0)}
        orderType = dic?["order_type"].map{String(describing: $0)} == "isbn" ? .isbn : .keyword
        isFinish = dic?["finished"] as? Bool
    }
}

public struct PressRelation {
    var id: String?
    var name: String?
    var nameEn: String?
    
    public init() {}
    public init(dic: [String: AnyObject]?) {
        id = dic?["id"].map{String(describing: $0)}
        name = dic?["name"].map{String(describing: $0)}
        nameEn = dic?["name_en"].map{String(describing: $0)}
    }
}

public struct Publisher {
    var id: String?
    var name: String?
    var nameEn: String?
    
    public init() {}
    public init(dic: [String: AnyObject]?) {
        id = dic?["id"].map{String(describing: $0)}
        name = dic?["name"].map{String(describing: $0)}
        nameEn = dic?["name_en"].map{String(describing: $0)}
    }
}

public struct Author {
    var id: String?
    var name: String?
    var nameEn: String?
    
    public init() {}
    public init(dic: [String: AnyObject]?) {
        id = dic?["id"].map{String(describing: $0)}
        name = dic?["name"].map{String(describing: $0)}
        nameEn = dic?["name_en"].map{String(describing: $0)}
    }
}

public struct CoverImage {
    var url: URL?
    
    public init() {}
    public init(dic: [String: AnyObject]?) {
        dic?["cover_image"]?["url"]?.map{url = URL(string:String(describing: $0))}
    }
}

let BookLikeCountChangeNotification: String = "BookLikeCountChangeNotification"

/**
Book Object
 
 
 */


open class Book: BaseModelObject {
    var identifier: String? /// id
    var title: String? ///  タイトル
    var fullTitle: String? /// これはpropertyとして持ってるだけで使ってない。RakutenがfullTitleを持っているが空欄の時の方が多い
    var isbn: String? /// isbn
    var isbn10: String? /// isbn10
    var publisher: Publisher? = Publisher() /// Publisherの情報
    var pressRelation: PressRelation? /// PressRelationの情報だが使ってない
    var author: Author? = Author() /// Authorの情報
    var amazonLink: URL? /// AmazonのLinkの情報
    var rakutenLink: URL? /// RakutenのLinkの情報
    var summary: String? /// 要約
    var liked: Bool? ///自分がこの本をLikeしているか否か。
    var numOfLike: Int?///Likeの数。
    var isSeries: Bool? /// まとめ売りかどうか
    var seriesTitle: String? /// まとめ売りタイトル
    var parentId: String? ///親本のID まとめ売りを作った場合本がcopyされる仕組み
    var lowestPrice: Int? /// 最安値
    var coverImage: CoverImage? ///本のimage
    var amazonPrice: Int? /// storeの最安値。今はAmazonは使ってない。Rakutenの最安値
    var listPrice:  String? /// 新品価格
    var categoryRoodId: String? ///本のカテゴリの親ID
    var categoryId: String? ///本のカテゴリID
    var categoryName: String?///本のカテゴリ名
    var imageWidth: Double? ///本のimageのWidth
    var imageHeight: Double?///本のimageのHeight
    var lowestMerchandise: Merchandise? ///最安値Merchandise
    var lastLowestMerchandiseId: String? ///最後に出品されたMechandiseのID
    var publishedAt: Date? ///出版び
    var lastFetched: String? ///どこからgetしたか
    var merchandisesCount: String? ///本が持っているMerchandiseの数
    var seriesNumber: String? ///まとめ売りの説明と同じ文章が帰ってくる

    var imageSize: CGSize? {
        guard let width = self.imageWidth else {
            return nil
        }
        guard let height = self.imageHeight else {
            return nil
        }
        return CGSize(width: width, height: height)
    }

    override open func updatePropertyWithAttributes(_ attributes: [String : AnyObject]?) {
        identifier = attributes?["id"].map{String(describing: $0)}
        let titleText: String? = attributes?["title"].map{String(describing: $0)}
        title = titleText?.replacingOccurrences(of: "\r\n", with: "").trimmingCharacters(in: CharacterSet.whitespaces).uppercased()
        
        fullTitle = attributes?["full_title"].map{String(describing: $0)}
        attributes?["amazon_link"].map{ amazonLink = URL(string:String(describing: $0)) }
        attributes?["rakuten_link"].map{ rakutenLink = URL(string: String(describing: $0)) }
        
        isbn = attributes?["isbn"].map{String(describing: $0)}
        isbn10 = attributes?["isbn_10"].map{String(describing: $0)}
        numOfLike = attributes?["cached_votes_total"] as? Int
        
        publisher = Publisher(dic: attributes?["publisher"] as? [String: AnyObject])
        author = Author(dic: attributes?["author"] as? [String: AnyObject])
        pressRelation = PressRelation(dic: attributes?["press_relation"] as? [String: AnyObject])
        
        lowestPrice = (attributes?["lowest_price"]) as? Int
        isSeries = !Utility.isEmpty(attributes?["series_no"])
        seriesNumber = attributes?["series_no"].map{ String(describing: $0) }

        parentId = attributes?["parent_id"].map{String(describing: $0)}
        liked = attributes?["is_liked"] as? Bool
        lowestMerchandise = Merchandise.createLowestMerchandise(attributes?["lowest_price_merchandise"] as? [String: AnyObject])
        seriesTitle = lowestMerchandise?.seriesDespription
        
        coverImage = CoverImage(dic: attributes?["cover_image"] as? [String: AnyObject])
        
        amazonPrice = attributes?["store_lowest_price"] as? Int
        listPrice = attributes?["store_price"].map{ String(describing: $0) }
        
        categoryRoodId = (attributes?["category"] as? [String: AnyObject])?["id"].map{String(describing: $0)}
        categoryName = (attributes?["category"] as? [String: AnyObject])?["name"].map{String(describing: $0)}
        categoryId = (attributes?["id"] as? [String: AnyObject])?["id"].map{String(describing: $0)}
        
        attributes?["image_width"].map {String(describing: $0)}.map { imageWidth = Double($0) }
        attributes?["image_height"].map {String(describing: $0)}.map { imageHeight = Double($0) }
        
        lastLowestMerchandiseId = attributes?["last_merchandise_id"].map {String(describing: $0)}
        
        lastFetched = attributes?["last_fetch_via"].map{String(describing: $0)}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        
        publishedAt = self.publishedAt(lastFetched, dateString: attributes?["published_at"].map {String(describing: $0)})
        
        summary = attributes?["summary"].map{String(describing: $0)}
        
        merchandisesCount = attributes?["merchandises_count"].map{String(describing: $0)}
        
    }
    
    open class func book(_ attributes: [String: AnyObject]?, update: Bool) ->Book? {
        let identifier: String? = attributes?["id"].map{ String(describing: $0) }
        if identifier?.isEmpty == true || identifier == nil {
            return nil
        }
        
        var book: Book? = BookStore.shared.storedBook(identifier ?? "-1")
        if book == nil {
            book = Book(dictionary: attributes)
            BookStore.shared.storeBook(book ?? Book())
        } else {
            if update == true {
                book?.updatePropertyWithAttributes(attributes)
            }
        }
        return book
    }
    
    open class func generatedBookFromStore(_ attributes: [String: AnyObject]?) ->Book? {
        return self.book(attributes, update: true)
    }
    
    open func lowestPriceString(_ type: PriceStringType) ->String {
        if self.notListings {
            if UIScreen.is4inchDisplay() {
                return "出品なし"
            }
            return "出品がありません"
        }
        
        if self.soldOut {
            return "売り切れです"
        }

        if type == .yenMark {
            return  "¥\(lowestPrice!.thousandsSeparator())"
        }
        return "\(lowestPrice!.thousandsSeparator())円"
    }

    fileprivate var notListings: Bool {
        get { return Utility.isEmpty(lastLowestMerchandiseId) && lowestMerchandise?.id == nil }
    }

    fileprivate var soldOut: Bool {
        get { return lowestMerchandise?.id == nil || lowestPrice == nil || lowestPrice == -1 }
    }

    fileprivate func publishedAt(_ lastFetched: String?, dateString: String?) ->Date? {
        if Utility.isEmpty(lastFetched) || Utility.isEmpty(dateString) {
            return nil
        }
        
        let dateFormatter = DateFormatter()

        switch lastFetched! {
        case "rakuten":
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            return dateFormatter.date(from: dateString!)
        case "hontojp":
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: dateString!)
        case "amazon":
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: dateString!)
        default:
            return nil
        }
    }
    
    func titleText() ->String {
        if Utility.isEmpty(self.seriesTitle) {
            if self.isSeries == true && !Utility.isEmpty(seriesNumber){
                return seriesNumber!
            }
            return self.title ?? ""
        } else {
            return self.seriesTitle ?? ""
        }
    }
    
    private func removeFirstSpace() {
        if Utility.isEmpty(title) {
            return
        }
       

    }
    
    /**
     timelineで使われている
     */
    open class func getBookInfoFromRootCategoryID(_ page: Int, categoryId: String, completion:@escaping (_ books: [Book]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/books/timeline_category/\(categoryId)",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        if responceObject?["books"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["books"]!).arrayObject!
                                        
                                        if page == 1 {
                                            _  = JSONCache.cache(jsonArray, kind: BookRootCategoryListCacheKey, identifier: categoryId)
                                        }
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let books: [Book] = jsonDic.map({ (dic) in
                                            let book: Book = Book.generatedBookFromStore(dic)!
                                            return book
                                        })
                                        
                                        completion(books, nil)
                                        
                                    } else {
                                       DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    
    ////for search timeline
    ///v1.5からは使われていない
    ///v1/books/timeline_category/id との違いは出品なしの本も帰ってくること
    open class func searchBookInfoFromRootCategoryID(_ page: Int, categoryId: String, completion:@escaping (_ books: [Book]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/books/all_categories/\(categoryId)",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        if responceObject?["books"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["books"]!).arrayObject!
                                        
                                        if page == 1 {
                                           _ = JSONCache.cache(jsonArray, kind: BookSearchCategoryListCacheKey, identifier: categoryId)
                                        }
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let books: [Book] = jsonDic.map({ (dic) in
                                            let book: Book = Book.generatedBookFromStore(dic)!
                                            return book
                                        })
                                        
                                        completion(books, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
     ////for Published Date Range timeline
    ///最近発売の本
    open class func getBooksFromDayRange(_ page: Int, number: Int, day: Int, completion: @escaping (_ books: [Book]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50
        params["day"] = day
        params["category_id"] = "1"
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/books/published_timeline",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        if responceObject?["books"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["books"]!).arrayObject!
                                        
                                        if page == 1 {
                                           _ = JSONCache.cacheArray(jsonArray, key: BookDayRangeListCacheKey)
                                        }
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let books: [Book] = jsonDic.map({ (dic) in
                                            let book: Book = Book.generatedBookFromStore(dic)!
                                            return book
                                        })
                                        
                                        completion(books, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    

    ////for price timeline
    ///300円以下の本
    open class func getBooksFromPriceLimit(_ page: Int, number: Int, price: Int, completion: @escaping (_ books: [Book]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50
        params["price"] = price
        params["category_id"] = "1"
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/books/price_timeline",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        if responceObject?["books"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["books"]!).arrayObject!
                                        
                                        if page == 1 {
                                           _ = JSONCache.cacheArray(jsonArray, key: BookPriceLimitListCacheKey)
                                        }
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let books: [Book] = jsonDic.map({ (dic) in
                                            let book: Book = Book.generatedBookFromStore(dic)!
                                            return book
                                        })
                                        
                                        completion(books, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    ////for bulk timeline
    ///まとめ売りの本
    open class func getBulkBooks(_ page: Int, number: Int, completion: @escaping (_ books: [Book]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50
        params["category_id"] = "1"
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/books/bulk_timeline",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        if responceObject?["books"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["books"]!).arrayObject!
                                        
                                        if page == 1 {
                                            JSONCache.cacheArray(jsonArray, key: BookBulkListCacheKey)
                                        }
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let books: [Book] = jsonDic.map({ (dic) in
                                            let book: Book = Book.generatedBookFromStore(dic)!
                                            return book
                                        })
                                        
                                        completion(books, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }

    ///カテゴリを送ると、そのカテゴリの本が帰ってくる
    open class func getBookInfoFromCategoryID(_ page: Int, categoryId: String, completion:@escaping (_ books: [Book]?, _ error: Error?) ->Void) {
        
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/books/categories/\(categoryId)",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        if responceObject?["books"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["books"]!).arrayObject!
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let books: [Book] = jsonDic.map({ (dic) in
                                            let book: Book = Book.generatedBookFromStore(dic)!
                                            return book
                                        })
                                        
                                        completion(books, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
    ///本のIDを送るとその本の情報が帰ってくる
    open class func getBookInfoFromID(_ bookId: String, completion:@escaping (_ book: Book?, _ error: Error?) ->Void) {
        ApiClient.sharedClient.GET("v1/books/\(bookId)",
                                   parameters: [:]) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        let book: Book? = Book.generatedBookFromStore(responceObject?["book"] as? [String: AnyObject])
                                        completion(book, nil)
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    
     ///本にlikeする
    open func likeBookcompletion(_ completion:@escaping (_ isLiked: Bool,  _ numLike: Int, _ error: Error?) ->Void) {
        if Utility.isEmpty(self.identifier) {
            completion(false, self.numOfLike ?? 0, Error(domain: ErrorDomain, code: 0, userInfo: nil))
            return
        }
        ApiClient.sharedClient.POST("v1/books/\(self.identifier!)/like",
                                    parameters: [:]) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            self.liked = true
                                            self.numOfLike? += 1
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: BookLikeCountChangeNotification), object: self)
                                            completion(self.liked ?? false, self.numOfLike ?? 0,nil)
                                        } else {
                                            DBLog(error)
                                            completion(false, self.numOfLike ?? 0, error)
                                        }
        }
    }
    /// 本へunlikeする
    open func unlikeBookcompletion(_ completion:@escaping (_ isLiked: Bool,  _ numLike: Int,  _ error: Error?) ->Void) {
        if Utility.isEmpty(self.identifier) {
            completion(false, self.numOfLike ?? 0, Error(domain: ErrorDomain, code: 0, userInfo: nil))
            return
        }
        ApiClient.sharedClient.POST("v1/books/\(self.identifier!)/unlike",
                                    parameters: [:]) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            self.liked = false
                                            self.numOfLike? -= 1
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: BookLikeCountChangeNotification), object: self)
                                            completion(self.liked ?? false, self.numOfLike ?? 0,nil)

                                        } else {
                                            DBLog(error)
                                            completion(false, self.numOfLike ?? 0, error)
                                        }
        }
    }
    
    ///likeを呼ぶかunlikeを呼ぶか管理
    open func toggleLikeBook(_ completion:@escaping (_ isLiked: Bool, _ numLike: Int, _ error: Error?) ->Void) {
        if self.liked == true {
            self.unlikeBookcompletion(completion)
            return
        }
        self.likeBookcompletion(completion)
    }

    class func suggestWords(withKeyword keyword: String, completion: @escaping (_ words: [String]?, _ error: Error?)-> Void) {
        let params: [String: Any] = ["keyword": keyword]

        ApiClient.sharedClient.POST("v1/books/suggest", parameters: params) { (response: [String: Any]?, error: Error?) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            guard let jsonWords = response?["words"] else {
                completion(nil, nil)
                return
            }

            let words = SwiftyJSON.JSON(jsonWords).arrayObject as? [String]
            completion(words, nil)
        }
    }
    
    ///text検索もしくわBarcode scan
    open class func searchBook(_ key: String?, type: SearchOrderType?,page: Int?, completion:@escaping (_ books:Array<Book>?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50
        params["keyword"] = key
        params["order_type"] = type == .keyword ? "keyword" : "isbn"
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/books/search",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            
                                            if responceObject?["books"] == nil {
                                                completion(nil, nil)
                                                return
                                            }
                                            
                                            let jsonArray = SwiftyJSON.JSON(responceObject!["books"]!).arrayObject!
                                            let jsonDic = jsonArray as! [[String: AnyObject]]
                                            let books: [Book] = jsonDic.map({ (dic) in
                                                let book: Book? = Book(dictionary: dic)
                                                return book!
                                            })

                                            completion(books, nil)
                                            
                                        } else {
                                            DBLog(error)
                                            completion(nil, error)
                                        }
        }
    }
    
    ///もしserverに本はなく、Rakutenへ問い合わせるときsearch_orderを作る
    
    open class func createSearchOrder(_ keyWord: String, type: SearchOrderType, completion:@escaping (_ order: SearchOrder?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["keyword"] = keyWord
        params["order_type"] = type == .keyword ? "keyword" : "isbn"
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/books/search_orders",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            let order: SearchOrder? = SearchOrder(dic: responceObject?["search_order"] as? [String: AnyObject])
                                            DBLog(order?.id)
                                            
                                            completion(order, nil)
                                        } else {
                                            DBLog(error)
                                            completion(nil, error)
                                        }
        }
    }
    
    ///search_orderの状態を確認
    
    open class func getSearchOrderStatusFromId(_ searchOrder: SearchOrder, completion:@escaping (_ order: SearchOrder?, _ error: Error?) ->Void) {
        
        ApiClient.sharedClient.GET("v1/books/search_orders/\(searchOrder.id!)",
                                    parameters: [:]) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            let order: SearchOrder? = SearchOrder(dic: responceObject?["search_order"] as? [String: AnyObject])
                                            completion(order, nil)
                                        } else {
                                            DBLog(error)
                             
                                            completion(nil, error)
                                        }
        }
    }
    
    ///Likeした本リスト
    open class func getLikedBook(_ page: Int, completion: @escaping (_ books: [Book]?, _ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50
        
        DBLog(params)
        
        ApiClient.sharedClient.GET("v1/books/liked_books",
                                   parameters: params) { (responceObject, error) in
                                    if error == nil {
                                        DBLog(responceObject)
                                        
                                        if responceObject?["books"] == nil {
                                            completion(nil, nil)
                                            return
                                        }
                                        
                                        let jsonArray = SwiftyJSON.JSON(responceObject!["books"]!).arrayObject!
                                        
                                        if page == 1 {
                                            JSONCache.cacheArray(jsonArray, key: LikedBookListCacheKey)
                                        }
                                        
                                        let jsonDic = jsonArray as! [[String: AnyObject]]
                                        let books: [Book] = jsonDic.map({ (dic) in
                                            let book: Book? = Book.generatedBookFromStore(dic)
                                            return book!
                                        })
                                        
                                        completion(books, nil)
                                        
                                    } else {
                                        DBLog(error)
                                        completion(nil, error)
                                    }
        }
    }
    ///本を通報
    open func reportBook(_ reason: String?, completion: @escaping (_ error: Error?) ->Void) {
        var params: [String: Any] = [:]
        params["reportable_type"] = "Book"
        params["reportable_id"] = self.idString(identifier)
        params["reason"] = reason
        
        DBLog(params)
        
        ApiClient.sharedClient.POST("v1/reports/create",
                                    parameters: params) { (responceObject, error) in
                                        if error == nil {
                                            DBLog(responceObject)
                                            completion(nil)
                                        } else {
                                            DBLog(error)
                                            completion(error)
                                        }
        }
    }
    
    open class func cachedRootBookList(_ categoryId: String) ->[Book]? {
        
        let cacheList: [Any]? = JSONCache.cachedJSONListWithKind(BookRootCategoryListCacheKey, identifier: categoryId)
        if cacheList == nil {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [Book] = modelDic.map({ (dic) in
            let model = Book.generatedBookFromStore(dic)!
            return model
        })
        return models
    }
    
    open class func cachedPriceBookList() ->[Book]? {
        
        let cacheList: [Any]? = JSONCache.cachedArrayListWithKey(BookPriceLimitListCacheKey)
        if cacheList == nil {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [Book] = modelDic.map({ (dic) in
            let model = Book.generatedBookFromStore(dic)!
            return model
        })
        return models
    }
    
    open class func cachedBulkBookList() ->[Book]? {
        
        let cacheList: [Any]? = JSONCache.cachedArrayListWithKey(BookBulkListCacheKey)
        if cacheList == nil {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [Book] = modelDic.map({ (dic) in
            let model = Book.generatedBookFromStore(dic)!
            return model
        })
        return models
    }
    
    open class func cachedPublishedBookList() ->[Book]? {
        
        let cacheList: [Any]? = JSONCache.cachedArrayListWithKey(BookDayRangeListCacheKey)
        if cacheList == nil {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [Book] = modelDic.map({ (dic) in
            let model = Book.generatedBookFromStore(dic)!
            return model
        })
        return models
    }
    
    open class func cachedSearchBookList(_ categoryId: String) ->[Book]? {
        
        let cacheList: [Any]? = JSONCache.cachedJSONListWithKind(BookSearchCategoryListCacheKey, identifier: categoryId)
        if cacheList == nil {
            return nil
        }
        
        let modelDic = cacheList as! [[String: AnyObject]]
        let models: [Book] = modelDic.map({ (dic) in
            let model = Book.generatedBookFromStore(dic)!
            return model
        })
        return models
    }
    
    open class func cachedLikedBookList() ->[Book]? {
       return self.cachedModelObjects(LikedBookListCacheKey, modelClass: Book.self) as? [Book]
    }
    
    open class func recomendBookList(_ categoryId: String, exceptBook: Book) ->[Book]? {
        let cachedBookList = self.cachedRootBookList(categoryId)
        if cachedBookList == nil {
            return nil
        }
        
        return cachedBookList
    }
    
    /**
     URLでtimelineを取得する
     */
    open class func getBookInfoFromUrl(_ page: Int, url: String, completion: @escaping ([Book]?, String?, Error?) -> Void) {
        var params: [String: Any] = [:]
        params["page"] = page
        params["number"] = 50
        
        DBLog(params)
        
        ApiClient.sharedClient.GET(url,
        parameters: params) { (responceObject, error) in
            if let error = error {
                DBLog(error)
                completion(nil, nil, error)
                return
            }
            
            DBLog(responceObject)
            
            guard let responceBooks = responceObject?["books"] else {
                completion(nil, nil, nil)
                return
            }
            
            let jsonArray = SwiftyJSON.JSON(responceBooks).arrayObject!
            let jsonDic = jsonArray as! [[String: AnyObject]]
            let books = jsonDic.map({
                Book.generatedBookFromStore($0)!
            })
            let title = responceObject?["title"].map { String(describing: $0) }
            
            completion(books, title, nil)
        }
    }
}

// Extension to show discount percent.
extension Book {
    private func discountPercentValue(with userPrice: Int?) -> Int {
        if self.notListings { return 0 }
        if self.soldOut { return 0 }
        guard let listPriceString = self.listPrice else { return 0 }
        guard let listPrice = Double(listPriceString) else { return 0 }
        if listPrice == 0 { return 0 }

        var price: Int!
        if let _ = userPrice {
            price = userPrice!
        } else {
            if let _ = self.lowestPrice {
                price = self.lowestPrice!
            } else {
                return 0
            }
        }

        let discountPercentValue = 100.0 - ((Double(price) / listPrice) * 100.0)
        return Int(discountPercentValue)
    }

    func discountPercentString(with userPrice: Int? = nil) -> String {
        let price = userPrice ?? self.lowestPrice
        let percentOff = UIScreen.is4inchDisplay() ? "%↓" : "%OFF"
        let discountPercentString = String(self.discountPercentValue(with: price)) + percentOff
        return discountPercentString
    }

    func isVisibleDiscountPercent(with userPrice: Int? = nil) -> Bool {
        if self.isSeries! { // まとめ売りは割引率表示対象外
            return false
        }

        let price = userPrice ?? self.lowestPrice
        return self.discountPercentValue(with: price) >= 30
    }
}
