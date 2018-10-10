//
//  AAMFeedbackViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/21.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import MessageUI
import SwiftTips

open class AAMFeedbackViewController: BaseTableViewController,
UITextViewDelegate,
MFMailComposeViewControllerDelegate,
AAMFeedbackTopicsViewControllerDelegaete {
    
    var descriptionText: String?
    var topics: [String]?
    var topicsToSend: [String]?
    var toRecipients: [String]?
    var ccRecipients: [String]?
    var bccRecipients: [String]?
    var isSelectedTopicsIndex: Int = 0
    var mailComposeResultFailedText: String {
        return "メールの送信に失敗しました"
    }
    
    var isFeedbackSent: Bool = false
    var descriptionTextView: PlaceholderTextView?
    let AAMFeedbackViewControllerBlackColor: UIColor = UIColor.colorWithHex(0x333333)
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    open class func isAvailable() ->Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    required public init(topics: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.topics = topics
        self.topicsToSend = topics
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func initializeNavigationLayout() {
        let rightButton = BarButtonItem.barButtonItemWithText("送信",
                                                              isBold: true,
                                                              isLeft: false,
                                                              target: self,
                                                              action: #selector(self.nextDidPress(_:)))
        self.setNavigationBarButton(rightButton, isLeft: false)
    }
    
    override open func generateTableView() -> BaseTableView {
        let tableView = BaseTableView.init(frame: self.view.bounds, style: .grouped)
        tableView.tableViewDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = kBackGroundColor
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = kBorderColor
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.scrollsToTop = true
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = true
        return tableView
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        ExternalServiceManager.syncExternalValues() { [weak self] (error) in
            if error == nil {
                if let message = ExternalServiceManager.csMessage {
                    DispatchQueue.main.async {
                        self?.cautionToUserLabel = (self?.makeCautionToUserLabel(with: message))!
                        self?.tableView?.reloadData()
                    }
                }
            }
        }

        emptyDataView?.removeFromSuperview()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFeedbackSent {
            self.dismiss(animated: true, completion: nil)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 4
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as IndexPath).section == 0 && (indexPath as IndexPath).row == 1 {
            return 88.0
        }
        return 42.0
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 42.0))
        view.backgroundColor = UIColor.clear
        let label: UILabel = UILabel()
        label.frame = CGRect(x: 12.0, y: 0, width: kCommonDeviceWidth, height: 14)
        label.text = section == 1 ? "動作環境" : ""
        label.textColor = kBlackColor87
        label.font = UIFont.systemFont(ofSize: 13)
        label.y = (view.height - label.height) / 2
        view.addSubview(label)
        return view
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42.0
    }

    private let userEnvironmentFooterMarginH: CGFloat = 12
    private let userEnvironmentFooterMarginV: CGFloat = 12
    private let userEnvironmentFooterFont = UIFont.systemFont(ofSize: 15)
    private let userEnvironmentFooterFontColor = kBlackColor87

    private var cautionToUserLabel: UILabel = UILabel()

    private func makeCautionToUserLabel(with cautionText: String)-> UILabel {
        let label = UILabel(frame: CGRect(x: self.userEnvironmentFooterMarginH,
                                          y: self.userEnvironmentFooterMarginV,
                                          width: kCommonDeviceWidth - (self.userEnvironmentFooterMarginH * 2),
                                          height: 0))
        label.font = self.userEnvironmentFooterFont
        label.textColor = self.userEnvironmentFooterFontColor
        label.numberOfLines = 0
        label.text = cautionText
        label.sizeToFit()
        return label
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : self.cautionToUserLabel.frame.size.height
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            let footerView = UIView(frame: CGRect(x: 0, y: 0,
                                                  width: self.cautionToUserLabel.frame.size.width + (self.userEnvironmentFooterMarginH * 2),
                                                  height: self.cautionToUserLabel.frame.size.height + (self.userEnvironmentFooterMarginV * 2)))
            footerView.backgroundColor = UIColor.clear
            footerView.addSubview(self.cautionToUserLabel)
            return footerView
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "AAMFeedbackViewControllerCell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            switch (indexPath as IndexPath).section {
            case 0:
                if (indexPath as IndexPath).row == 0 {
                    cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
                    cell?.accessoryType = .disclosureIndicator
                    break
                }
                cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
                cell?.selectionStyle = .none
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 13)
                cell?.textLabel?.textColor = kBlackColor87
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
                
                descriptionTextView = PlaceholderTextView(frame: CGRect(x: 10.0, y: 0, width: 300.0, height: 88.0))
                descriptionTextView?.backgroundColor = UIColor.clear
                descriptionTextView?.font = UIFont.systemFont(ofSize: 14)
                descriptionTextView?.delegate = self
                descriptionTextView?.clipsToBounds = true
                descriptionTextView?.placeholder = "内容はできるだけ詳細に入力してください"
                descriptionTextView?.text = descriptionText
                descriptionTextView?.textContainerInset = UIEdgeInsets(top: 6.0,
                                                                       left: 4.0,
                                                                       bottom: descriptionTextView!.textContainerInset.bottom,
                                                                       right: 4.0)
                descriptionTextView?.contentInset = UIEdgeInsets(top: 0.0,
                                                                 left: 0.0,
                                                                 bottom: descriptionTextView!.textContainerInset.bottom,
                                                                 right: 0.0)
                cell?.contentView.addSubview(descriptionTextView!)
                break
            case 1:
                cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
                break
            default:
                break
            }
        }
        
        let height: CGFloat = ((indexPath as IndexPath).section == 0 && (indexPath as IndexPath).row == 1) ? 88 : 42
        let bottomLineView: UIView = UIView(frame: CGRect(x: 12.0, y: height - 0.5, width: kCommonDeviceWidth - 12.0, height: 0.5))
        bottomLineView.backgroundColor = kBorderColor
        cell?.contentView.addSubview(bottomLineView)
        
        
        // Configure the cell..
        
        switch (indexPath as IndexPath).section {
        case 0:
            switch (indexPath as IndexPath).row {
            case 0:
                cell?.textLabel?.text = "トピック"
                cell?.detailTextLabel?.text = self.isSelectedTopic()
                break
            default:
                break
            }
        case 1:
            switch (indexPath as IndexPath).row {
            case 0:
                cell?.textLabel?.text = "端末"
                cell?.detailTextLabel?.text = UIDevice.current.modelName
                cell?.selectionStyle = .none
                break
            case 1:
                cell?.textLabel?.text = "iOS"
                cell?.detailTextLabel?.text = UIDevice.current.systemVersion
                cell?.selectionStyle = .none
                break
            case 2:
                cell?.textLabel?.text = "アプリ名"
                cell?.detailTextLabel?.text = self.appName()
                cell?.selectionStyle = .none
                break
            case 3:
                cell?.textLabel?.text = "アプリバージョン"
                cell?.detailTextLabel?.text = self.appVersion()
                cell?.selectionStyle = .none

                break
                
            default:
                break
            }
            break
        default:
            break
        }
                
        return cell ?? UITableViewCell()
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as IndexPath).section == 0 && (indexPath as IndexPath).row == 0 {
            descriptionTextView?.resignFirstResponder()
            
            let controller: AAMFeedbackTopicsViewController = AAMFeedbackTopicsViewController()
            controller.delegate = self
            controller.topics = topics
            controller.isSelectedIndex = isSelectedTopicsIndex
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    open func feedbackTopicsViewController(_ feedbackTopicsViewController: AAMFeedbackTopicsViewController, didSelectTopicAtIndex: Int) {
        isSelectedTopicsIndex = didSelectTopicAtIndex
    }
    
    func cancelDidPress(_ sender: UIButton) {
        self.dismiss()
    }
    
    func nextDidPress(_ sender: UIButton) {
        self.nextDidPress()
    }
    
    open func nextDidPress() {
        descriptionTextView?.resignFirstResponder()
        
        let picker: MFMailComposeViewController = MFMailComposeViewController()
        
        picker.mailComposeDelegate = self
        picker.setToRecipients(toRecipients)
        picker.setCcRecipients(ccRecipients)
        picker.setBccRecipients(bccRecipients)
        picker.setSubject(self.feedbackSubject())
        picker.setMessageBody(self.feedbackBody(), isHTML: false)
        self.present(picker, animated: true, completion: nil)
    }
    
    open func textViewDidChange(_ textView: UITextView) {
        descriptionText = descriptionTextView?.text
        //Magic for updating Cell height
        tableView?.beginUpdates()
        tableView?.endUpdates()
    }
    
    open func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        if result == MFMailComposeResult.sent {
            isFeedbackSent = true
        } else if result == MFMailComposeResult.failed {
            self.simpleAlert(nil, message: mailComposeResultFailedText, cancelTitle: "OK", completion: nil)
        }
        controller.dismiss(animated: true, completion: nil)
    }

    func feedbackSubject() ->String {
        return "\(self.appName()) \(self.isSelectedTopicToSend())"
    }
    
    func feedbackBody() ->String {
        return "\(descriptionTextView?.text ?? "")\n\n\nDevice:\n\(UIDevice.current.platform)\n\niOS:\n\(UIDevice.current.systemVersion)\n\nApp:\n\(self.appName()) \(self.appVersion())\n\nIP Adress:\n\(Network.getIPAddresses())"
    }
    
    fileprivate func isSelectedTopic() ->String? {
        if topics == nil {
            return nil
        }
        return topics![isSelectedTopicsIndex]
    }
    
    fileprivate func isSelectedTopicToSend() ->String {
        if topics == nil  {
            return ""
        }
        return topicsToSend![isSelectedTopicsIndex]
    }
    
    fileprivate func appName() ->String {
        return Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
    }
    
    fileprivate func appVersion() ->String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
}
