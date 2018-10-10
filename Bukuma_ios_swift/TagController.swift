//
//  TagController.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/29/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

protocol TagControllerDelegate {
    func showBooks(withTag tag: Tag)

    func shouldBeginEditTag() -> Bool
    func didBeginEditTag(withTagEditor tagEditor: TagEditorView)
}

protocol TagControllerProtocol: class {
    // 以下 let 扱い
    var haveTagHeader: Int { get }
    var haveTagHeaderAndFooter: Int { get }

    static var numberOfTagsAt1st: Int { get }
    static var numberOfTagsAtOnce: Int { get }

    static var defaultWidth: CGFloat { get }
    static var defaultHeight: CGFloat { get }

    var tagSection: Int { get }
    var topTagRow: Int { get }

    // 条件付き固定値
    var numberOfTags: Int { get }
    var numberOfTagItems: Int { get }

    // DetailPageTableViewController で定義必要
    var tags: [Tag]? { get set }
    var isMoreTags: Bool { get set }
    var isTagEditing: Bool { get set }
    var tagEditor: TagEditorView? { get set }

    func tag(atRow index: Int) -> Tag?
    func get1stTags(completion: @escaping (_ error: Error?) -> Void)
    func getAllTags(completion: @escaping (_ error: Error?) -> Void)
    func makeTagArrayView() -> TagArrayView
}

extension TagControllerProtocol where Self: DetailPageTableViewController {
    var haveTagHeader: Int { get { return 1 } }
    var haveTagHeaderAndFooter: Int { get { return 2 } }

    static var numberOfTagsAt1st: Int { get { return 5 } }
    static var numberOfTagsAtOnce: Int { get { return 20 } }

    static var defaultWidth: CGFloat { get { return kCommonDeviceWidth - (TagArrayView.horizontalMargin + TagArrayView.horizontalMargin) } }
    static var defaultHeight: CGFloat { get { return 66.0 } }

    var tagSection: Int { get { return 1 } }
    var topTagRow: Int { get { return 0 } }

    var numberOfTags: Int {
        get {
            return self.tags?.count ?? 0
        }
    }

    var numberOfTagItems: Int {
        get {
            return self.isMoreTags ? self.numberOfTags + self.haveTagHeaderAndFooter : self.numberOfTags + self.haveTagHeader
        }
    }

    func tag(atRow index: Int) -> Tag? {
        let rowIndex = index - self.haveTagHeader
        let tagsCount = self.tags?.count ?? 0
        return 0 ..< tagsCount ~= rowIndex ? self.tags?[rowIndex] : nil
    }

    func get1stTags(completion: @escaping (_ error: Error?) -> Void) {
        guard let bookId = self.book?.identifier?.int() else {
            completion(Error())
            return
        }

        Tag.get1stTags(forBookId: bookId, withAmount: Self.numberOfTagsAt1st + 1) { [weak self] (_ tags: [Tag]?, _ error: Error?) in
            guard error == nil else {
                completion(error)
                return
            }

            self?.isMoreTags = (tags?.count ?? 0) > Self.numberOfTagsAt1st
            self?.tags = tags
            if self?.isMoreTags == true {
                self?.tags?.removeLast()
            }

            completion(nil)
        }
    }

    func getAllTags(completion: @escaping (_ error: Error?) -> Void) {
        if self.isMoreTags == true {
            guard let bookId = self.book?.identifier?.int() else {
                completion(Error())
                return
            }
            
            Tag.getAllTags(forBookId: bookId) { [weak self] (_ tags: [Tag]?, _ error: Error?) in
                guard error == nil else {
                    completion(error)
                    return
                }
                self?.tags = tags
                self?.isMoreTags = false
                completion(nil)
            }
        }
    }

    func makeTagArrayView() -> TagArrayView {
        let defaultFrame = CGRect(x: 0, y: 0, width: Self.defaultWidth, height: Self.defaultHeight)
        let tagArrayView = TagArrayView(with: defaultFrame, and: self.tags)
        tagArrayView.delegate = self
        return tagArrayView
    }
}
