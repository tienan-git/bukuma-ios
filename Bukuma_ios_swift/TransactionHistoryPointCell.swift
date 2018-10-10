//
//  TransactionHistoryPointCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/16.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
private let cellVerticalPadding: CGFloat = 15.0
private let cellHorizontalPadding: CGFloat = 12.0
private let titleLabelHeight: CGFloat = 15.0
private let titleLabelwidth: CGFloat = 100.0
private let priceLabelHeight: CGFloat = 25.0
private let priceLabelVerticalPadding: CGFloat = 2.0
private let expirePointLabelHeight: CGFloat = 21.0
private let expirePointLabelVerticalPadding: CGFloat = 6.0
private let expireDateLabelHeight: CGFloat = 13.0
private let expirePartsMargin: CGFloat = 10.0

class TransactionHistoryPointCell: BaseTableViewCell {
    
    let titleLabel = UILabel()
    let priceLabel = UILabel()
    let titleLabel2 = UILabel()
    let expirePointLabel = UILabel()
    let expireDateLabel = UILabel()
    
    var pointInfo: GetPointTransactionResponse? {
        didSet {
            priceLabel.text = "\(pointInfo?.userBonusPoint?.thousandsSeparator() ?? "0")pt"
            
            if pointInfo?.userBonusPoint ?? 0 > 0 {
                expirePointLabel.isHidden = false
                expirePointLabel.text = "\(pointInfo?.nearExpireBonusPoint?.thousandsSeparator() ?? "0")pt"
                
                let fitSize = expirePointLabel.sizeThatFits(CGSize(width: kCommonDeviceWidth,
                                                                   height: expirePointLabelHeight))
                expirePointLabel.x = kCommonDeviceWidth - fitSize.width - cellHorizontalPadding
                expirePointLabel.width = fitSize.width
                
                expireDateLabel.isHidden = false
                expireDateLabel.text = pointInfo?.nearExpireBonusPointDatetime?.string(format: "yyyy/MM/dd")
                expireDateLabel.y = expirePointLabel.bottom - expireDateLabelHeight
                expireDateLabel.width = expirePointLabel.left - kCommonDeviceWidth / 2 - expirePartsMargin
            
            } else {
                expirePointLabel.isHidden = true
                expireDateLabel.isHidden = true
            }
        }
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        
        titleLabel.frame = CGRect(x: cellHorizontalPadding,
                                  y: cellVerticalPadding,
                                  width: titleLabelwidth,
                                  height: titleLabelHeight)
        titleLabel.textColor = kGray03Color
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.text = "ブクマ！ポイント"
        
        priceLabel.frame = CGRect(x: cellHorizontalPadding,
                                  y: titleLabel.bottom + priceLabelVerticalPadding,
                                  width: kCommonDeviceWidth / 2 - cellHorizontalPadding,
                                  height: priceLabelHeight)
        priceLabel.textColor = kBlackColor87
        priceLabel.textAlignment = .left
        priceLabel.lineBreakMode = .byTruncatingTail
        priceLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        titleLabel2.frame = CGRect(x: kCommonDeviceWidth - titleLabelwidth - cellHorizontalPadding,
                                   y: cellVerticalPadding,
                                   width: titleLabelwidth,
                                   height: titleLabelHeight)
        titleLabel2.textColor = kGray03Color
        titleLabel2.textAlignment = .right
        titleLabel2.lineBreakMode = .byTruncatingTail
        titleLabel2.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel2.text = "最短の有効期限"
        
        expirePointLabel.frame = CGRect(x: kCommonDeviceWidth - 100 - cellHorizontalPadding,
                                        y: titleLabel2.bottom + expirePointLabelVerticalPadding,
                                        width: 100,
                                        height: expirePointLabelHeight)
        expirePointLabel.textColor = kBlackColor87
        expirePointLabel.textAlignment = .right
        expirePointLabel.lineBreakMode = .byTruncatingTail
        expirePointLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        expireDateLabel.frame = CGRect(x: kCommonDeviceWidth / 2,
                                       y: expirePointLabel.bottom - expireDateLabelHeight,
                                       width: expirePointLabel.left - kCommonDeviceWidth / 2 - expirePartsMargin,
                                       height: expireDateLabelHeight)
        expireDateLabel.textColor = kBlackColor54
        expireDateLabel.textAlignment = .right
        expireDateLabel.lineBreakMode = .byTruncatingTail
        expireDateLabel.font = UIFont.boldSystemFont(ofSize: 12)
        
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(titleLabel2)
        contentView.addSubview(expirePointLabel)
        contentView.addSubview(expireDateLabel)
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
