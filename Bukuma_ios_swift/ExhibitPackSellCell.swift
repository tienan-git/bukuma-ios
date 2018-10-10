//
//  ExhibitPackSellCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/29.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

@objc public protocol ExhibitPackSellCellDelegate: BaseTableViewCellDelegate {
    func exhibitPackSellCellSwitchDidChanged(_ cell: ExhibitPackSellCell)
}

open class ExhibitPackSellCell: BaseTableViewCell {
    
    fileprivate let packSellTextLabel: UILabel! = UILabel()
    fileprivate let packSellSwitch: UISwitch! = UISwitch()
    open var isOn: Bool? {
        get {
            return packSellSwitch.isOn
        }
        set (newValue){
            packSellSwitch.backgroundColor = newValue == true ? kMainGreenColor : kGrayColor
        }
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.contentView.backgroundColor = UIColor.white
        
        self.selectionStyle = .none
        packSellTextLabel.frame = CGRect(x: 15.0, y: 0, width: 250, height: 20)
        packSellTextLabel.font = UIFont.boldSystemFont(ofSize: 15)
        packSellTextLabel.textColor = kDarkGray03Color
        packSellTextLabel.textAlignment = .right
        packSellTextLabel.text = "連載書籍を複数まとめて出品"
        self.contentView.addSubview(packSellTextLabel)
        
        packSellSwitch.viewOrigin = CGPoint(x: kCommonDeviceWidth - packSellSwitch.width - 10, y: (self.height - packSellSwitch.height) / 2)
        packSellSwitch.tintAdjustmentMode = .normal
        packSellSwitch.onTintColor = kMainGreenColor
        packSellSwitch.backgroundColor = kGrayColor
        packSellSwitch.tintColor = UIColor.clear
        packSellSwitch.clipsToBounds = true
        packSellSwitch.layer.cornerRadius = packSellSwitch.height / 2
        packSellSwitch.addTarget(self, action: #selector(self.packSellSwitchDidChanged(_:)), for: .valueChanged)
        self.contentView.addSubview(packSellSwitch)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        packSellTextLabel.y = (self.height - packSellTextLabel.height) / 2
        packSellSwitch.y = (self.height - packSellSwitch.height) / 2
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 50
    }
    
    func packSellSwitchDidChanged(_ sender: UISwitch) {
        
        if (self.delegate! as! ExhibitPackSellCellDelegate).responds(to: #selector(ExhibitPackSellCellDelegate.exhibitPackSellCellSwitchDidChanged(_:))){
            (self.delegate! as! ExhibitPackSellCellDelegate).exhibitPackSellCellSwitchDidChanged(self)
        }
    }
    

}
