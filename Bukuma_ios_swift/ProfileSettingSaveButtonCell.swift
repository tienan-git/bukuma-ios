//
//  ProfileSettingSaveButtonCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

let saveButtonSize: CGSize = CGSize(width: kCommonDeviceWidth - saveButtonHolizonalMargin * 2, height: 40.0)
let saveButtonHolizonalMargin: CGFloat = 20
let saveButtonVerticalMargin: CGFloat = 30

@objc public protocol ProfileSettingSaveButtonCellDelegate: BaseTableViewCellDelegate {
    func saveButtonCellSaveButtonTapped(_ cell: ProfileSettingSaveButtonCell)
}

open class ProfileSettingSaveButtonCell: BaseTableViewCell {
    
    let saveButton: UIButton! = UIButton()
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets.zero
        
        saveButton.frame = CGRect(x: saveButtonHolizonalMargin, y: saveButtonVerticalMargin, width: saveButtonSize.width, height: UIImage(named: "img_stretch_btn")!.size.height)
        saveButton.clipsToBounds = true
        saveButton.layer.cornerRadius = 3.0
        saveButton.layer.borderColor = UIColor.clear.cgColor
        saveButton.setBackgroundColor(kMainGreenColor, state: .normal)
        saveButton.setBackgroundImage(UIImage(named: "img_stretch_btn")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        saveButton.setTitle("変更する", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.addTarget(self, action: #selector(self.saveButtonTapped(_:)), for: .touchUpInside)
        self.contentView.addSubview(saveButton)
        
        self.isShortBottomLine = false
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return saveButtonVerticalMargin + saveButtonSize.height
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        bottomLineView?.isHidden = true
    }
    
    func saveButtonTapped(_ sender: UIButton) {
        if (self.delegate! as! ProfileSettingSaveButtonCellDelegate).responds(to: #selector(ProfileSettingSaveButtonCellDelegate.saveButtonCellSaveButtonTapped(_:))){
            (self.delegate! as! ProfileSettingSaveButtonCellDelegate).saveButtonCellSaveButtonTapped(self)
        }
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }
    
}
