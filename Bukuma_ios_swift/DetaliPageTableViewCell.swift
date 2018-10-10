//
//  DetaliPageTableViewCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/17.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class DetaliPageTableViewCell: BaseTableViewCell {

    fileprivate var book: Book?
    fileprivate var iconImageViewButton: UIButton!
    fileprivate var priceLabel: UILabel!
    fileprivate var statusLabel: UILabel!
    fileprivate var userNamelabel: UILabel!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        iconImageViewButton = UIButton(frame: CGRect(x: 15, y: 15, width: 45, height: 45))
        iconImageViewButton.contentHorizontalAlignment = .fill
        iconImageViewButton.contentVerticalAlignment = .fill
        iconImageViewButton.clipsToBounds = true
        iconImageViewButton.layer.cornerRadius = iconImageViewButton.height / 2
        self.contentView.addSubview(iconImageViewButton)
        
//        iconImageViewButton.sd_setImageWithURL(URL(string:"http://ecx.images-amazon.com/images/I/41kKoPxu2TL._SX337_BO1,204,203,200_.jpg"),
//            for: .normal, placeholderImage: kPlaceholderUserImage)
        
        priceLabel = UILabel(frame: CGRect(x: iconImageViewButton.right + 20, y: iconImageViewButton.y, width: 150, height: 30))
        priceLabel.textAlignment = .right
        priceLabel.text = "¥3,300"
        priceLabel.font = UIFont.boldSystemFont(ofSize: 25)
        priceLabel.textColor = kBlackColor87
        self.contentView.addSubview(priceLabel)
        
        statusLabel = UILabel(frame: CGRect(x: priceLabel.x, y: priceLabel.bottom, width: priceLabel.width, height: 20))
        statusLabel.textAlignment = .right
        statusLabel.text = "商品の状態: 非常に良い"
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textColor = UIColor.gray
        self.contentView.addSubview(statusLabel)
        
        userNamelabel = UILabel(frame: CGRect(x: statusLabel.x, y: statusLabel.bottom, width: 200, height: 20))
        userNamelabel.textAlignment = .right
        self.contentView.addSubview(userNamelabel)
        
    }
    
    override open var cellModelObject: AnyObject? {
        willSet(newValue) {
            book = newValue as? Book
            
            userNamelabel.attributedText = self._generateAtrributeText(book!)
        }
    }
    
    func _generateAtrributeText(_ book: Book) ->NSAttributedString {
        let mutableAttributedString: NSMutableAttributedString =  NSMutableAttributedString()
        let insertNickName: String = "\(book.title!)"
        
        let name: NSAttributedString = NSAttributedString.init(string: insertNickName,
            attributes: [NSForegroundColorAttributeName:kMainGreenColor, NSFontAttributeName:UIFont.systemFont(ofSize: 15)])
        mutableAttributedString.append(name)
        
        let otherText: NSMutableAttributedString = NSMutableAttributedString.init(string: "による出品です",
            attributes: [NSForegroundColorAttributeName:UIColor.gray, NSFontAttributeName:UIFont.systemFont(ofSize: 15)])
        
        mutableAttributedString.append(otherText)
        return mutableAttributedString
    }

    override open class func cellHeightForObject(_ object: AnyObject?) -> CGFloat {
        return 90
    }
}
