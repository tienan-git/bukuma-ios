
//
//  ExhibitBookStatusCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

public protocol ExhibitBookStatusCellDelegate: BaseTableViewCellDelegate {
    func exhibitBookStatusCellButtonTapped(_ tag: Int)
}

open class ExhibitBookStatusCell: BaseTextFieldCell {
    
    var buttons: [UIButton]? = Array()
    var ballons: [UIImageView]? = Array()
    var isSelectedImages: [UIImageView]? = Array()
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        self.titleText = "商品の状態"
        
        self.textFieldType = 2
        self.isShortBottomLine = true
        self.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel!.textColor = kDarkGray03Color
        titleLabel?.width = titleLabel!.text!.getTextWidthWithFont(titleLabel!.font, viewHeight: titleLabel!.height)
        titleLabel!.x = 15.0
        
        selectionStyle = .none
        textField!.isHidden = true
        textField!.isUserInteractionEnabled = false
        
        for i in 0...3 {
            let imageViewButton: UIButton! = UIButton()
            let unisSelectedImage: UIImage = UIImage(named: "btn_condition_0\(i)")!
            let isSelectedImage: UIImage = UIImage(named: "btn_condition_0\(i)_selected")!
            imageViewButton.viewSize = CGSize(width: unisSelectedImage.size.width, height: unisSelectedImage.size.height)
            imageViewButton.setImage(unisSelectedImage, for: .normal)
            imageViewButton.setImage(isSelectedImage, for: .selected)
            imageViewButton.setImage(isSelectedImage, for: .highlighted)
            imageViewButton.contentMode = .scaleAspectFill
            imageViewButton.y = (60.0 - imageViewButton.height) / 2
            imageViewButton.x = kCommonDeviceWidth
            imageViewButton.x -= 10
            imageViewButton.x -= (imageViewButton.width * (CGFloat(i) + 1))
            imageViewButton.x -= 4.0 * (CGFloat(i) + 1)
           // imageViewButton.x = kCommonDeviceWidth - 10.0 - (imageViewButton.width * (CGFloat(i) + 1)) - (4.0 * (CGFloat(i) + 1))
            imageViewButton.clipsToBounds = true
            imageViewButton.tag = i
           
            imageViewButton.backgroundColor = UIColor.clear
            imageViewButton.addTarget(self, action: #selector(self.buttonTaapped(_:)), for: .touchUpInside)
            buttons?.append(imageViewButton)
            self.contentView.addSubview(imageViewButton)
            
            if i == 0 {
                imageViewButton.isSelected = false
            } else {
                imageViewButton.isSelected = false
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonTaapped(_ sender: UIButton) {
        for b in buttons! {
            b.isSelected = false
        }
        sender.isSelected = true
        
        (self.delegate as? ExhibitBookStatusCellDelegate)?.exhibitBookStatusCellButtonTapped(sender.tag)
    }
    
    open override var cellModelObject: AnyObject? {
        didSet {
            let merchandise: Merchandise? = cellModelObject as? Merchandise
            
            for b in buttons! {
                b.isSelected = false
                if b.tag == merchandise?.quality {
                    b.isSelected = true
                }
            }            
        }
    }
}
