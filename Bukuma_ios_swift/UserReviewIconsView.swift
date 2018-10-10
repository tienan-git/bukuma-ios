//
//  UserReviewIconsView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/30.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

/**
 
reviewの評価のView
 本詳細Pageとかなどで使われている
 
 */

enum ReviewIconViewType: Int {
    case good
    case normal
    case bad
}

enum ReviewIconSizeType: Int {
    case userPage
    case detailPage
}

class ReviewIconView: UIView {
    var iconImageView: UIImageView?
    var textlabel: UILabel?
    var viewType: ReviewIconViewType?
    var sizeType: ReviewIconSizeType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required convenience init(viewType: ReviewIconViewType, sizeType: ReviewIconSizeType) {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.viewType = viewType
        self.sizeType = sizeType
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() {
        iconImageView = UIImageView()
        iconImageView?.viewOrigin = CGPoint(x: 0, y: 0)
        self.setImage(viewType!, sizeType: sizeType!)
        
        self.addSubview(iconImageView!)
        
        textlabel = UILabel()
        textlabel?.viewOrigin = CGPoint(x: iconImageView!.right + 3.0, y: 0)
        textlabel?.height = self.height
        textlabel?.textColor = kGray03Color
        textlabel?.textAlignment = .center
        self.setAttributes(sizeType!)
        
        self.addSubview(textlabel!)
    }
    
    func setImage(_ viewType: ReviewIconViewType, sizeType: ReviewIconSizeType) {
        
        switch viewType {
        case .good:
            switch sizeType {
            case .userPage:
                iconImageView?.image = UIImage(named: "ic_review_19x19_gd")!
                break
            case .detailPage:
                iconImageView?.image = UIImage(named: "ic_review_13x13_gd")!
                break
            }
        case .normal:
            switch sizeType {
            case .userPage:
                iconImageView?.image = UIImage(named: "ic_review_19x19_rg")!
                break
            case .detailPage:
                iconImageView?.image = UIImage(named: "ic_review_13x13_rg")!
                break
            }
        case .bad:
            switch sizeType {
            case .userPage:
                iconImageView?.image = UIImage(named: "ic_review_19x19_bd")!
                break
            case .detailPage:
                iconImageView?.image = UIImage(named: "ic_review_13x13_bd")!
                break
            }
        }
        
        iconImageView?.viewSize = iconImageView!.image!.size
        self.height = iconImageView!.height
    }
    
    func setAttributes(_ sizeType: ReviewIconSizeType) {
        switch sizeType {
        case .userPage:
            textlabel?.textColor = UIColor.colorWithHex(0x666666)
            textlabel?.font = UIFont.boldSystemFont(ofSize: 16)
            break
        case .detailPage:
            textlabel?.textColor = UIColor.colorWithHex(0x5c6572)
            textlabel?.font = UIFont.boldSystemFont(ofSize: 10)
            break
        }
    }
    
    func setCount(_ count: String?) {
        textlabel?.text = count ?? "0"
        textlabel?.width = textlabel!.text!.getTextWidthWithFont(textlabel!.font, viewHeight: textlabel!.height)
        self.width = textlabel!.right
    }
}

class UserReviewIconsView: UIView {
    
    var sizeType: ReviewIconSizeType?
    var icons: [ReviewIconView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init (sizeType: ReviewIconSizeType) {
        self.init(frame: CGRect.zero)
        self.sizeType = sizeType
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() {
        for i in 0 ... 2 {
            let reviewView: ReviewIconView = ReviewIconView(viewType: ReviewIconViewType(rawValue: i)!, sizeType: sizeType!)
            reviewView.tag = i
            icons.append(reviewView)
            self.addSubview(reviewView)
            self.height = reviewView.height
        }
    }
    
    func count(_ user: User, type: ReviewIconViewType) ->String {
        switch type {
        case .good:
            return user.goodReviewCount ?? "0"
        case .normal:
            return user.normalReviewCount ?? "0"
        case .bad:
            return user.badReviewCount ?? "0"
        
        }
    }
    
    class func holizonMargin(_ sizeType: ReviewIconSizeType) ->CGFloat {
        switch sizeType {
        case .userPage:
            return 20.0
        case .detailPage:
            return 7.0
        }
    }
    
    var user: User? {
        didSet {
            
            if user == nil {
                return
            }
            
            for i in 0 ... 2 {
                icons[i].setCount(self.count(user!, type: ReviewIconViewType(rawValue: i)!))
                if i == 0 {
                    icons[i].viewOrigin = CGPoint(x: 0,
                                              y: 0)
                } else {
                    var width: CGFloat = 0
                    for j in 0 ... i - 1 {
                        width += icons[j].width
                    }

                    icons[i].viewOrigin = CGPoint(x: type(of: self).holizonMargin(sizeType!) * i.cgfloat() + width,
                                              y: 0)
                }
            }
            
            self.width = icons[0].width + icons[1].width + icons[2].width + type(of: self).holizonMargin(sizeType!) * 2
        }
    }
}
