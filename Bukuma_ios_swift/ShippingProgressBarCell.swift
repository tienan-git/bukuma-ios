//
//  ShippingProgressCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/31.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public protocol ShippingProgressBarCellDelegate: BaseTableViewCellDelegate {
    func shippingProgressBarButtonTapped(_ cell: ShippingProgressBarCell, completion:@escaping () ->Void)
}

open class ShippingProgressBarCell: BaseTableViewCell {
    
    fileprivate let titleLabel: UILabel! = UILabel()
    fileprivate let detailLabel: UILabel! = UILabel()
    fileprivate var progressBarImageView: UIImageView?
    fileprivate let evaluateExhibitorButton: EvaluateExhibitorButton! = EvaluateExhibitorButton()
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        titleLabel.frame = CGRect(x: 0, y: 15.0, width: kCommonDeviceWidth, height: 30)
        titleLabel.textAlignment = .center
        titleLabel.textColor = kBlackColor87
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.contentView.addSubview(titleLabel)
        
        detailLabel.frame = CGRect(x: 15.0, y: titleLabel.bottom, width: kCommonDeviceWidth - 15.0 * 2, height: 20)
        detailLabel.textAlignment = .center
        detailLabel.textColor = kGrayColor
        detailLabel.numberOfLines = 2
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(detailLabel)
        
        progressBarImageView = UIImageView(image: self.progressBarImage(0))
        progressBarImageView?.viewOrigin = CGPoint(x: (kCommonDeviceWidth - progressBarImageView!.width) / 2,
                                               y: detailLabel.bottom)
        if UIScreen.is4inchDisplay() || UIScreen.is3_5inchDisplay() {
            progressBarImageView?.width = self.progressBarImage(0)!.size.width - 12.0 * 2
            progressBarImageView?.x = (kCommonDeviceWidth - progressBarImageView!.width) / 2
        }
        
        self.contentView.addSubview(progressBarImageView!)
        
        evaluateExhibitorButton.viewSize = CGSize(width: 200, height: 35.0)
        evaluateExhibitorButton.viewOrigin = CGPoint(x: (kCommonDeviceWidth - evaluateExhibitorButton!.width) / 2, y: progressBarImageView!.bottom + 15.0)
        evaluateExhibitorButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        evaluateExhibitorButton.addTarget(self, action: #selector(self.evaluateExhibitorButtonTapped(_:)), for: .touchUpInside)
        self.contentView.addSubview(evaluateExhibitorButton)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func progressBarImage(_ progress: Int) ->UIImage? {
        if progress > 3 {
            return nil
        }
        return UIImage(named: "img_progress_0\(progress)")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let transaction: Transaction = object as! Transaction
        if transaction.isBuyer() == false && (transaction.type == .sellerPrepareShipping || transaction.type == .sellerShipped) {
            return 200
        }
        return 165.0
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let transaction: Transaction? = cellModelObject as? Transaction
            
            evaluateExhibitorButton.transaction = transaction
            if transaction?.isBuyer() == true {
                switch transaction!.type! {
                case .sellerPrepareShipping:
                    titleLabel.text = "出品者が発送準備中です"
                    detailLabel.text = "出品者からの発送通知をお待ち下さい"
                    progressBarImageView?.image = self.progressBarImage(0)
                    break
                case .sellerShipped:
                    titleLabel.text = "出品者が発送しました"
                    detailLabel.text = "商品の到着をお待ち下さい。"
                    progressBarImageView?.image = self.progressBarImage(1)
                    break
                case .buyerItemArried:
                    titleLabel.text = "出品者を評価済みです"
                    detailLabel.text = "出品者があなたのレビューを書き終わるまでお待ち下さい"
                    progressBarImageView?.image = self.progressBarImage(2)
                    break
                case .sellerReviewBuyer, .finishedTransaction:
                    titleLabel.text = "出品者を評価済みです"
                    detailLabel.text = "これで取引は完了です"
                    progressBarImageView?.image = self.progressBarImage(2)
                    break
                case .pendingReviewByStuff:
                    titleLabel.text = "この取引はキャンセルされました"
                    detailLabel.text = "詳しくはお問い合わせフォームよりお願いします"
                    progressBarImageView?.image = self.progressBarImage(0)
                    break
                default:
                    progressBarImageView?.image = self.progressBarImage(0)
                    break
                }
            } else {
                switch transaction!.type! {
                case .initial:
                    titleLabel.text = "まだ取引が始まっていません"
                    detailLabel.text = "購入通知をお待ち下さい"
                    progressBarImageView?.image = self.progressBarImage(0)
                    break
                case .sellerPrepareShipping:
                    titleLabel.text = "発送準備を行って下さい"
                    detailLabel.text = "発送完了したら購入者に伝えましょう"
                    progressBarImageView?.image = self.progressBarImage(0)
                    break
                case .sellerShipped:
                    titleLabel.text = "発送完了しました"
                    detailLabel.text = "購入者が受け取るまでお待ち下さい"
                    progressBarImageView?.image = self.progressBarImage(1)
                    break
                case .buyerItemArried:
                    titleLabel.text = "購入者が受け取りました"
                    detailLabel.text = "購入者のレビューを書いて評価しましょう"
                    progressBarImageView?.image = self.progressBarImage(2)
                    break
                case .sellerReviewBuyer:
                    titleLabel.text = "出品者を評価済みです"
                    detailLabel.text = "取引終了の通知が来るまでお待ち下さい"
                    progressBarImageView?.image = self.progressBarImage(2)
                    break
                case .finishedTransaction:
                    titleLabel.text = "取引は終了しました"
                    detailLabel.text = "お疲れさまでした"
                    progressBarImageView?.image = self.progressBarImage(2)
                    break
                case .pendingReviewByStuff, .cancelled:
                    titleLabel.text = "この取引はキャンセルされました"
                    detailLabel.text = "詳しくはお問い合わせフォームよりお願いします"
                    progressBarImageView?.image = self.progressBarImage(0)
                    break
                case .unknown:
                    titleLabel.text = "不明な取引です"
                    detailLabel.text = "お問い合わせお願いします"
                    progressBarImageView?.image = self.progressBarImage(0)
                    break
                }
            }
        }
    }
    
    func evaluateExhibitorButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.isUserInteractionEnabled = false
            (self.delegate as? ShippingProgressBarCellDelegate)?.shippingProgressBarButtonTapped(self, completion: {[weak self] in
                DispatchQueue.main.async {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute:  {
                        self?.isUserInteractionEnabled = true
                    })
                }
            })
        }
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(isSelected, animated: animated)
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
}

class EvaluateExhibitorButton: UIButton {
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isExclusiveTouch = false
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        self.layer.borderWidth = 2.0
        self.layer.borderColor = kMainGreenColor.cgColor
        self.layer.cornerRadius = self.height / 2
        self.setBackgroundColor(UIColor.white, state: .normal)
        self.setBackgroundColor(UIColor.white, state: .selected)
        self.setBackgroundColor(UIColor.white, state: .highlighted)
        
        self.setTitle("出品者を評価する", for: .normal)
        self.titleLabel!.font = UIFont.systemFont(ofSize: 13)
        self.setTitleColor(kMainGreenColor, for: .normal)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonString(_ transaction: Transaction) {
        
    }
    
    var transaction: Transaction? {
        didSet {
            if transaction == nil {
                return
            }
            if transaction?.isBuyer() == false {
                if transaction!.type == .sellerPrepareShipping {
                    self.isUserInteractionEnabled = true
                    self.setTitle("発送完了を購入者に伝える", for: .normal)
                    self.setBackgroundColor(UIColor.white, state: .normal)
                    self.setBackgroundColor(UIColor.colorWithHex(0xf2f2f2), state: .highlighted)
                    self.setTitleColor(kMainGreenColor, for: .normal)
                } else if transaction!.type == .sellerShipped {
                    self.isUserInteractionEnabled = false
                    self.setTitle("発送完了を伝えました", for: .normal)
                    self.setBackgroundColor(kMainGreenColor, state: .normal)
                    self.setTitleColor(UIColor.white, for: .normal)
                } else {
                    self.isHidden = true
                    self.isUserInteractionEnabled = false
                }
            } else {
                self.isHidden = true
                self.isUserInteractionEnabled = false
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.height / 2
    }
}
