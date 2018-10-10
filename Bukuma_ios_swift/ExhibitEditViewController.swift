//
//  ExhibitEditViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/21.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import RMUniversalAlert

let ExhibitEditViewControllerEditNotification = "ExhibitEditViewControllerEditNotification"

public enum MerchandiseEditType {
    case normal
    case series
}

open class ExhibitEditViewController: ExhibitTableViewController, ExhibitDeleteCellDelegate {
    
    var type: MerchandiseEditType?
    
    override var isEdit: Bool {
        return true
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "出品を編集する"
    }
    
    required public init(merchandise: Merchandise?, book: Book?, type: MerchandiseEditType) {
        super.init(book: book)
        self.type = type
        isSeries = type == .normal ? false : true
        self.merchandise = merchandise ?? Merchandise()
        Me.sharedMe.defaultShipWay = self.merchandise.shipWay?.string()
        Me.sharedMe.defaultShipIn = self.merchandise.shipInDay?.string()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(book: Book?) {
        fatalError("init(book:) has not been implemented")
    }
    
    override func setUpStruct() {
        if self.isInCommission(withDate: self.merchandise.createdAt) {
            normalSections = [Section(sectionType: .bookInfo,
                                      rowItems: [.bookInfoBookDetail, .bookInfoPrice, .bookInfoCommissionAndBenefits, .bookInfoSeparator,
                                                 .bookInfoStatus, .bookInfoShippingComment, .bookInfoSeparator,
                                                 .bookInfoShippingIn, .bookInfoShippingFrom, .bookInfoShippingWay,
                                                 .bookInfoExhibitButton, .bookInfoOr, .bookInfoDeleteButton])]
            seriesSections = [Section(sectionType: .bookInfo,
                                      rowItems: [.bookInfoBookDetail, .bookInfoBulkTitle, .bookInfoPrice, .bookInfoCommissionAndBenefits, .bookInfoSeparator,
                                                 .bookInfoStatus, .bookInfoBulkPhoto , .bookInfoShippingComment, .bookInfoSeparator,
                                                 .bookInfoShippingIn, .bookInfoShippingFrom, .bookInfoShippingWay,
                                                 .bookInfoExhibitButton, .bookInfoOr, .bookInfoDeleteButton])]
        } else {
            normalSections = [Section(sectionType: .bookInfo,
                                      rowItems: [.bookInfoBookDetail, .bookInfoPrice, .bookInfoSeparator,
                                                 .bookInfoStatus, .bookInfoShippingComment, .bookInfoSeparator,
                                                 .bookInfoShippingIn, .bookInfoShippingFrom, .bookInfoShippingWay,
                                                 .bookInfoExhibitButton, .bookInfoOr, .bookInfoDeleteButton])]
            seriesSections = [Section(sectionType: .bookInfo,
                                      rowItems: [.bookInfoBookDetail, .bookInfoBulkTitle, .bookInfoPrice, .bookInfoSeparator,
                                                 .bookInfoStatus, .bookInfoBulkPhoto , .bookInfoShippingComment, .bookInfoSeparator,
                                                 .bookInfoShippingIn, .bookInfoShippingFrom, .bookInfoShippingWay,
                                                 .bookInfoExhibitButton, .bookInfoOr, .bookInfoDeleteButton])]
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.tableHeaderView = nil
        
        tableView?.isFixTableScrollWhenChangeContentsSize = true
        thanksView = ExhibitThanksView(delegate: self,
                                    image: UIImage(named: "img_cover_after_submit")!,
                                    title: "編集しました！",
                                    detail: "出品した商品は「マイページ」から\nいつでも見ることができます",
                                    buttonText: "OK,わかりました")
        thanksView?.isEditMeachandise = true
        
        merchandise.isSeries = isSeries
        
        DBLog(merchandise.shipWay)
        
    }
    
    override func createMerchandise() {
        SVProgressHUD.show()
        
        Merchandise.updateMerchandiseInfo(merchandise) { (merch, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self.view.isUserInteractionEnabled = true
                    self.navigationController?.navigationItem.leftBarButtonItem?.isEnabled = true
                    self.simpleAlert(nil, message: error!.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                
                SVProgressHUD.dismiss()
                
                 DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                    self.thanksView?.appearOnViewController(self.navigationController ?? self)
                    self.view.isUserInteractionEnabled = true
                    self.navigationController?.navigationItem.leftBarButtonItem?.isEnabled = true
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: ExhibitEditViewControllerEditNotification), object: nil)
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: ExhibitTableViewControllerPostedMerchandiseKey), object: nil, userInfo: nil)
                })
            }
        }
    }
    
    override func setbookId() {
        merchandise.bookId = book.identifier
    }
    
    override  open func baseSuggestViewActionButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?){
        for controller in self.navigationController!.viewControllers {
            if controller is DetailPageTableViewController {
              _ = self.navigationController?.popToRootViewController(animated: true)
                return
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.section(isSeries)[indexPath.section].rowItems[indexPath.row] == .bookInfoOr {
            return  12.0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    open func exhibitDeleteCellDeleteButtonTapped(_ cell: ExhibitDeleteCell, completion: (() ->Void)?) {
        
        RMUniversalAlert.show(in: self,
                              withTitle: nil,
                              message: "本当に削除しますか?",
                              cancelButtonTitle: "キャンセル",
                              destructiveButtonTitle: "削除",
                              otherButtonTitles: nil) {[weak self] (al, index) in
                                DispatchQueue.main.async {
                                    if index == al.destructiveButtonIndex {
                                        self?.deleteMerchandise({
                                            if completion != nil {
                                                completion!()
                                            }
                                        })
                                    }
                                    if completion != nil {
                                        completion!()
                                    }
                                }
        }
    }

    func deleteMerchandise(_ completion: @escaping () ->Void) {
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false

        merchandise.deleteMerchandise {[weak self] (error) in
            DispatchQueue.main.async {
                self?.view.isUserInteractionEnabled = true
                self?.navigationItem.leftBarButtonItem?.isEnabled = true
                if error != nil {
                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK", completion: nil)
                    completion()
                    return
                }
                SVProgressHUD.dismiss()
                self?.simpleAlert(nil, message: "削除しました！", cancelTitle: "OK", completion: {
                   _ = self?.navigationController?.popToRootViewController(animated: true)
                    completion()
                })
            }
        }
    }
}
