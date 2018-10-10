//
//  SearchBookTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/04/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class SearchBookFromTitleViewController: BaseSearchTableViewController {
    
    override open func registerDataSourceClass() -> AnyClass? {
        return SearchBookDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return SearchBookTableViewCell.self
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func emptyViewCenterPositionY() -> CGFloat {
        guard let textField = self.serchBarTextField else { return super.emptyViewCenterPositionY() }
        return textField.isFirstResponder ? super.emptyViewCenterPositionY() - 50.0 : super.emptyViewCenterPositionY()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        isNeedKeyboardNotification = true
        tableView!.isFixTableScrollWhenChangeContentsSize = true
        
        emptyDataView?.removeFromSuperview()

        if let tableView = self.tableView,
            let searchBar = self.serchBar,
            let dataSource = self.dataSource as? SearchBookDataSource {
            self.suggestController = SuggestController(withViewController: self,
                                                       withSearchBar: searchBar,
                                                       withTableView: tableView,
                                                       withDataSource: dataSource,
                                                       withIsSearching: self.isSearching)
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // このタイミングで編集状態にしないと、「キャンセル」表示の位置がズレてしまう（原因不明）
        serchBar?.becomeFirstResponder()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (dataSource as? SearchBookDataSource)?.searchText = nil
        
        serchBar?.resignFirstResponder()

        self.suggestController.showSuggetsWhenAppear(withKeyword: self.suggestController.searchBar.text)
    }

    override func keyboardDidShow(_ notification: Foundation.Notification) {
        let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as!NSValue).cgRectValue
        tableView?.viewSize = CGSize(width: kCommonDeviceWidth, height: kCommonDeviceHeight - keyboardFrame.height + 50.0)
    }
    
    override func keyboardDidHide(_ notification: Foundation.Notification) {
        tableView?.viewSize =  CGSize(width: kCommonDeviceWidth, height: kCommonDeviceHeight)
    }

    // MARK: - Suggests

    private var suggestController: SuggestController!
}
