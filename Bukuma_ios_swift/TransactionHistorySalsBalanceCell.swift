//
//  TransactionHistorySalsBalanceCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/08.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

private let cellVerticalPadding: CGFloat = 15.0
private let cellHorizontalPadding: CGFloat = 12.0
private let titleLabelHeight: CGFloat = 15.0
private let priceLabelHeight: CGFloat = 25.0
private let priceLabelVerticalPadding: CGFloat = 2.0

class TransactionHistorySalsBalanceCell: BaseTableViewCell {
    
    var priceLabel: UILabel?
    
    var pointInfo: GetPointTransactionResponse? {
        didSet {
            priceLabel?.text = "¥ \(pointInfo?.userPoint?.thousandsSeparator() ?? "0")"
        }
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)

        let titleLabel: UILabel = UILabel()
        titleLabel.frame = CGRect(x: cellHorizontalPadding,
                                   y: cellVerticalPadding,
                                   width: 100,
                                   height: titleLabelHeight)
        titleLabel.textColor = kGray03Color
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.text = "売上金"
        self.contentView.addSubview(titleLabel)
    
        let priceLabel: UILabel = UILabel()
        priceLabel.frame = CGRect(x: cellHorizontalPadding,
                                  y: titleLabel.bottom + priceLabelVerticalPadding,
                                  width: kCommonDeviceWidth - cellHorizontalPadding * 2,
                                  height: priceLabelHeight)
        priceLabel.textColor = kBlackColor87
        priceLabel.textAlignment = .left
        priceLabel.lineBreakMode = .byTruncatingTail
        priceLabel.font = UIFont.boldSystemFont(ofSize: 24)
        self.contentView.addSubview(priceLabel)
        self.priceLabel = priceLabel
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let cellHeight: CGFloat = cellVerticalPadding * 2 + titleLabelHeight + priceLabelVerticalPadding + priceLabelHeight
        return cellHeight
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
