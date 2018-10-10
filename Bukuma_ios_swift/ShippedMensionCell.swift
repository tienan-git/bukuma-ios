//
//  ShippedMensionCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/20.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class ShippedMensionCell: BaseMensionCell {
    
    override class func mensionImage() ->UIImage? {
        return UIImage(named: "img_int_ship")
    }
    
    override class func actionTitle() ->String? {
        return "商品を発送しました"
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func setMessage(_ message: Message, isSameWeekDay: Bool, isSequenced: Bool) {
        super.setMessage(message, isSameWeekDay: isSameWeekDay, isSequenced: isSequenced)
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
    }

}
