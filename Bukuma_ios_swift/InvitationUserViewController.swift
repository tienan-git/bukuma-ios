//
//  UserInvitationViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/04.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import LINEActivity
import RMUniversalAlert

open class InvitationUserViewController: BaseTableViewController, InvitationCellDelegate {
    
    fileprivate let headerView: InvitationHeaderView! = InvitationHeaderView()
    
    // ================================================================================
    // MARK: - setting
    override open func registerDataSourceClass() -> AnyClass? {
        return InviteDataSource.self
    }

    // ================================================================================
    // MARK: -init
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func titleOnEmptyView(_ view: EmptyDataView) -> String {
        return ""
    }
    
    override open func bodyOnEmptyView(_ view: EmptyDataView) -> String {
        return ""
    }
    
    override open func placeHolderImageOnEmptyView(_ view: EmptyDataView) -> UIImage? {
        return UIImage(named: "")
    }
    
    // ================================================================================
    // MARK: - viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
         navigationBarView!.backgroundColor = UIColor.clear
        tableView!.showsPullToRefresh = false
        
        tableView!.tableHeaderView = headerView
        tableView!.showsVerticalScrollIndicator = false
        
        emptyDataView?.removeFromSuperview()
        
        self.refreshDataSource()
    }
    
    // ================================================================================
    // MARK: - InvitationCellDelegate delegate
    
    open func invitationCellShareButtonTapped(_ cell: InvitationCell) {
        self.recommentdApp()
    }
    
    open func invitationCellReviewButtonTapped(_ cell: InvitationCell) {
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "レビューしますか?",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["レビューする"]) {[weak self] (alert, buttonIndex) in
                                if buttonIndex == alert.firstOtherButtonIndex {
                                    self?.review()
                                }
        }
    }


    // ================================================================================
    // MARK: - tableViewDataSource delegate

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: UIView = UIView()
        sectionView.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonTableSectionHeight)
        sectionView.backgroundColor = UIColor.clear
        return sectionView
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kCommonTableSectionHeight
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return InvitationCell.cellHeightForObject(nil)
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: InvitationCell?
        var cellIdentifier: String! = ""
        
        cellIdentifier = NSStringFromClass(InvitationCell.self)
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?InvitationCell
        if cell == nil {
            cell = InvitationCell(reuseIdentifier: cellIdentifier, delegate: self)
        }
        
        let invite: Invite? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Invite
        cell?.cellModelObject = invite?.total as AnyObject?
        
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        self.copyCode()
    }
    
    fileprivate func copyCode() {
        if Me.sharedMe.isRegisterd == false {
            return
        }
        
        if Me.sharedMe.invitationCode == nil {
            return
        }

        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "招待コードをコピーしますか?",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: nil,
                              otherButtonTitles: ["コピー"]) {[weak self] (al, index) in
                                DispatchQueue.main.async {
                                    if index == al.firstOtherButtonIndex {
                                        let pb: UIPasteboard? = UIPasteboard.general
                                        pb?.setValue(Me.sharedMe.invitationCode!, forPasteboardType: "public.utf8-plain-text")
                                        self?.simpleAlert(nil, message: "コピーしました！！", cancelTitle: "OK", completion: nil)
                                    }
                                }

        }
    }

    fileprivate func recommentdApp() {
        let activityItems: [String] = ["ブクマ!の招待コード[\(Me.sharedMe.invitationCode ?? "")]\n入力で、今なら\(ExternalServiceManager.invitationPoint)ポイントプレゼント!!\nブクマ！なら中古本を10秒で出品できるよ！\n#ブクマ！" + kShareLink]
        let applicationActivities: [UIActivity] = [LINEActivity()]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    fileprivate func review() {
        UIApplication.shared.openURL(URL(string: kAppStoreURL)!)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.75 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute:  {
            SVProgressHUD.showSuccess(withStatus: "レビューありがとうございました")
        })
    }
}
