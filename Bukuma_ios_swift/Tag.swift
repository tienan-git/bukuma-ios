//
//  Tag.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/28/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftyJSON

class Tag: BaseModelObject {
    var id: Int!
    var name: String!
    var created: Date?
    var updated: Date?
    var numberOfBooks: Int = 0
    var numberOfVotes: Int = 0
    var isVoted: Bool = false

    var displayName: String {
        get {
            return "#" + self.name
        }
    }

    static func get1stTags(forBookId bookId: Int, withAmount amount: Int, completion: @escaping (_ tags: [Tag]?, _ error: Error?) -> Void) {
        let parameters = ["page": 1, "number": amount]
        self.getTags(forBookId: bookId, withParameters: parameters, completion: completion)
    }

    static func getAllTags(forBookId bookId: Int, completion: @escaping (_ tags: [Tag]?, _ error: Error?) -> Void) {
        let parameters = ["all": 1]
        self.getTags(forBookId: bookId, withParameters: parameters, completion: completion)
    }

    static func getTags(forBookId bookId: Int, withParameters parameters: [String: Any], completion: @escaping (_ tags: [Tag]?, _ error: Error?) -> Void) {
        let endPoint = String(format: "v1/books/%lld/tags", bookId)
        ApiClient.sharedClient.get(endPoint, parameters: parameters) { (_ json: JSON, _ error: Error?) in
            if error != nil {
                completion(nil, error)
                return
            }
            
            let tags = json["tags"].array?.map({
                Tag(json: $0)
            })
            completion(tags, nil)
        }
    }

    override open func updatePropertyWithJSON(_ json: SwiftyJSON.JSON) {
        DBLog(json)

        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.created = json["created_at"].date
        self.updated = json["updated_at"].date
        self.numberOfBooks = json["books_count"].intValue
        self.numberOfVotes = json["votes_count"].intValue
        self.isVoted = json["is_voted"].boolValue
    }

    func setLikes(forBookId bookId: Int, completion: ((_ error: Error?) -> Void)?) {
        let endPoint = self.isVoted ?
            String(format: "v1/books/%lld/tags/%lld/vote", bookId, self.id) :
            String(format: "v1/books/%lld/tags/%lld/unvote", bookId, self.id)
        ApiClient.sharedClient.POST(endPoint, parameters: nil) { (_ response: [String: Any]?, _ error: Error?) in
            guard error == nil else {
                completion?(error)
                return
            }
            completion?(nil)
        }
    }

    func getBooks(_ completion: @escaping (_ books: [Book]?, _ error: Error?) -> Void) {
        let endPoint = String(format: "v1/books/tags/%lld", self.id)
        let parameters = ["page": 1, "number": Int32.max] // 全件取得（サーバー側 Int は 32bit）
        ApiClient.sharedClient.GET(endPoint, parameters: parameters) { (_ response: [String: Any]?, _ error: Error?) in
            DBLog(response)

            if error != nil {
                completion(nil, error)
                return
            }
            guard let booksArray = response?["books"] as? [[String: AnyObject]] else {
                completion(nil, nil)
                return
            }

            let books = booksArray.map({ (dic) in
                Book(dictionary: dic)
            })
            DBLog(books)
            completion(books, nil)
        }
    }

    static func addTags(forBookId bookId: Int, tagStringsToAdd tagStrings: [String], completion: ((_ error: Error?) -> Void)?) {
        var tagCount = 0
        var lastErr: Error?

        let endPoint = String(format: "v1/books/%lld/tags/new", bookId)
        for tagString in tagStrings {
            let parameters: [String: Any] = ["name": tagString]
            ApiClient.sharedClient.POST(endPoint, parameters: parameters) { (_ response: [String: Any]?, _ error: Error?) in
                DBLog(response)

                tagCount += 1

                if error != nil {
                    lastErr = error
                }
                if tagCount == tagStrings.count {
                    completion?(lastErr)
                }
            }
        }
    }
}
