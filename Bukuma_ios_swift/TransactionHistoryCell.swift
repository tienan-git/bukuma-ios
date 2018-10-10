//
//  TransactionHistoryCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

private let cellVerticalPadding: CGFloat = 15.0
private let cellHorizontalPadding: CGFloat = 12.0
private let priceLabelHeight: CGFloat = 20.0
private let titleLabelHeight: CGFloat = 20.0
private let dateLabelVerticalPadding: CGFloat = 8.0

private let titleLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 16)
private let priceLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 16)

class TransactionHistoryCell: BaseTableViewCell {
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let priceLabel = UILabel()
    let expireDateLabel = UILabel()
    
    let testLabel = UILabel()
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        
        
        testLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        testLabel.textColor = UIColor.blue
        
        titleLabel.frame = CGRect(x: cellHorizontalPadding,
                                   y: cellVerticalPadding,
                                   width: 0,
                                   height: titleLabelHeight)
        titleLabel.textColor = kBlackColor87
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = titleLabelFont
        
        dateLabel.frame = CGRect(x: titleLabel.x,
                                 y: titleLabel.bottom + dateLabelVerticalPadding,
                                 width: 125,
                                 height: dateLabelHeight)
        dateLabel.textColor = kGrayColor
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        
        expireDateLabel.frame = CGRect(x: dateLabel.right,
                                 y: titleLabel.bottom + dateLabelVerticalPadding,
                                 width: 150,
                                 height: dateLabelHeight)
        expireDateLabel.textColor = kPink02Color
        expireDateLabel.font = UIFont.systemFont(ofSize: 13)
        
        priceLabel.frame = CGRect(x: 0,
                                   y: 0,
                                   width: 0,
                                   height: priceLabelHeight)
        
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        contentView.addSubview(testLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(expireDateLabel)
        contentView.addSubview(priceLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let pointTransaction: PointTransaction? = object as? PointTransaction
        
        var priceLabelWidth: CGFloat = 0
        var title: String = ""

        if pointTransaction != nil {
            priceLabelWidth = self.priceAttribute(pointTransactoin: pointTransaction!).getTextWidth(priceLabelHeight)
            title = self.title(pointTransaction: pointTransaction!)
        }
        
        let titleLabelWidth: CGFloat = kCommonDeviceWidth - priceLabelWidth - (cellHorizontalPadding * 2) - 10.0
        let titleLabelheight = title.getTextHeight(titleLabelFont, viewWidth: titleLabelWidth)
        
        let cellHeight: CGFloat = cellVerticalPadding * 2  + dateLabelVerticalPadding + dateLabelHeight + titleLabelheight
        return cellHeight
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let pointTransaction = cellModelObject as? PointTransaction

            pointTransaction.map {
                priceLabel.attributedText = type(of: self).priceAttribute(pointTransactoin: $0)
                
                let priceLabelWidth: CGFloat = type(of: self).priceAttribute(pointTransactoin: $0).getTextWidth(priceLabelHeight)
                
                priceLabel.width = priceLabelWidth
                priceLabel.right = kCommonDeviceWidth - cellHorizontalPadding
                
                titleLabel.text = type(of: self).title(pointTransaction: $0)
                
                let titleLabelWidth: CGFloat = kCommonDeviceWidth - priceLabelWidth - (cellHorizontalPadding * 2) - 10.0
                titleLabel.width = titleLabelWidth
                titleLabel.height = (titleLabel.text ?? "").getTextHeight(titleLabelFont, viewWidth: titleLabelWidth)
            }
            
            dateLabel.y = titleLabel.bottom + dateLabelVerticalPadding
            dateLabel.text = pointTransaction?.createdAt?.string(format: "yyyy/MM/dd HH:mm")
            
            expireDateLabel.y = dateLabel.y
            if let expiredAt = pointTransaction?.expiredAt {
                expireDateLabel.text = "有効期限 \(expiredAt.string(format: "yyyy/MM/dd"))"
            } else {
                expireDateLabel.text = nil
            }
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        priceLabel.y = (self.contentView.height - priceLabelHeight) / 2
        
    }
    
    private class func title(pointTransaction: PointTransaction) ->String {
        switch pointTransaction.stateType! {
        case .firstSingin:
            return "初回ブクマ！ポイント獲得"
        case .singin:
            return "招待コード入力"
        case .buyMerchandise:
            var bookName: String = ""
            if pointTransaction.book?.identifier != nil {
                if Utility.isEmpty(pointTransaction.book) == false {
                    bookName = "「\(pointTransaction.book?.title ?? "")」"
                } else {
                    bookName = "「\(pointTransaction.book?.seriesTitle ?? "")」"
                }
            }
            if pointTransaction.pointType == PointTransactionPointType.bonus {
                return "ブクマ！ポイント商品購入" + "\n" + bookName
            }
            return "売上金商品購入" + "\n" + bookName
        case .buyPoint:
            return "クレジットカード購入"
        case .soldMerchandise:
            var bookName: String = ""
            if pointTransaction.book?.identifier != nil {
                 bookName = "「\(pointTransaction.book?.titleText() ?? "")」"
            }
            return "商品売却" + "\n" + bookName
        case .withdraw:
            return "銀行振込"
        case .refundBonus:
            return "ブクマ！ポイント返却"
        case .refundNormal:
            return "売上返却"
        case .adminNormal:
            if pointTransaction.moneySignType == PointTransactionMoneySignType.puls {
                return "運営からの売上付与"
            }
            return "運営からの売上差引"
        case .adminBonus:
            if pointTransaction.moneySignType == PointTransactionMoneySignType.puls {
                return "運営からのブクマ！ポイント付与"
            }
            return "運営からのブクマ！ポイント差引"
        case .campain:
            return "キャンペーン"
        case .buyMerchandiseViaCreditCard, .buyCreditCard:
            var bookName: String = ""
            if pointTransaction.book?.identifier != nil {
               
               bookName = "「\(pointTransaction.book?.titleText() ?? "")」"
            }

            return "クレジットカード商品購入" + "\n" + bookName
        case .expiredSales:
            return "売上金期限切れ"
        case .expiredPoint:
            return "ブクマポイント！期限切れ"
        case .unknown:
            return ""
        }
    }
    
    private class func priceAttribute(pointTransactoin: PointTransaction) ->NSMutableAttributedString {
        var price: String = ""
        var moneySign: String = ""
        var textColor: UIColor = UIColor()
        var attribute: NSMutableAttributedString = NSMutableAttributedString()
        
        if pointTransactoin.pointType == PointTransactionPointType.normal {
            price = pointTransactoin.stateType == .buyCreditCard ? pointTransactoin.creditPoint.string() : pointTransactoin.pointChanged.string()
        }
        if pointTransactoin.pointType == PointTransactionPointType.bonus {
            price = pointTransactoin.bonusPointChanged.string()
        }
        
        if pointTransactoin.moneySignType == PointTransactionMoneySignType.puls {
            moneySign = "+"
            textColor = kTintGreenColor
        } else if pointTransactoin.moneySignType == PointTransactionMoneySignType.minus {
            textColor = kPink02Color
        }
        
        let text: String = moneySign + price.int().thousandsSeparator()
        let textRange: NSRange = NSRange(location: 0, length: text.length)
        
        attribute = NSMutableAttributedString(string: text)
        attribute.addAttributes([NSFontAttributeName: priceLabelFont], range: textRange)
        attribute.addAttributes([NSForegroundColorAttributeName: textColor], range: textRange)
        return attribute
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
    }
}
