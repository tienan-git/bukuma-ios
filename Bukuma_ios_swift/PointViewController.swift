//
//  PointViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class PointViewController: BaseTableViewController {
    
    fileprivate var sections = [Section]()
    var willExpirePoint: Int = 0
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate enum PointTableViewSectionType: Int {
        case point
    }
    
    fileprivate enum PointTableViewRowType {
        case pointCurrentPoint
        case pointWillLosePoint
        case pointIntroduceFriend
    }
    
    fileprivate struct Section {
        var sectionType: PointTableViewSectionType
        var rowItems: [PointTableViewRowType]
    }
    
    // ================================================================================
    // MARK: setting
    
    override open func footerHeight() -> CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    override func initializeTableViewStruct() {
        sections = [Section(sectionType: .point, rowItems: [.pointCurrentPoint, .pointWillLosePoint, .pointIntroduceFriend])]
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "ポイント"
    }
    
    // ================================================================================
    // MARK: init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.refreshDataSource()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView!.showsPullToRefresh = false
        self.automaticallyAdjustsScrollViewInsets = false
        tableView!.showsVerticalScrollIndicator = false
    
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        User.recalculatePoint { (error) in
            Me.sharedMe.syncronizeMyProfileWithCompletion({ [weak self] (error) in
                DispatchQueue.main.async {
                    self?.tableView?.reloadData()
                    
                }
                })
        }
        self.refreshDataSource()
    }
    
    open override func refreshDataSource() {
        Point.getExpirePoints { (point, error) in
            DispatchQueue.main.async {
                self.willExpirePoint = point?.willExpireBonus ?? 0
                self.tableView?.reloadData()
            }
        }
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return  sections.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowItems.count
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BaseIconTitleTextCell.cellHeightForObject(nil)
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseIconTitleTextCell?
        let cellIdentifier: String! = NSStringFromClass(BaseIconTitleTextCell.self)
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseIconTitleTextCell
        if cell == nil {
            cell = BaseIconTitleTextCell.init(reuseIdentifier: cellIdentifier, delegate: self)
        }
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .pointCurrentPoint:
            cell?.title = "所持ポイント"
            if Me.sharedMe.point != nil {
                cell?.textLabelText = "\(Me.sharedMe.point!.bonusPoint!.thousandsSeparator()) pt"
            }
            cell?.textlabel?.font = UIFont.boldSystemFont(ofSize: 14)
            cell?.selectionStyle = .none
            break
        case .pointWillLosePoint:
            cell?.title = "3か月以内に失効するポイント"
            cell?.textLabelText = "\(willExpirePoint.thousandsSeparator()) pt"
            
            cell?.textlabel?.textColor = kPink01Color
            cell?.textlabel?.font = UIFont.boldSystemFont(ofSize: 14)
            cell?.selectionStyle = .none
            break
        case .pointIntroduceFriend:
            cell?.title = "友達に招待してポイント増やす"
            break
        }
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        var controller: BaseViewController?
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .pointIntroduceFriend:
            controller = InvitationUserViewController()
            break
        default:
            break
        }
        
        if controller != nil {
            controller!.view.clipsToBounds = true
            self.navigationController?.pushViewController(controller!, animated: true)
        }
    }

}
