//
//  AAMFeedbackTopicsViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

public protocol AAMFeedbackTopicsViewControllerDelegaete: NSObjectProtocol {
    func feedbackTopicsViewController(_ feedbackTopicsViewController: AAMFeedbackTopicsViewController, didSelectTopicAtIndex: Int)
}

open class AAMFeedbackTopicsViewController: BaseTableViewController {
    var isSelectedIndex: Int?
    var topics: [String]?
    weak var delegate: AAMFeedbackTopicsViewControllerDelegaete?
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "トピック"
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        tableView?.showsPullToRefresh = false
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCellselection()
    }
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if delegate != nil {
            return topics?.count ?? 0
        }
        return 1
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "AAMFeedbackTopicsViewControllerCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            UIFont.boldSystemFont(ofSize: 12)
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell?.selectionStyle = .none
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 13)
            cell?.textLabel?.textColor = kBlackColor87
            let height: CGFloat = 54.0
            let bottomLineView: UIView = UIView(frame: CGRect(x: 12.0, y: height - 0.5, width: kCommonDeviceWidth - 12.0, height: 0.5))
            bottomLineView.backgroundColor = kBorderColor
            cell?.contentView.addSubview(bottomLineView)
        }
        cell?.textLabel?.text = topics?[indexPath.row] ?? ""
        
        return cell ?? UITableViewCell()
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        isSelectedIndex = (indexPath as IndexPath).row
        self.updateCellselection()
        
        self.delegate?.feedbackTopicsViewController(self, didSelectTopicAtIndex: (indexPath as IndexPath).row)
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func updateCellselection() {
        
        let cells = tableView?.visibleCells
        
        if cells == nil {
            return
        }
        let n = cells!.count
        
        if n < 2  {
            return
        }
        for i in 0...n - 1 {
            let cell: UITableViewCell = cells![i]
            cell.accessoryType = .none
        }
        
        let path = IndexPath(row: isSelectedIndex ?? 0, section: 0)
        
        let cell: UITableViewCell? = tableView?.cellForRow(at: path)
        cell?.accessoryType = .checkmark
        cell?.setSelected(false, animated: true)
    }
}
