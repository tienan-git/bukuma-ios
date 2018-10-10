//
//  ChatTransactionListViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


public protocol ChatTransactionListViewControllerDelegate {
    func chatTransactionListViewControllerMensionTapped(_ viewController: ChatTransactionListViewController, merchandise: Merchandise?)
}

open class ChatTransactionListViewController: BaseTableViewController {
    
    var opponent: User?
    var delegate: ChatTransactionListViewControllerDelegate?
    
    override open func registerDataSourceClass() -> AnyClass? {
        return ChatMensionDataSource.self
    }
    
    override open func registerCellClass() -> AnyClass? {
        return ChatTransactionCell.self
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "まだこのユーザーのアイテムはありません"
    }
    
    override open func pullToRefreshInsetTop() -> CGFloat {
        return NavigationHeightCalculator.navigationHeight() + 50.0
    }
    
    // ================================================================================
    // MARK: init
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(opponent: User?, delegate: ChatTransactionListViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.opponent = opponent
        self.delegate = delegate
        (self.dataSource as? ChatMensionDataSource)?.user = opponent
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshDataSource()
        let segmentedControlBackgroundView: UIView = UIView()
        segmentedControlBackgroundView.frame = CGRect(x: 0,
                                                      y: NavigationHeightCalculator.navigationHeight(),
                                                      width: kCommonDeviceWidth,
                                                      height: 50.0)
        segmentedControlBackgroundView.backgroundColor = UIColor.white
        segmentedControlBackgroundView.clipsToBounds = true
        self.view.addSubview(segmentedControlBackgroundView)
        
        let borderView: UIView = UIView()
        borderView.frame = CGRect(x: 0, y: segmentedControlBackgroundView.height - 0.5, width: segmentedControlBackgroundView.width, height: 0.5)
        borderView.backgroundColor = kBorderColor
        segmentedControlBackgroundView.addSubview(borderView)
        
        let items = ["相手のアイテム","自分のアイテム"]
        let segmentControlFont = UIFont.systemFont(ofSize: 14)
        
        let segmentControl: UISegmentedControl = UISegmentedControl(items: items)
        segmentControl.y = (segmentedControlBackgroundView.height - segmentControl.height) / 2
        segmentControl.clipsToBounds = true
        segmentControl.layer.cornerRadius = 4.0
        let leftWidth: CGFloat = items[0].getTextWidthWithFont(segmentControlFont, viewHeight: segmentControl.height) + 20.0
        let rightWidth: CGFloat = items[1].getTextWidthWithFont(segmentControlFont, viewHeight: segmentControl.height) + 20.0
        segmentControl.setWidth(leftWidth, forSegmentAt: 0)
        segmentControl.setWidth(rightWidth, forSegmentAt: 1)
        segmentControl.width = leftWidth + rightWidth + 1.0 * 2
        segmentControl.x = (segmentedControlBackgroundView.width - segmentControl.width) / 2

        segmentControl.selectedSegmentIndex = 0
        segmentControl.setTitleTextAttributes([NSFontAttributeName: segmentControlFont, NSForegroundColorAttributeName: kBlackColor54], for: UIControlState.normal)
        segmentControl.setTitleTextAttributes([NSFontAttributeName: segmentControlFont, NSForegroundColorAttributeName: UIColor.white], for: UIControlState.selected)
        segmentControl.setTitleTextAttributes([NSFontAttributeName: segmentControlFont, NSForegroundColorAttributeName: UIColor.white], for: UIControlState.disabled)
        
        segmentControl.setBackgroundImage(UIImage.imageWithColor(UIColor.white, size: CGSize(width: leftWidth, height: segmentControl.height)), for: UIControlState.highlighted, barMetrics: .default)
        segmentControl.setBackgroundImage(UIImage.imageWithColor(kTintGreenColor, size: CGSize(width: leftWidth, height: segmentControl.height)), for: UIControlState.disabled, barMetrics: .default)
        
        segmentControl.addTarget(self, action: #selector(self.segmentControlValueChanged(_:)), for: .valueChanged)
        segmentedControlBackgroundView.addSubview(segmentControl)
        
    }
    
    func segmentControlValueChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            (self.dataSource as? ChatMensionDataSource)?.user = opponent
            (self.dataSource as? ChatMensionDataSource)?.changeDataSource(opponent?.identifier ?? "")
            self.reloadTableView()
            emptyDataView?.isHidden = (self.dataSource?.count() ?? 0) > 0
            return
        }
        
        (self.dataSource as? ChatMensionDataSource)?.user = Me.sharedMe
        (self.dataSource as? ChatMensionDataSource)?.changeDataSource(Me.sharedMe.identifier ?? "")
        self.reloadTableView()
        emptyDataView?.isHidden = (self.dataSource?.count() ?? 0) > 0
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let merchandise: Merchandise? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Merchandise
        self.delegate?.chatTransactionListViewControllerMensionTapped(self, merchandise: merchandise)
        self.dismiss(animated: true, completion: nil)
    }
}
