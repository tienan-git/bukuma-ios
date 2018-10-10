//
//  RegisterPhoneNumberCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class RegisterPhoneNumberCell: BaseTextFieldCell {
    
    var iconView: UIImageView? = UIImageView()
    var type: RegisterPhoneNumberViewControllerType? {
        didSet {
            self.placeholderText = self.type! == .input ? "電話番号" : "認証番号を入力"
            iconView!.image = self.type! == .input ? UIImage(named: "ic_set_phone")! : UIImage(named: "ic_set_lock")!
        }
    }
    
    override func releaseSubViews() {
        super.releaseSubViews()
        iconView = nil
        
    }
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        let image: UIImage = UIImage(named: "ic_set_phone")!
        iconView!.image = image
        iconView!.viewSize = CGSize(width: image.size.width, height: image.size.height)
        self.contentView.addSubview(iconView!)
        
        textField!.textAlignment = .left
        textField!.keyboardType = .numberPad
        textField!.font = UIFont.systemFont(ofSize: 23)
        bottomLineView!.isHidden = false
        
        self.selectionStyle = .none
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        textField!.x = iconView!.right
        textField!.width = kCommonDeviceWidth - iconView!.right
        bottomLineView!.frame = CGRect(x: 10.0, y: self.height - 0.5, width: kCommonDeviceWidth - 10.0, height: 0.5)

    }
    
    override func textFieldDidBeginEditing() {}

    
}
