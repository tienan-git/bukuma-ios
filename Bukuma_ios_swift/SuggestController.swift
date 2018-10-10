//
//  SuggestController.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/8/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import RMUniversalAlert

enum SuggestControllerCellType: Int {
    case searchHistoryContents
    case deleteHistoryCacshe
    case suggestWord
    case unexpect
}

protocol SuggestControllerProtocol: class {
    var viewController: UIViewController! { get set }
    var searchBar: BukumaSearchBar! { get set }
    var tableView: BaseTableView! { get set }
    var blarView: UIView! { get set }
    var dataSource: SearchBookDataSource! { get set }
    var isSearching: Bool { get set }

    func showSuggests(withKeyword keyword: String)
    func hideSuggests()

    func keyword(fromInputText inputText: String, withTextPosition textPosition: NSRange)-> String
    func chaseTyping(withInputText inputText: String, withTextPosition textPosition: NSRange)

    func showSuggetsIfNeeded(withKeyword keyword: String?)
    func showSuggetsWhenAppear(withKeyword keyword: String?)

    func typeOfCell(for indexPath: IndexPath)-> SuggestControllerCellType
    func numberOfCells(in section: Int)-> Int
    var isShowSuggests: Bool { get }

    func showTableView()
    func closeTableView()
    func showTableViewSimple()
    func closeTableViewSimple()

    func showSearchResult(with searchWord: String)
    func showDeleteHistoryAlert()
}

extension SuggestControllerProtocol {
    func showSuggests(withKeyword keyword: String) {
        self.dataSource.getSuggestWords(withKeyword: keyword, completion: nil)
    }

    func hideSuggests() {
        self.dataSource.clearSuggestWords()
    }

    func keyword(fromInputText inputText: String, withTextPosition textPosition: NSRange)-> String {
        var keyword = ""
        if inputText.length > 0 {
            keyword = (self.searchBar.text ?? "") + inputText
        } else {
            keyword = self.searchBar.text ?? ""
            let removeRange = keyword.index(keyword.startIndex, offsetBy: textPosition.location)..<keyword.index(keyword.startIndex, offsetBy: textPosition.location + textPosition.length)
            keyword.removeSubrange(removeRange)
        }
        return keyword
    }

    func chaseTyping(withInputText inputText: String, withTextPosition textPosition: NSRange) {
        let keyword = self.keyword(fromInputText: inputText, withTextPosition: textPosition)

        self.isSearching = keyword.length > 0

        if keyword.length > 0 {
            self.showSuggests(withKeyword: keyword)
        } else {
            self.hideSuggests()
        }
    }

    func showSuggetsIfNeeded(withKeyword keyword: String?) {
        if let keyword = keyword {
            if keyword.length > 0 {
                self.isSearching = true
                self.showSuggests(withKeyword: keyword)
            }
        }
    }

    func showSuggetsWhenAppear(withKeyword keyword: String?) {
        if let keyword = keyword {
            if keyword.length > 0 {
                self.showSuggests(withKeyword: keyword)
            }
        }
    }
}

extension SuggestControllerProtocol {
    func typeOfCell(for indexPath: IndexPath)-> SuggestControllerCellType {
        switch indexPath.section {
        case 0: return self.isShowSuggests ? SuggestControllerCellType.suggestWord : SuggestControllerCellType.searchHistoryContents
        case 1: return self.isShowSuggests == false && SearchHistoryCache.shared.count() > 0 ? SuggestControllerCellType.deleteHistoryCacshe : SuggestControllerCellType.unexpect
        default: return SuggestControllerCellType.unexpect
        }
    }

    func numberOfCells(in section: Int)-> Int {
        switch section {
        case 0: return self.isShowSuggests ? self.dataSource.count()! : SearchHistoryCache.shared.count()
        case 1: return self.isShowSuggests ? 0 : SearchHistoryCache.shared.count() > 0 ? 1 : 0
        default: return 0
        }
    }

    var isShowSuggests: Bool { get {
        return self.isSearching && (self.dataSource.count() ?? 0) > 0
        }}
}

extension SuggestControllerProtocol {
    func showTableView() {
        self.showTableViewSimple()
    }

    func closeTableView() {
        self.closeTableViewSimple()
    }

    func showTableViewSimple() {
        self.blarView.alpha = 0.0
        self.blarView.isHidden = false
        self.blarView.isUserInteractionEnabled = true

        self.tableView.isHidden = false
        self.tableView.isUserInteractionEnabled = true
        self.tableView.reloadData()

        UIView.animate(withDuration: 0.25, animations: { [weak self] () in
            self?.blarView.alpha = 1.0
            self?.tableView.frame.origin.y = 0
        }, completion: { (isFinish: Bool) in
        })
    }

    func closeTableViewSimple() {
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] () in
            self?.blarView.alpha = 0.0
            self?.tableView.frame.origin.y = -(self?.tableView.frame.size.height ?? 1000)
        }, completion: { [weak self] (isFinish: Bool) in
            self?.tableView.isHidden = true
            self?.tableView.isUserInteractionEnabled = false

            self?.blarView.isHidden = true
            self?.blarView.isUserInteractionEnabled = false
        })
    }

    func showDeleteHistoryAlert() {
        RMUniversalAlert.show(in: self.viewController,
                              withTitle: nil,
                              message: "検索履歴を消しますか?",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["消去する"]) { [weak self] (aleart, buttonIndex) in
                                if buttonIndex == aleart.firstOtherButtonIndex {
                                    SearchHistoryCache.shared.deleteHistoryCache()
                                    self?.tableView.reloadData()
                                }
        }
    }
}

class SuggestController: NSObject, SuggestControllerProtocol {
    var viewController: UIViewController!
    var searchBar: BukumaSearchBar!
    var tableView: BaseTableView!
    var blarView: UIView!
    var dataSource: SearchBookDataSource!
    var isSearching: Bool = false

    init(withViewController viewController: UIViewController,
         withSearchBar searchBar: BukumaSearchBar,
         withTableView tableView: BaseTableView,
         withDataSource dataSource: SearchBookDataSource,
         withIsSearching isSearching: Bool) {
        super.init()

        self.viewController = viewController
        self.searchBar = searchBar
        self.tableView = tableView
        self.dataSource = dataSource
        self.isSearching = isSearching
        self.makeBlarView()

        self.searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.closeTableView()
    }

    private func makeBlarView() {
        let frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonDeviceHeight)
        self.blarView = UIView(frame: frame)
        self.blarView.backgroundColor = kBackGroundColor
        self.blarView.isHidden = true
        self.tableView.superview?.insertSubview(self.blarView, belowSubview: self.tableView)
    }

    func showSearchResult(with searchWord: String) {
        if self.searchBar.isFirstResponder {
            self.searchBar.resignFirstResponder()
            self.searchBar.setShowsCancelButton(false, animated: true)
        }

        let controller = SearchBookListViewController(text: searchWord)
        controller.view.clipsToBounds = true
        self.viewController.navigationController?.pushViewController(controller, animated: true)
    }
}

extension SuggestController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        self.showTableView()

        self.showSuggetsIfNeeded(withKeyword: searchBar.text)

        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        self.closeTableView()
        
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearching = searchText.length != 0

        if searchText.length > 0 {
            self.showSuggests(withKeyword: searchText)
        } else {
            self.hideSuggests()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchWord = searchBar.text {
            if searchWord.length > 0 {
                self.showSearchResult(with: searchWord)
                SearchHistoryCache.shared.addHistory(searchWord)

                AnaliticsManager.sendAction("search",
                                            actionName: "search_book",
                                            label: searchWord,
                                            value: 1,
                                            dic: ["searchText": searchWord as AnyObject])
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.viewController.navigationController?.popViewController(animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.chaseTyping(withInputText: text, withTextPosition: range)
        return true
    }
}

extension SuggestController: UITableViewDataSource, BaseTableViewCellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfCells(in: section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? SearchTextHistoryCell.cellHeightForObject(nil) : SearchDeleteHistroyCell.cellHeightForObject(nil)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.typeOfCell(for: indexPath) {
        case .searchHistoryContents:
            let cellId = NSStringFromClass(SearchTextHistoryCell.self)
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SearchTextHistoryCell
            if cell == nil {
                cell = SearchTextHistoryCell.init(reuseIdentifier: cellId, delegate: self)
            }
            if 0..<SearchHistoryCache.shared.count() ~= indexPath.row {
                cell?.title = SearchHistoryCache.shared.historyName(indexPath.row)
            }
            return cell!

        case .deleteHistoryCacshe:
            let cellId = NSStringFromClass(SearchDeleteHistroyCell.self)
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SearchDeleteHistroyCell
            if cell == nil {
                cell = SearchDeleteHistroyCell.init(reuseIdentifier: cellId, delegate: self)
            }
            return cell!

        case .suggestWord:
            let cellId = NSStringFromClass(SearchTextHistoryCell.self)
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SearchTextHistoryCell
            if cell == nil {
                cell = SearchTextHistoryCell.init(reuseIdentifier: cellId, delegate: self)
            }
            if let suggestWord = self.dataSource.dataAtIndex(indexPath.row, isAllowUpdate: false) as? String {
                cell?.title = suggestWord
            }
            return cell!

        default:
            return UITableViewCell()
        }
    }
}

extension SuggestController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cellType = self.typeOfCell(for: indexPath)
        switch cellType {
        case .searchHistoryContents, .suggestWord:
            if let cell = tableView.cellForRow(at: indexPath) as? SearchTextHistoryCell {
                if let searchWord = cell.title {
                    if searchWord.length > 0 {
                        self.searchBar.text = searchWord
                        self.showSearchResult(with: searchWord)
                        SearchHistoryCache.shared.addHistory(searchWord)

                        AnaliticsManager.sendAction("search",
                                                    actionName: cellType == .searchHistoryContents ? "search_book_by_history" : "search_book_by_suggest",
                                                    label: searchWord,
                                                    value: 1,
                                                    dic: ["searchText": searchWord as AnyObject])
                    }
                }
            }
            break
        case .deleteHistoryCacshe:
            self.showDeleteHistoryAlert()
            break
        default:
            break
        }
    }
}
