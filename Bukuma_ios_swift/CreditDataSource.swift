//
//  CreditDataSource.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/19.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class CreditDataSource: BaseDataSource {
    
    required public init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteCard(_:)), name: NSNotification.Name(rawValue: CreditCardDeleteKey), object: nil)

    }
    
    override open func cachedData() ->[AnyObject]? {
        return nil
    }
    
    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        CreditCard.getCardInfo { (cards, error) in
            self.completeGetting(cards, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    override func update() {
        isMoreDataSourceAvailable = false
    }
    
    func deleteCard(_ notification: Foundation.Notification) {
        let card: CreditCard = notification.object as! CreditCard
        for r in self.dataSource! as! Array<CreditCard> {
            if r.id == card.id {
                self.dataSource!.removeObject(r)
            }
        }
        self.delegate?.completeRequest()
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
