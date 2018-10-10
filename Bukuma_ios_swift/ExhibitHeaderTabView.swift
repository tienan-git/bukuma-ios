//
//  ExhibitHeaderTabView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/13.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public protocol ExhibitHeaderTabViewDelegate {
    func exhibitHeaderTabViewTabisSelected(_ view: ExhibitHeaderTabView, tag: Int)
}

open class ExhibitHeaderTabView: UIView {
    
    fileprivate var delegate: ExhibitHeaderTabViewDelegate?
    fileprivate let headerViewHeight:  CGFloat = 77.0
    fileprivate let tabHeight: CGFloat = 57.0
    fileprivate let holizonMargin: CGFloat = 15.0
    fileprivate let verticalMargin: CGFloat = 10.0
    fileprivate var tabs: [UIButton] = []
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(delegate: ExhibitHeaderTabViewDelegate) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: headerViewHeight))
        
        self.delegate = delegate
        self.backgroundColor = UIColor.white
        
        for i in 0...1 {
            let tab: UIButton = UIButton()
            tab.viewSize = CGSize(width: (kCommonDeviceWidth - holizonMargin * 3) / 2,
                              height: tabHeight)
            tab.viewOrigin = CGPoint(x: holizonMargin * (i.cgfloat() + 1) + tab.width * i.cgfloat(),
                                 y: verticalMargin)
            if i == 0 {
                tab.setImage(UIImage(named: "btn_sell_single"), for: .normal)
                tab.setImage(UIImage(named: "btn_sell_single_on"), for: .selected)
                tab.isSelected = true
            } else {
                tab.setImage(UIImage(named: "btn_sell_multi"), for: .normal)
                tab.setImage(UIImage(named: "btn_sell_multi_on"), for: .selected)
                tab.layer.borderWidth = 1.0
                tab.layer.borderColor = UIColor.colorWithHex(0xc3c8cf).cgColor
            }
            tab.setBackgroundColor(UIColor.white, state: .normal)
            tab.setBackgroundColor(kMainGreenColor, state: .selected)
            tab.clipsToBounds = true
            tab.layer.cornerRadius = 4.0
            tab.isExclusiveTouch = true
            tab.tag = i
            tab.addTarget(self, action: #selector(self.tabisSelected(_:)), for: .touchUpInside)
            tabs.append(tab)
            self.addSubview(tab)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tabisSelected(_ sender: UIButton) {
        for tab in tabs {
            tab.isSelected = false
            tab.layer.borderWidth = 1.0
            tab.layer.borderColor = UIColor.colorWithHex(0xc3c8cf).cgColor
        }
        sender.isSelected = true
        sender.layer.borderWidth = 0
        sender.layer.borderColor = UIColor.clear.cgColor
        
        delegate?.exhibitHeaderTabViewTabisSelected(self, tag: sender.tag)
    }

}
