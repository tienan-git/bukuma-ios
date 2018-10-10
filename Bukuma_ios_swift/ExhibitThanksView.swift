//
//  ExhibitThanksView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/25.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

public protocol ExhibitThanksViewDelegate: BaseSuggestViewDelegate {
    func exhibitThanksViewShareTwitter(_ view: ExhibitThanksView)
    func exhibitThanksViewGoBackHome(_ view: ExhibitThanksView)
}

open class ExhibitThanksView: BaseThanksView {
    
    var shareTwitterButton: UIButton?
    var backHomeButton: UIButton?
    var isEditMeachandise: Bool = false {
        didSet {
            if isEditMeachandise == true {
                backHomeButton?.removeFromSuperview()
                sheetView.height = shareTwitterButton!.bottom + 30.0
            }
        }
    }
    
    required public init(delegate: SheetViewDelegate, image: UIImage, title: String, detail: String, buttonText: String) {
        super.init(delegate: delegate, image: image, title: title, detail: detail, buttonText: buttonText)
        
        borderView?.backgroundColor = UIColor.clear
        
        actionButton?.y = detailLabel!.bottom + 20.0
        actionButton?.width = sheetView.width - 30 * 2
        actionButton?.height = 40.0
        actionButton?.x = 30.0
        actionButton?.setTitleColor(UIColor.white, for: .normal)
        actionButton?.setBackgroundColor(UIColor.clear, state: .normal)
        actionButton?.setBackgroundImage(UIImage(named: "img_stretch_btn")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        
        shareTwitterButton = UIButton()
        shareTwitterButton?.viewSize = actionButton!.viewSize
        shareTwitterButton?.viewOrigin = CGPoint(x: actionButton!.x, y: actionButton!.bottom + 10.0)
        shareTwitterButton?.clipsToBounds = true
        shareTwitterButton?.setTitle("商品をシェアする", for: .normal)
        shareTwitterButton?.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        shareTwitterButton?.setTitleColor(kMainGreenColor, for: .normal)
        shareTwitterButton?.setBackgroundImage(UIImage(named: "img_stretch_btn_03")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        shareTwitterButton?.addTarget(self, action: #selector(self.shareTwitterButtonTapped(_:)), for: .touchUpInside)
        sheetView.addSubview(shareTwitterButton!)
        
        backHomeButton = UIButton()
        backHomeButton?.viewSize = CGSize(width: sheetView!.width, height: 50.0)
        backHomeButton?.viewOrigin = CGPoint(x: 0, y: shareTwitterButton!.bottom)
        backHomeButton?.clipsToBounds = true
        backHomeButton?.setTitle("ホームに戻る", for: .normal)
        backHomeButton?.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        backHomeButton?.setTitleColor(kDarkGray02Color, for: .normal)
        backHomeButton?.addTarget(self, action: #selector(self.goBackHomeButtonTapped(_:)), for: .touchUpInside)
        sheetView.addSubview(backHomeButton!)
        
        sheetView.height = backHomeButton!.bottom
        sheetView.y = kCommonDeviceHeight
        
    }
    
    required public init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(delegate: SheetViewDelegate?) {
        fatalError("init(delegate:) has not been implemented")
    }
    
    func shareTwitterButtonTapped(_ sender: UIButton) {
        self.disappear {
            (self.delegate as? ExhibitThanksViewDelegate)?.exhibitThanksViewShareTwitter(self)
        }
    }
    
    func goBackHomeButtonTapped(_ sender: UIButton) {
        self.disappear { 
            (self.delegate as? ExhibitThanksViewDelegate)?.exhibitThanksViewGoBackHome(self)
        }
    }
}
