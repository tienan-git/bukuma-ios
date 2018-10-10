//
//  CreditCardInfoCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/19.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

open class CreditCardInfoCell: BaseIconTextTableViewCell {
    
    fileprivate var datelabel: UILabel? = UILabel()
    fileprivate var last4Label: UILabel?
    var defaultButton: UIButton?
    let defaultImage: UIImage! = UIImage(named: "ic_to_check")!
    
    deinit {
        DBLog("-----deinit--CreditCardInfoCell-----")
    }
    
    override var iconImage: UIImage? {
        didSet {
            iconImageView!.image = iconImage
            iconImageView!.viewSize = CGSize(width: iconImage!.size.width, height: iconImage!.size.height)
            iconImageView!.y = (self.height - iconImageView!.height) / 2
            titleLabel!.x = iconImageView!.right + 15.0
            titleLabel!.height = 20
            titleLabel!.y = iconImageView!.y
            datelabel!.x = titleLabel!.x
        }
    }

    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        iconImageView!.x = 15.0
        
        datelabel!.frame = CGRect(x: titleLabel!.x, y: titleLabel!.bottom + 10.0, width: 150.0, height: 20.0)
        datelabel!.textAlignment = .left
        datelabel!.font = UIFont.systemFont(ofSize: 12)
        titleLabel!.layer.borderColor = UIColor.clear.cgColor
        self.contentView.addSubview(datelabel!)
        
        defaultButton = UIButton(frame: CGRect(x:self.contentView.width - defaultImage.size.width, y: 0, width: defaultImage.size.width, height: defaultImage.size.height))
        self.contentView.addSubview(defaultButton!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return UIImage(named: "img_credit_visa")!.size.height + (15.0 * 2)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        defaultButton!.x = self.contentView.width - defaultImage.size.width
        defaultButton!.y = (self.height - defaultButton!.height) / 2
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let card: CreditCard? = cellModelObject as? CreditCard
            if card == nil {
                return
            }
            self.iconImage = self.cardImage(card!)
            title = "**** **** **** \(card!.last4!)"
            datelabel!.text = "有効期限 \(card!.expirationMonth!)/ \(card!.expirationYear!)"
            if card?.isDefault == true {
                defaultButton!.setImage(defaultImage, for: .normal)
            } else {
                defaultButton!.setImage(nil, for: .normal)
            }
        }
    }
    
    func cardImage(_ card: CreditCard) -> UIImage? {
        if card.brand == nil {
            iconImageView?.viewSize = CGSize(width: UIImage(named: "img_credit_visa")!.size.width, height: UIImage(named: "img_credit_visa")!.size.height)
            return UIImage.imageWithColor(kBorderColor, size: iconImageView!.viewSize)
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
            iconImageView?.viewSize = CGSize(width: UIImage(named: "img_credit_visa")!.size.width, height: UIImage(named: "img_credit_visa")!.size.height)
            return UIImage.imageWithColor(kBorderColor, size: iconImageView!.viewSize)
        }
    }
}
