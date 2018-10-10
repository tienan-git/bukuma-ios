//
//  SegmentedButtonsView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/15.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


public protocol SegmentedButtonsViewDelegate: NSObjectProtocol {
    func segmentedButtonsViewdidSelectHeaderMenuType(_ type: SegmentedButtonType)
}

public enum SegmentedButtonType: Int {
    case left
    case right
}

private let SegmentedButtonsViewSelectIndexViewHeight: CGFloat = 2.0

open class SegmentedButtonsView: UIView {
    
    fileprivate weak var delegate: SegmentedButtonsViewDelegate?
    open var leftTitle: String?
    open var rightTitle: String?
    fileprivate let leftButton: SegmentedButton! = SegmentedButton.generateButtonWithType(.left)
    fileprivate let rightButton: SegmentedButton! = SegmentedButton.generateButtonWithType(.right)
    
    // ================================================================================
    // MARK:- 
    
    open class func headerMenuHeight() ->CGFloat {
        return SegmentedButton.headerMenuHeight()
    }

    required public init(delegate: SegmentedButtonsViewDelegate, leftTitle: String, rightTitle: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: SegmentedButtonsView.headerMenuHeight()))
        self.backgroundColor = UIColor.white
        
        self.delegate = delegate
        self.leftTitle = leftTitle
        self.rightTitle = rightTitle
        
        leftButton.setTitle(leftTitle, for: .normal)
        leftButton.x = 12.0
        leftButton.addTarget(self, action: #selector(self.leftButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(leftButton)
        
        rightButton.setTitle(rightTitle, for: .normal)
        rightButton.x = leftButton.right + 12.0
        rightButton.addTarget(self, action: #selector(self.rightButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(rightButton)
        
        let separatror: UIView! = UIView(frame: CGRect(x: 0, y: SegmentedButton.headerMenuHeight() - 0.5, width: kCommonDeviceWidth, height: 0.5))
        separatror.backgroundColor = kBorderColor
        self.addSubview(separatror)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func leftButtonTapped(_ sender: UIButton) {
        self.tapButtonWithType(.left)
    }
    
    func rightButtonTapped(_ sender: UIButton) {
        self.tapButtonWithType(.right)
    }
    
    func tapButtonWithType(_ type: SegmentedButtonType) {
        self.moveSelectIndexViewWithSelectType(type)
        self.delegate?.segmentedButtonsViewdidSelectHeaderMenuType(type)
    }
    
    open func moveSelectIndexViewWithSelectType(_ type: SegmentedButtonType) {
        DispatchQueue.main.async {
            if self.leftButton.isSelected == false && self.rightButton.isSelected == false {
                self.leftButton.isSelected = true
                self.leftButton.isUserInteractionEnabled = false
                self.rightButton.isSelected = false
                return
            }
            
            self.leftButton.isUserInteractionEnabled = true
            self.rightButton.isUserInteractionEnabled = true
            self.leftButton.isSelected = false
            self.rightButton.isSelected = false
            
            switch type {
            case .left:
                self.leftButton.isSelected = true
                self.leftButton.isUserInteractionEnabled = false
                break
            case .right:
                self.rightButton.isSelected = true
                self.rightButton.isUserInteractionEnabled = false
                break
            }
        }
    }
}

open class SegmentedButton: UIButton {
    
    open var type: SegmentedButtonType?
    
    open class func headerMenuHeight() ->CGFloat {
        return 38.0
    }
    
    open class func generateButtonWithType(_ type: SegmentedButtonType) ->SegmentedButton {
        let button: SegmentedButton = SegmentedButton(frame: CGRect(x: 0, y: 0, width: (kCommonDeviceWidth - 36.0) / 2, height: SegmentedButton.headerMenuHeight()))
        button.type = type
        button.isExclusiveTouch = true
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.setTitleColor(kGray01Color, for: .normal)
        button.setTitleColor(kTintGreenColor, for: .selected)
        button.backgroundColor = UIColor.clear
        return button
    }
}
