//
//  NewsViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/04.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class NewsViewController: BaseTableViewController {

    open override func registerDataSourceClass() -> AnyClass? {
        return NewsDataSource.self
    }
    
    open override func registerCellClass() -> AnyClass? {
        return NewsCell.self
    }
    
    override open func footerHeight() -> CGFloat {
        return 66.0
    }
    
    override open func scrollIndicatorInsetBottom() ->CGFloat {
        return 0
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return "お知らせはまだありません"
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return "運営からのお知らせがここに表示されます"
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "img_ph_00")
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "お知らせ"
        self.title = "お知らせ"
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (dataSource?.firstData() as? Announcement)?.readAnnouncement(nil)
        self.reloadTableView()
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let object: Announcement? = dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Announcement
        
        if object?.contentUrl != nil {
            let controller: BaseWebViewController = BaseWebViewController(url: object!.contentUrl!)
            controller.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
