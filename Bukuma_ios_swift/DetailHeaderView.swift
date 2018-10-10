//
//  BKMDetailHeaderView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/16.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

protocol LikeCountButtonProtocol {
    func likeCountButtonHeartButtonTapped(_ button: LikeCountButton, completion:@escaping () ->Void)
}

class LikeCountButton: UILabel {
    
    fileprivate var delegate: LikeCountButtonProtocol?
    fileprivate var heartButton: LikeButton?
    fileprivate var likeCountLabel: UILabel?
    fileprivate let heartMargin: CGFloat = -16
    fileprivate let heartAdditionalMargin: CGFloat = 12.0
    fileprivate let likeCountLabelAdditionalMargin: CGFloat = 5.0
    fileprivate let heartOriginalWidth: CGFloat = 16.0
    fileprivate let rightMargin: CGFloat = 12.0

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.height / 2
        self.clipsToBounds = false
        self.isExclusiveTouch = false
        self.isUserInteractionEnabled = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = kGray01Color.cgColor
        
        heartButton = LikeButton()
        heartButton?.viewSize = CGSize(width: UIImage(named: "heart_before")!.size.width,
                                   height: UIImage(named: "heart_before")!.size.height)
        heartButton?.viewOrigin = CGPoint(x: heartMargin + heartAdditionalMargin,
                                      y: (self.height - heartButton!.height) / 2)
        heartButton?.addTarget(self, action: #selector(self.heartButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(heartButton!)
        
        let likeCountLabelXMargin: CGFloat = heartButton!.right - 16.0
        
        likeCountLabel = UILabel()
        likeCountLabel?.font = UIFont.systemFont(ofSize: 14)
        likeCountLabel?.height = 13.0
        likeCountLabel?.viewOrigin = CGPoint(x: likeCountLabelXMargin + likeCountLabelAdditionalMargin,
                                         y: (self.height - likeCountLabel!.height) / 2)
        likeCountLabel?.width = 10
        likeCountLabel?.isUserInteractionEnabled = true
        likeCountLabel?.textColor = UIColor.gray
        self.addSubview(likeCountLabel!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateLikeCount(_:)), name: NSNotification.Name(rawValue: BookLikeCountChangeNotification), object: nil)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var book: Book? {
        didSet {
            likeCountLabel?.text = book?.numOfLike?.string()

            let lastHeight = likeCountLabel?.frame.size.height
            likeCountLabel?.sizeToFit()
            likeCountLabel?.frame.size.height = lastHeight!

            heartButton?.setLiked(book?.liked ?? false)
            
            if book?.liked == true {
                likeCountLabel?.textColor = kPink02Color
            } else {
                likeCountLabel?.textColor = UIColor.gray
            }
            self.width = heartAdditionalMargin + heartOriginalWidth + likeCountLabelAdditionalMargin + likeCountLabel!.width + rightMargin
        }
    }
    
    func heartButtonTapped(_ sender: UIButton) {
        self.isUserInteractionEnabled = false
        delegate?.likeCountButtonHeartButtonTapped(self, completion: { [weak self] in
            DispatchQueue.main.async {
                self?.isUserInteractionEnabled = true
            }
        })
    }
    
    func setLike(_ isLiked: Bool) {
        DispatchQueue.main.async {
            self.isUserInteractionEnabled = false
            self.heartButton?.setImage(isLiked ? UIImage(named: "heart_after") : UIImage(named: "heart_before") , for: .normal)
            self.likeCountLabel?.textColor = isLiked ? kPink02Color : kGrayColor
            self.isUserInteractionEnabled = true
        }
    }
    
    func updateLikeCount(_ notification: Foundation.Notification) {
        let book: Book? = notification.object as? Book
        self.book = book
    }
}

private let DetailHeaderViewBottomBaseViewMargin: CGFloat = 8.0
private let DetailHeaderViewBuyButtonMargin: CGFloat = 15.0
private let DetailHeaderViewLikeCountButtonSize: CGSize = CGSize(width: 80, height: 30)

@objc public protocol DetailHeaderViewDelegate: NSObjectProtocol {
    func headerViewBuyButtonTapped(_ view: DetailHeaderView)
    func headerViewLikeCountButtonTapped(_ view: DetailHeaderView, completion:@escaping (_ isLiked: Bool, _ numLike: Int) ->Void)
}

open class DetailHeaderView: UIView, LikeCountButtonProtocol {
    fileprivate var topBaseView: UIView?
    fileprivate var itemImageView: UIImageView?
    fileprivate var itemTitleLabel: UILabel?
    fileprivate var itemAuthorInfoLabel: UILabel?
    fileprivate var bottomBaseView: UIView?
    fileprivate var likeButton: LikeCountButton?
    fileprivate weak var delegate: DetailHeaderViewDelegate?
    fileprivate var priceTitleLabel: UILabel?
    fileprivate var priceLabel: UILabel?
    fileprivate var statusLabel: UILabel?
    fileprivate var buyButton: UIButton?
    fileprivate var bottomLineView: UIView?
    fileprivate var storePriceLabel: UILabel?
    fileprivate var publishAtLabel: UILabel?
    
    deinit {
        delegate = nil
        topBaseView = nil
        itemImageView?.image = nil
        itemImageView = nil
        itemTitleLabel = nil
        itemAuthorInfoLabel = nil
        bottomBaseView = nil
        likeButton = nil
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(delegate: DetailHeaderViewDelegate) {
        self.init()
        self.delegate = delegate
        
        self.backgroundColor = kBackGroundColor
        self.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 450)
        self.clipsToBounds = true
        
        topBaseView = UIView(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 250))
        topBaseView!.backgroundColor = UIColor.white
        self.addSubview(topBaseView!)
        
        likeButton = LikeCountButton(frame: CGRect(x: kCommonDeviceWidth - DetailHeaderViewLikeCountButtonSize.width - 15.0,
            y: 26.0,
            width: DetailHeaderViewLikeCountButtonSize.width,
            height: DetailHeaderViewLikeCountButtonSize.height))
        likeButton?.delegate = self
        self.addSubview(likeButton!)
        
        itemImageView = UIImageView()
        itemImageView!.viewOrigin = CGPoint(x: (kCommonDeviceWidth - itemImageView!.width) / 2, y: 26.0)
        itemImageView!.contentMode = .scaleAspectFill
        itemImageView!.clipsToBounds = true
        itemImageView!.layer.cornerRadius = 3.0
        itemImageView!.layer.borderWidth = 0.5
        itemImageView!.layer.borderColor = kBorderColor.cgColor
        
        topBaseView!.addSubview(itemImageView!)
        
        itemTitleLabel = UILabel()
        itemTitleLabel?.frame = CGRect(x: 30, y: itemImageView!.bottom + 10.0, width: kCommonDeviceWidth - 30 * 2, height: 0)
        itemTitleLabel!.textAlignment = .center
        itemTitleLabel!.font = UIFont.boldSystemFont(ofSize: 17)
        _ = itemTitleLabel!.text.map{itemTitleLabel!.height = $0.getTextHeight(itemTitleLabel!.font, viewWidth: itemTitleLabel!.width)}
        itemTitleLabel!.textColor = kBlackColor87
        itemTitleLabel!.numberOfLines = 0
        topBaseView!.addSubview(itemTitleLabel!)
        
        itemAuthorInfoLabel = UILabel(frame: CGRect(x: 0, y: itemTitleLabel!.bottom - 2.0, width: kCommonDeviceWidth, height: 25.0))
        itemAuthorInfoLabel!.textAlignment = .center
        itemAuthorInfoLabel!.font = UIFont.boldSystemFont(ofSize: 13)
        itemAuthorInfoLabel!.textColor = kGray03Color
        topBaseView!.addSubview(itemAuthorInfoLabel!)
            
        publishAtLabel = UILabel(frame: CGRect(x: 0, y: itemAuthorInfoLabel!.bottom - 2.0, width: kCommonDeviceWidth, height: 25.0))
        publishAtLabel!.textAlignment = .center
        publishAtLabel!.font = UIFont.boldSystemFont(ofSize: 13)
        publishAtLabel!.textColor = kGray03Color
        topBaseView!.addSubview(publishAtLabel!)
        
        storePriceLabel = UILabel()
        storePriceLabel?.y = publishAtLabel!.bottom - 2
        storePriceLabel?.width = kCommonDeviceWidth
        storePriceLabel?.height = 15.0
        storePriceLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        storePriceLabel?.textAlignment = .center
        storePriceLabel?.textColor = kGray03Color
        topBaseView!.addSubview(storePriceLabel!)
        
        topBaseView!.height = storePriceLabel!.bottom + 8.0
        
        bottomLineView = UIView(frame: CGRect(x: 0, y: topBaseView!.bottom - 0.5, width: kCommonDeviceWidth, height: 0.5))
        bottomLineView?.backgroundColor = kBlackColor12
        topBaseView!.addSubview(bottomLineView!)
        
        bottomBaseView = UIView(frame: CGRect(x: DetailHeaderViewBottomBaseViewMargin, y: topBaseView!.bottom + 8.0, width: kCommonDeviceWidth - DetailHeaderViewBottomBaseViewMargin * 2, height: 0))
        bottomBaseView!.backgroundColor = UIColor.white
        bottomBaseView!.clipsToBounds = true
        bottomBaseView!.layer.cornerRadius = 3.0
        self.addSubview(bottomBaseView!)
        
        priceTitleLabel = UILabel(frame: CGRect(x: 0, y: 25.0, width: bottomBaseView!.width, height: 0))
        priceTitleLabel?.textAlignment = .center
        priceTitleLabel?.text = "最安の出品価格"
        priceTitleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        priceTitleLabel?.textColor = kGray03Color
        priceTitleLabel?.height = priceTitleLabel!.text!.getTextHeight(priceTitleLabel!.font, viewWidth: priceTitleLabel!.width)
        bottomBaseView!.addSubview(priceTitleLabel!)
        
        priceLabel = UILabel(frame: CGRect(x: 0, y: priceTitleLabel!.bottom + 3.0, width: bottomBaseView!.width, height: 35))
        priceLabel?.textAlignment = .center
        priceLabel?.font = UIFont.boldSystemFont(ofSize: 37)
        priceLabel?.textColor = kBlackColor87
        bottomBaseView!.addSubview(priceLabel!)
        
        statusLabel = UILabel(frame: CGRect(x: 0, y: priceLabel!.bottom + 5.5, width: bottomBaseView!.width, height: 20))
        statusLabel?.textAlignment = .center
        statusLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        statusLabel?.textColor = kGray03Color
        statusLabel?.numberOfLines = 0
        bottomBaseView!.addSubview(statusLabel!)
        
        buyButton = UIButton(frame: CGRect(x: DetailHeaderViewBuyButtonMargin,
            y: statusLabel!.bottom + 19.0,
            width: bottomBaseView!.width - DetailHeaderViewBuyButtonMargin*2,
            height: UIImage(named: "img_stretch_btn_red")!.size.height))
        buyButton?.setBackgroundImage(UIImage(named: "img_stretch_btn_red")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        buyButton?.titleLabel?.textAlignment = .center
        buyButton?.setTitle("最安値で購入手続きへ", for:.normal)
        buyButton?.setTitleColor(UIColor.white, for: .normal)
        buyButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        buyButton?.clipsToBounds = true
        buyButton?.layer.cornerRadius = 4.0
        buyButton?.isUserInteractionEnabled = true
        buyButton?.addTarget(self, action: #selector(DetailHeaderView.buyButtonTapped(_:)), for: .touchUpInside)
        bottomBaseView!.addSubview(buyButton!)
        
        bottomBaseView!.height = buyButton!.bottom + 12.0
        
        self.height = bottomBaseView!.bottom
    }
    
    func likeCountButtonHeartButtonTapped(_ button: LikeCountButton, completion: @escaping () -> Void) {
        self.isUserInteractionEnabled = false
        self.delegate?.headerViewLikeCountButtonTapped(self, completion: {[weak self] (isLiked, num) in
            DispatchQueue.main.async {
                self?.likeButton?.setLike(isLiked)
                self?.isUserInteractionEnabled = true
                completion()
            }
            })
    }

    var book: Book? {
        didSet {
            
            if book?.imageWidth == nil && book?.imageHeight == nil {
                itemImageView?.viewSize = CGSize(width: kPlacejolderBookImage.size.width, height: 166.0)
                itemImageView?.x = (kCommonDeviceWidth - itemImageView!.width) / 2
            } else {
                itemImageView!.resize(CGSize(width: CGFloat(book!.imageWidth!), height: CGFloat(book!.imageHeight!)),
                                      fixedHeight: 166.0,
                                      fixedWidth: 113.0,
                                      center: kCommonDeviceWidth)
            }
            
            if book?.coverImage?.url != nil {
                itemImageView!.downloadImageWithURL(book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)
            } else {
                itemImageView!.image = kPlacejolderBookImage
            }
            
            self.likeButton!.frame = CGRect(x: 0, y: self.itemImageView!.y, width: 45, height: 30)
            self.likeButton!.x = kCommonDeviceWidth - self.likeButton!.width - 12.0
            
            self.itemTitleLabel?.frame = CGRect(x: 30, y: self.itemImageView!.bottom + 10.0, width: kCommonDeviceWidth - 30 * 2, height: 0)
            self.itemTitleLabel!.text = book?.titleText()
            
            _ = self.itemTitleLabel!.text.map{self.itemTitleLabel!.height = $0.getTextHeight(self.itemTitleLabel!.font, viewWidth: self.itemTitleLabel!.width)}
            
            self.itemAuthorInfoLabel?.frame = CGRect(x: 0, y: self.itemTitleLabel!.bottom, width: kCommonDeviceWidth, height: 5.0)
            if Utility.isEmpty(book?.author?.name) == false && Utility.isEmpty(book?.publisher?.name) == false {
                self.itemAuthorInfoLabel?.height = 25.0
                self.itemAuthorInfoLabel!.text = "\(book!.author!.name!)/\(book!.publisher!.name!)"
               
            }
            
            publishAtLabel?.frame = CGRect(x: 0, y: itemAuthorInfoLabel!.bottom - 5.0, width: kCommonDeviceWidth, height: 5.0)
            if Utility.isEmpty(book?.publishedAt) == false {
                self.publishAtLabel?.height = 25.0
                self.publishAtLabel!.text = "出版日: \(book!.publishedAt!.year)/\(book!.publishedAt!.month)/\(book!.publishedAt!.day)"
            }
            
            storePriceLabel?.y = publishAtLabel!.bottom - 2
            storePriceLabel?.text = "新品定価: ¥\(book?.listPrice?.int().thousandsSeparator() ?? "")"
            
            self.topBaseView!.height = self.storePriceLabel!.bottom + 8.0
            
            self.bottomLineView?.frame = CGRect(x: 0, y: self.topBaseView!.bottom - 0.5, width: kCommonDeviceWidth, height: 0.5)
            
            self.bottomBaseView?.frame = CGRect(x: DetailHeaderViewBottomBaseViewMargin,
                                                y: self.topBaseView!.bottom + 8.0,
                                                width: kCommonDeviceWidth - DetailHeaderViewBottomBaseViewMargin * 2,
                                                height: 0)
            
            self.priceLabel?.frame = CGRect(x: 0, y: self.priceTitleLabel!.bottom + 2.5, width: self.bottomBaseView!.width, height: 36)
            
            self.statusLabel?.frame = CGRect(x: 0, y: self.priceLabel!.bottom + 4.0, width: self.bottomBaseView!.width, height: 20)
            
            self.buyButton?.frame = CGRect(x: DetailHeaderViewBuyButtonMargin,
                                           y: self.statusLabel!.bottom + 19.0,
                                           width: self.bottomBaseView!.width - DetailHeaderViewBuyButtonMargin*2,
                                           height: UIImage(named: "img_stretch_btn_red")!.size.height)
            
            self.bottomBaseView!.height = self.buyButton!.bottom + 12.0
            
            self.height = self.bottomBaseView!.bottom
            
            likeButton?.book = book
            likeButton?.x = kCommonDeviceWidth - likeButton!.width - 15.0
        }
    }
    
    var merchandise: Merchandise? {
        didSet {
            self.statusLabel?.text = "商品の状態: \(merchandise?.statusString() ?? "")"
            
            if Utility.isEmpty(merchandise?.price) {
                self.updateBottomView()
            } else {
                self.priceLabel?.text = merchandise?.price.map{"¥\($0.int().thousandsSeparator())"}
                
                if merchandise?.isSold == true {
                    self.updateBottomView()
                    return
                }
                
                priceTitleLabel?.text = "最安の出品価格"
                buyButton?.setTitle("最安値で購入手続きへ", for:.normal)
                buyButton?.setBackgroundImage(UIImage(named: "img_stretch_btn_red")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
            }
        }
    }

    var tagArrayView: TagArrayView? {
        didSet {
            if let targetView = self.tagArrayView {
                let frame = CGRect(x: TagArrayView.horizontalMargin,
                                   y: (self.storePriceLabel?.frame.maxY)! + TagArrayView.topMargin,
                                   width: (self.topBaseView?.frame.size.width)! - TagArrayView.horizontalMargin - TagArrayView.horizontalMargin,
                                   height: 0)
                targetView.frame = frame
                targetView.sizeToFit()
                targetView.frame.size = CGSize(width: frame.size.width, height: targetView.frame.size.height)

                self.topBaseView?.addSubview(targetView)
                self.topBaseView?.frame.size.height = targetView.frame.maxY + TagArrayView.bottomMargin

                var position = (self.bottomLineView?.frame.origin)!
                position.y = (self.topBaseView?.frame.maxY)! - 0.5
                self.bottomLineView?.frame.origin = position

                position = (self.bottomBaseView?.frame.origin)!
                position.y = (self.topBaseView?.frame.maxY)! + 8.0
                self.bottomBaseView?.frame.origin = position

                var size = self.frame.size
                size.height = (self.bottomBaseView?.frame.maxY)!
                self.frame.size = size
            }
        }
    }

    fileprivate func updateBottomView() {
        priceTitleLabel?.isHidden = true
        buyButton?.isHidden = true
        
        if !Utility.isEmpty(book?.lastLowestMerchandiseId) &&
            (book?.lowestMerchandise?.id == nil || (Utility.isEmpty(book?.lowestMerchandise) || Utility.isEmpty(book?.lowestMerchandise?.id))) {
            priceLabel?.text = "売り切れです"
        } else {
            priceLabel?.text = "出品がありません"
        }

        priceLabel?.font = UIFont.boldSystemFont(ofSize: 21)
        priceLabel?.height = priceLabel!.text!.getTextHeight(priceLabel!.font, viewWidth: priceLabel!.width)
        statusLabel?.text = "\("いいね")しておくと、新たに出品があった際に\n通知を受け取ることができます"
        statusLabel?.height = statusLabel!.text!.getTextHeight(statusLabel!.font, viewWidth: statusLabel!.width)
        priceLabel?.y = priceTitleLabel!.y
        statusLabel?.y = priceLabel!.bottom + 13.0
        bottomBaseView!.height = statusLabel!.bottom + 30.0
        height = bottomBaseView!.bottom
    }
    
    func buyButtonTapped(_ sender: UIButton) {
        self.delegate?.headerViewBuyButtonTapped(self)
    }
}
