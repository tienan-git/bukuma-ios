//
//  BaseSearchTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/04/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class BaseSearchTableViewController: BaseTableViewController, UISearchBarDelegate, BukumaSearchBarAdjusterProtocol {
    
    var serchBarTextField: UITextField?
    var serchBar: BukumaSearchBar?
    var searchText: String?
    var isSearching: Bool = false
    var tapGesture: UITapGestureRecognizer?
    var cancelButton: BarButtonItem?
    
    deinit {
        serchBar = nil
        
        DBLog("---------------- deinit BaseSearchTableViewController --------------------")
        
    }
    
    override var shouldShowProgressHUDWhenDataSourceRefresh: Bool {
        get {
            return false
        }
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "本が見つかりません"
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return "入力したタイトルに誤りがないかご確認の上再度検索してください"
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "img_ph_04")
    }

    override open func pullToRefreshInsetTop() -> CGFloat {
        return (BukumaSearchBar.searchBarHeight + kCommonStatusBarHeight)
    }

    // ================================================================================
    // MARK: viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.showsPullToRefresh = false

        serchBar = BukumaSearchBar(frame: CGRect(x: -30.0, y: 0, width: kCommonDeviceWidth - 60, height: BukumaSearchBar.searchBarHeight))
        serchBar?.delegate = self

        serchBarTextField = serchBar?.textField

        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapView(_:)))
        serchBar?.addGestureRecognizer(tapGesture!)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.adjustPosition(for: self.navigationController?.navigationBar)
        self.adjustHeight(for: self.navigationBarView)
        self.addItem(as: self.serchBar, on: self.navigationItem)
    }

    override open func viewWillDisappear(_ animated: Bool) {
        self.resetPosition(for: self.navigationController?.navigationBar)
        self.addItem(as: nil, on: self.navigationItem)

        super.viewWillDisappear(animated)
    }
    
    func tapView(_ sender: UITapGestureRecognizer) {
        if serchBar?.isFirstResponder == true {
            serchBar?.resignFirstResponder()
            self.searchBarDidTapped(true)
            return
        }
        serchBar?.becomeFirstResponder()
        self.searchBarDidTapped(false)
    }
    
    func searchBarDidTapped(_ isResignFirstResponder: Bool) {}
    
    // ================================================================================
    // MARK: - UISearchBarDelegate
    open func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        serchBar?.setShowsCancelButton(true, animated: true)
        return true
    }
    
    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        isSearching = true
    }
    
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
            serchBar?.setShowsCancelButton(false, animated: true)
            return
        }
        searchBar.becomeFirstResponder()
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        serchBar?.setShowsCancelButton(false, animated: true)
        serchBar?.resignFirstResponder()
        isSearching = false
    }
    
    func searchBarCancelButtonTapped(_ sender: UIButton) {
        serchBar?.setShowsCancelButton(false, animated: true)
        serchBar?.resignFirstResponder()
        isSearching = false
    }
    
    open func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}
