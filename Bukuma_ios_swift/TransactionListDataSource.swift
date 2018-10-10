//
//  TransactionListDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/18.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD

open class TransactionListDataSource: BaseDataSource {
    // 最初に updateDatasourceByRefreshDataSource でデータを全件取得したいため、無限スクロールを可能にするこのフラグを OFF にして、
    // 途中でデータの更新が起きないようにする
    override open var isMoreDataSourceAvailable: Bool? {
        get { return false }
        set {}
    }

    var todoDatas: [[Transaction]] = [[Transaction](), [Transaction]()]

    override open var dataSource: [AnyObject]? {
        didSet {
            self.updatedAt = Date()

            self.todoDatas = [[Transaction](), [Transaction]()]
            if let transactions = self.dataSource as? [Transaction] {
                for transaction in transactions {
                    if transaction.isBuyer() == true {
                        if transaction.type == .sellerShipped {
                            self.todoDatas[0].append(transaction)
                        } else {
                            self.todoDatas[1].append(transaction)
                        }
                    } else {
                        if transaction.type == .sellerPrepareShipping ||
                            transaction.type == .buyerItemArried {
                            self.todoDatas[0].append(transaction)
                        } else {
                            self.todoDatas[1].append(transaction)
                        }
                    }
                }
            }
        }
    }

    override open func cachedData() ->[AnyObject]? {
        return Transaction.cachedItemTransaction()
    }

    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        self.storeAllDataSource(true)
    }

    private let numberOfTransactionsAtOnce = 100

    private func storeAllDataSource(_ shouldRefresh: Bool) {
        Transaction.getItemTransactionList(self.numberOfTransactionsAtOnce, page: self.paging(&page)) { [weak self] (transactions, error) in
            if let error = error {
                self?.delegate?.failedRequest(error)
                return
            }

            if let transactions = transactions {
                self?.completeGetting(transactions, shouldRefresh: shouldRefresh, error: error)

                self?.storeAllDataSource(false)
            } else {
                self?.delegate?.completeRequest()
            }
        }
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }
}
