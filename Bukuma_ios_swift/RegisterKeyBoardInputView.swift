//
//  RegisterKeyBoardInputView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


@objc public protocol RegisterKeyBoardInputViewDelegate: NSObjectProtocol {
    func registerKeyBoardInputViewTapped(_ view: RegisterKeyBoardInputView)
}

open class RegisterKeyBoardInputView: UIView {
    
    weak var delegate: RegisterKeyBoardInputViewDelegate?
    let label: UILabel! = UILabel()
    
    open var text: String? {
        get {
            return label.text
        }
        set(newValue) {
            label.text = newValue
        }
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(delegate: RegisterKeyBoardInputViewDelegate) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 50.0))
        
        
        self.backgroundColor = kMainGreenColor
        self.delegate = delegate
        
        label.frame = self.frame
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        self.addSubview(label)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        self.addGestureRecognizer(tap)
       
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewTapped(_ sender: UITapGestureRecognizer) {
        self.delegate?.registerKeyBoardInputViewTapped(self)
    }
        
}
