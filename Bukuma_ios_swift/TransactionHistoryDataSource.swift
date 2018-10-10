//
//  TransactionHistoryDataSource.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class TransactionHistoryDataSource: BaseDataSource {
    
    var getPointTransactionResponse: GetPointTransactionResponse?
    
    override open func cachedData() -> [AnyObject]? {
        return PointTransaction.cachePointTransactions()
    }

    override open func updateDatasourceByRefreshDataSource(_ shouldRefresh: Bool) {
        if Me.sharedMe.isRegisterd == false {
            self.completeGetting(nil, shouldRefresh: shouldRefresh, error: nil)
            return
        }
        PointTransaction.getPointTransactionLogs(self.paging(&page)) { [weak self] (response, error) in
            self?.getPointTransactionResponse = response
            self?.completeGetting(response?.pointTransactions, shouldRefresh: shouldRefresh, error: error)
        }
    }
    
    // server上で売り上げで買ったのか、クレカで買ったのか判別できない(それを判別するような仕様で作られていない)のでローカルでsortしたり
    // している.
    //もしpurchased from cardというdesproptionだと、それはクレカ購入なので、その場合次のPointTransactionでどれくらいPointを消費しているか
    //クレカと同じ額消費していたら、それはクレカ購入だし、+20 normal pointつかってたら、クレカ+20円売上で購入だし、bonus pointつかわれてたら、クレカ+売上+ポイントになる可能性もある
    override open func update() {
        guard let pointTransactions: [PointTransaction] = dataSource as? [PointTransaction]  else {
            return
        }
        
        var points: [PointTransaction] = pointTransactions
        var addblePoints: [PointTransaction] = []
        
        for (i, point) in pointTransactions.enumerated() {
            if point.purchaseDescription?.contains("purchased from card") == true {
                
                let nextIndex: Int =  pointTransactions.index(before: i)
                let nextPointTransaction: PointTransaction = pointTransactions[nextIndex]
                
                if nextPointTransaction.purchaseDescription?.contains("Bought merchandise") == true &&
                    nextPointTransaction.pointType == PointTransactionPointType.bonus {
                    
                    point.shouldRemove = true
                    
                    let nextnextIndex: Int = pointTransactions.index(before: nextIndex)
                    let nextNextPointTransaction: PointTransaction =  pointTransactions[nextnextIndex]
                    
                    let dif: Double = fabs(point.pointChanged.double()) - fabs(nextNextPointTransaction.pointChanged.double())
                    
                    if dif == 0 {
                        let newTransaction: PointTransaction = PointTransaction()
                        newTransaction.id = "-\(String(describing: nextPointTransaction.id))"
                        newTransaction.pointChanged = -point.pointChanged
                        newTransaction.book = nextPointTransaction.book
                        newTransaction.stateType = PointTransactionStateType.buyMerchandiseViaCreditCard
                        newTransaction.moneySignType = PointTransactionMoneySignType.minus
                        newTransaction.pointType = PointTransactionPointType.normal
                        newTransaction.createdAt = nextPointTransaction.createdAt
                        newTransaction.updatedAt = nextPointTransaction.updatedAt
                        newTransaction.expiredAt = nextPointTransaction.expiredAt
                        newTransaction.shouldAdd = true
                        newTransaction.addableIndex = nextIndex
                        addblePoints.append(newTransaction)
                        
                        nextNextPointTransaction.shouldRemove = true
                        
                    } else if dif > 0 {
                        
                    } else if dif < 0 {
                        let newTransaction: PointTransaction = PointTransaction()
                        newTransaction.id = "-\(String(describing: nextPointTransaction.id))"
                        newTransaction.pointChanged = -point.pointChanged
                        newTransaction.book = nextPointTransaction.book
                        newTransaction.stateType = PointTransactionStateType.buyMerchandiseViaCreditCard
                        newTransaction.moneySignType = PointTransactionMoneySignType.minus
                        newTransaction.pointType = PointTransactionPointType.normal
                        newTransaction.createdAt = nextPointTransaction.createdAt
                        newTransaction.updatedAt = nextPointTransaction.updatedAt
                        newTransaction.expiredAt = nextPointTransaction.expiredAt
                        newTransaction.shouldAdd = true
                        newTransaction.addableIndex = nextIndex
                        addblePoints.append(newTransaction)
                        
                        nextNextPointTransaction.pointChanged = -Int(fabs(nextNextPointTransaction.pointChanged.double()) - fabs(newTransaction.pointChanged.double()))
                    }
                    
                } else if nextPointTransaction.purchaseDescription?.contains("Bought merchandise") == true &&
                    nextPointTransaction.pointType == PointTransactionPointType.normal {
                    
                    let dif: Double = fabs(nextPointTransaction.pointChanged.double()) - fabs(point.pointChanged.double())
                    
                    if dif == 0.0 {
                        point.shouldRemove = true
                        nextPointTransaction.stateType = PointTransactionStateType.buyMerchandiseViaCreditCard
                        
                    } else if  dif > 0 {
                        
                        let replaceNextPointTransaction: PointTransaction = PointTransaction()
                        replaceNextPointTransaction.id = "-\(String(describing: nextPointTransaction.id))"
                        replaceNextPointTransaction.pointChanged = -point.pointChanged
                        replaceNextPointTransaction.stateType = PointTransactionStateType.buyMerchandiseViaCreditCard
                        replaceNextPointTransaction.moneySignType = nextPointTransaction.moneySignType
                        replaceNextPointTransaction.pointType = nextPointTransaction.pointType
                        replaceNextPointTransaction.createdAt = nextPointTransaction.createdAt
                        replaceNextPointTransaction.updatedAt = nextPointTransaction.updatedAt
                        replaceNextPointTransaction.expiredAt = nextPointTransaction.expiredAt
                        replaceNextPointTransaction.shouldAdd = true
                        replaceNextPointTransaction.book = nextPointTransaction.book
                        replaceNextPointTransaction.addableIndex = nextIndex
                        addblePoints.append(replaceNextPointTransaction)
                        
                        nextPointTransaction.shouldRemove = true
                        
                        let newTransaction: PointTransaction = PointTransaction()
                        newTransaction.id = "-\(String(describing: nextPointTransaction.id))"
                        newTransaction.pointChanged = -dif.int()
                        newTransaction.book = nextPointTransaction.book
                        newTransaction.stateType = PointTransactionStateType.buyMerchandise
                        newTransaction.moneySignType = PointTransactionMoneySignType.minus
                        newTransaction.pointType = PointTransactionPointType.normal
                        newTransaction.createdAt = nextPointTransaction.createdAt
                        newTransaction.updatedAt = nextPointTransaction.updatedAt
                        newTransaction.expiredAt = nextPointTransaction.expiredAt
                        newTransaction.shouldAdd = true
                        newTransaction.addableIndex = nextIndex
                        addblePoints.append(newTransaction)
                        
                        point.shouldRemove = true
                    }
                }
            }
        }
        
        //rescutive クレジットだけ購入して、何も買ってない場合。//ほとんどアリエナイ
        for (_, point) in points.enumerated() {
            if point.purchaseDescription?.contains("purchased from card") == true {
                point.shouldRemove = true
            }
        }
        
        for point in addblePoints {
            points.insert(point, at: point.addableIndex)
        }
        
        for point in points {
            if point.shouldRemove == true {
                points.removeObject(point)
            }
        }
        
        points.sort(by: { (pointTransaction, nextPointTransaction) -> Bool in
            return pointTransaction.createdAt!.compare(nextPointTransaction.createdAt! as Date) == ComparisonResult.orderedDescending
        })
        
        dataSource = points
    }
    
    override open func removeMyExistenseNotification(_ notification: Foundation.Notification) {
        dataSource?.removeAll()
        delegate?.completeRequest()
    }

}
