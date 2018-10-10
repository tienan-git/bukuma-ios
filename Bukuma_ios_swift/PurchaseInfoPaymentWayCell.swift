//
//  PurchaseInfoPaymentWayCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/14.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


private let cardVerticalMargin: CGFloat = 10
private let cardImageViewSize: CGSize = CGSize(width: 36.0, height: 36.0)
private let cardNumberLabelSize: CGSize = CGSize(width: 115, height: 15.0)

open class PurchaseInfoPaymentWayCell: BaseIconTitleTextCell {
    
    fileprivate let cardImageView: UIImageView! = UIImageView()
    fileprivate let cardNumberLabel: UILabel! = UILabel()
    fileprivate let cardAvailablePeriodLabel: UILabel! = UILabel()

    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        titleLabel!.text = "お支払い方法"
        titleLabel!.x = 15.0

        cardImageView.frame = CGRect(x: kCommonDeviceWidth - cardNumberLabelSize.width - 12.0 - cardImageViewSize.width,
                                     y: cardVerticalMargin,
                                     width: cardImageViewSize.width,
                                     height: cardImageViewSize.height)
        cardImageView.contentMode = .scaleToFill
        cardImageView!.image = UIImage(named: "img_credit_master")!
        cardImageView.isHidden = true
        self.contentView.addSubview(cardImageView)
        
        cardNumberLabel.frame = CGRect(x: kCommonDeviceWidth - cardNumberLabelSize.width - 12.0,
                                       y: cardImageView.y + 1.0,
                                       width: cardNumberLabelSize.width,
                                       height: cardNumberLabelSize.height)
        cardNumberLabel.font = UIFont.boldSystemFont(ofSize: 12)
        cardNumberLabel.textColor = kBlackColor87
        cardNumberLabel.textAlignment = .right
        cardNumberLabel.text = "未設定"
        self.contentView.addSubview(cardNumberLabel)
        
        cardAvailablePeriodLabel.frame = CGRect(x: cardNumberLabel.x,
                                                y: cardNumberLabel.bottom + 3.0,
                                                width: cardNumberLabel.width,
                                                height: cardNumberLabel.height)
        cardAvailablePeriodLabel.font = UIFont.boldSystemFont(ofSize: 10)
        cardAvailablePeriodLabel.textColor = UIColor.colorWithHex(0x70828e)
        cardAvailablePeriodLabel.textAlignment = .right
        self.contentView.addSubview(cardAvailablePeriodLabel)
        
        isShortBottomLine = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            if cellModelObject is CreditCard {
                let card: CreditCard? = cellModelObject as? CreditCard
                if card == nil || card?.id == nil {
                    return
                }
                cardImageView.isHidden = false
                cardImageView!.image = self.cardImage(card!)
                
                cardNumberLabel.textAlignment = .right
                cardNumberLabel.text = "**** **** **** \(card!.last4!)"
                cardNumberLabel.width =  cardNumberLabel.text!.getTextWidthWithFont(cardNumberLabel.font, viewHeight: cardNumberLabel.height)
                
                cardAvailablePeriodLabel.width = cardNumberLabel.width
                cardImageView.x = kCommonDeviceWidth - cardNumberLabel.width - cardImageViewSize.width - 12.0 * 2
                cardNumberLabel.x = cardImageView.right + 12.0
                cardAvailablePeriodLabel.x = cardNumberLabel.x
                cardAvailablePeriodLabel.text = "有効期限 \(card!.expirationMonth!)/ \(card!.expirationYear!)"
            }
            
            if cellModelObject is Point {
                let point: Point? = cellModelObject as? Point
                cardImageView.isHidden = false
                cardImageView.image = UIImage(named: "img_pay_point")!
                cardImageView.clipsToBounds = true
                cardImageView.layer.cornerRadius = cardImageView.height / 2
                
                cardAvailablePeriodLabel.text = "ブクマ！ポイント"
                cardAvailablePeriodLabel.width = cardAvailablePeriodLabel.text!.getTextWidthWithFont(cardAvailablePeriodLabel.font, viewHeight: cardAvailablePeriodLabel.height)
                cardAvailablePeriodLabel.x = kCommonDeviceWidth - cardAvailablePeriodLabel.width - 12.0
                
                cardNumberLabel.textAlignment = .right
                cardNumberLabel.text = "残り:\(point?.usablePoint ?? "0") pt"
                cardNumberLabel.width =  cardNumberLabel.text!.getTextWidthWithFont(cardNumberLabel.font, viewHeight: cardNumberLabel.height)
                cardNumberLabel.x = cardAvailablePeriodLabel.x
                cardImageView.x = cardNumberLabel.left - cardImageViewSize.width - 12.0
            }
        }
    }

    fileprivate func cardImage(_ card: CreditCard) -> UIImage {
        if card.brand == nil {
            return UIImage(named: "img_credit_master")!
        }
        switch card.brand! {
        case "Visa":
            return UIImage(named: "img_credit_visa")!
        case "Amex":
            return UIImage(named: "img_credit_amex")!
        case "JCB":
            return UIImage(named: "img_credit_jcb")!
        case "MasterCard":
            return UIImage(named: "img_credit_master")!
        case "Diners":
            return UIImage(named: "img_credit_diners")!
        default:
            return UIImage(named: "img_credit_master")!
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if cellModelObject == nil {
            cardNumberLabel.y = (50.0 - cardNumberLabel.height) / 2
        }
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        if object == nil {
            return 50.0
        }
        return cardImageViewSize.height + cardVerticalMargin * 2
    }
}
