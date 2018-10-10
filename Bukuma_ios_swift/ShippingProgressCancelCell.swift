//
//  ShippingProgressCancelCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/10/11.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

public protocol ShippingProgressCancelCellDelegate: BaseTableViewDelegate {
    func shippingProgressCancelCellCancelButtonTapped(_ cell: ShippingProgressCancelCell)
}

private let ShippingProgressCancelCellDetailLabelWidth: CGFloat = 22.0

private let detailFont: UIFont = UIFont.systemFont(ofSize: 12)
private let detailWidth: CGFloat = kCommonDeviceWidth - 12.0 * 2 - ShippingProgressCancelCellDetailLabelWidth * 2

open class ShippingProgressCancelCell: BaseTableViewCell {
    
    fileprivate var baseView: UIView?
    fileprivate var titleLabel: UILabel?
    fileprivate var detailLabel: UILabel?
    fileprivate var cancelButton: UIButton?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        baseView = UIView()
        baseView?.clipsToBounds = true
        baseView?.layer.borderWidth = 1.0
        baseView?.layer.borderColor = kPink01Color.cgColor
        baseView?.layer.cornerRadius = 4.0
        baseView?.frame = CGRect(x: 12.0,
                                 y: 12.0,
                                 width: kCommonDeviceWidth - 12.0 * 2,
                                 height: 0)
        baseView?.backgroundColor = UIColor.white
        self.contentView.addSubview(baseView!)
        
        titleLabel = UILabel()
        titleLabel?.frame = CGRect(x: 0,
                                   y: 33.0,
                                   width: baseView!.width,
                                   height: 25.0)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel?.textColor = kBlackColor87
        titleLabel?.text = "取引のキャンセルが可能です"
        titleLabel?.textAlignment = .center
        baseView?.addSubview(titleLabel!)
        
        detailLabel = UILabel()
        detailLabel?.frame = CGRect(x: ShippingProgressCancelCellDetailLabelWidth,
                                    y: titleLabel!.bottom + 15.0,
                                    width: detailWidth,
                                    height: 0)
        detailLabel?.font = detailFont
        detailLabel?.textAlignment = .center
        detailLabel?.numberOfLines = 0
        detailLabel?.text = "お支払いを完了してから10日が以上経ちました。\nもし取引に進展がない場合は取引をキャンセル\nすることができます。商品の代金は全額返金されます"
        detailLabel?.textColor = kBlackColor70
        detailLabel?.height = detailLabel!.text!.getTextHeight(detailLabel!.font, viewWidth: detailLabel!.width)
        baseView?.addSubview(detailLabel!)
        
        cancelButton = UIButton()
        cancelButton?.frame = CGRect(x: ShippingProgressCancelCellDetailLabelWidth, y: detailLabel!.bottom + 30.0, width: baseView!.width - ShippingProgressCancelCellDetailLabelWidth * 2, height: UIImage(named: "img_stretch_btn_red")!.size.height)
        cancelButton?.setTitle("キャンセル", for: .normal)
        cancelButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cancelButton?.backgroundColor = UIColor.clear
        cancelButton?.setBackgroundImage(UIImage(named: "img_stretch_btn_red")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        cancelButton?.addTarget(self, action: #selector(self.cancelButtonTapped(_:)), for: .touchUpInside)
        baseView?.addSubview(cancelButton!)

        baseView?.height = cancelButton!.bottom + 15.0
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        let margin: CGFloat = 12.0
        let titleHeight: CGFloat = 25.0
        let detail: String = "お支払いを完了してから10日が以上経ちました。\nもし取引に進展がない場合は取引をキャンセル\nすることができます。商品の代金は全額返金されます"
        let detailHeight: CGFloat = detail.getTextHeight(detailFont, viewWidth: detailWidth)
        let buttonHeight: CGFloat = UIImage(named: "img_stretch_btn_red")!.size.height
        let contentHeight: CGFloat = titleHeight + detailHeight + buttonHeight
        
        return contentHeight + margin + 33.0 + 15.0 + 30.0 + 15.0
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        self.backgroundColor = kBackGroundColor
        self.contentView.backgroundColor = kBackGroundColor
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = kBackGroundColor
        self.contentView.backgroundColor = kBackGroundColor
    }
    
    func cancelButtonTapped(_ sender: UIButton) {
        (self.delegate as? ShippingProgressCancelCellDelegate)?.shippingProgressCancelCellCancelButtonTapped(self)
    }
}
