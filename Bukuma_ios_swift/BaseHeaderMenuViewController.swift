//
//  BaseHeaderTabViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class BaseHeaderMenuViewController: BaseTableViewController, SegmentedButtonsViewDelegate {
    
    var BaseHeaderMenuViewControllerScrollViewTag = 1000
    var lastScrollY: CGFloat = 0
    var currentPageIndex: Int = 0
    var sv: UIScrollView?
    var headerMenuView: SegmentedButtonsView?
    var leftMenuTitle: String? {
        return nil
    }
    var rightMenuTitle: String? {
        return nil
    }
    
    override open func pullToRefreshInsetTop() -> CGFloat {
        return super.pullToRefreshInsetTop() + SegmentedButtonsView.headerMenuHeight()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        sv = UIScrollView(frame: UIScreen.main.bounds)
        sv?.delegate = self
        sv?.bounces = false
        sv?.isPagingEnabled = true
        sv?.scrollsToTop = false
        sv?.tag = BaseHeaderMenuViewControllerScrollViewTag
        sv?.contentSizeWidth = kCommonDeviceWidth * 2
        self.view.insertSubview(sv!, belowSubview: navigationBarView!)
        
        headerMenuView = SegmentedButtonsView(delegate: self, leftTitle: leftMenuTitle!, rightTitle: rightMenuTitle!)
        headerMenuView?.y = navigationBarView!.bottom
        headerMenuView?.moveSelectIndexViewWithSelectType(.left)
        self.view.insertSubview(headerMenuView!, belowSubview: navigationBarView!)

    }
    
    override open func completeRequest() {
        super.completeRequest()
        lastScrollY = tableView!.contentOffsetY
    }
    
    open func segmentedButtonsViewdidSelectHeaderMenuType(_ type: SegmentedButtonType) {
        currentPageIndex = type.rawValue
        var frame: CGRect = sv!.frame
        frame.origin.x = frame.size.width * currentPageIndex.cgfloat()
        frame.origin.y = 0
        self.updateInterfaceWhenPageChanged()
        UIView.animate(withDuration:0.25, animations: { 
            self.sv?.contentOffsetX = frame.origin.x
            }) { (finish) in
                self.reloadTableView()
        }
    }
    
    open func updateInterfaceWhenPageChanged() {}
    
    static var shouldReload: Bool = false
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {

        self.scrollButtonsHeaderMenu(scrollView)
        if scrollView.tag != BaseHeaderMenuViewControllerScrollViewTag {
            return
        }
        
        let offset: CGPoint = scrollView.contentOffset
        let page: Int = (offset.x.int() + kCommonDeviceWidth.int() / 2) / kCommonDeviceWidth.int()
        if currentPageIndex != page {
            currentPageIndex = page
            headerMenuView?.moveSelectIndexViewWithSelectType(SegmentedButtonType(rawValue: currentPageIndex)!)
            self.updateInterfaceWhenPageChanged()
            type(of: self).shouldReload = true
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if type(of: self).shouldReload == true {
            
            activeTableViewtag = tableView?.tag
            dataSource?.update()
            tableView?.reloadData()
            
            if dataSource != nil && (dataSource?.count() == 0 || dataSource?.isFinishFirstRefresh == false) {
                self.refreshDataSource()
            }
            type(of: self).shouldReload = false
        }
    }
    
    func scrollButtonsHeaderMenu(_ scrollView: UIScrollView) {
        let headerView: UIView? = headerMenuView
        
        _ = headerView.map { (headerView) in
            
            let gap: CGFloat = lastScrollY - scrollView.contentOffsetY
            lastScrollY = scrollView.contentOffsetY
            
            if scrollView.contentOffsetY <= -(NavigationHeightCalculator.navigationHeight() + headerView.height) || scrollView.tag == BaseHeaderMenuViewControllerScrollViewTag  {
                headerView.top = navigationBarView!.bottom
                return
            }
            
            if headerView.top + gap <= NavigationHeightCalculator.navigationHeight() {
                headerView.top += gap
                return
            }
            
            if headerView.top + gap > NavigationHeightCalculator.navigationHeight() {
                headerView.top = gap
            }
        }
    }
}
