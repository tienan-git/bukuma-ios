//
//  MaintenanceView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/15.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import GLDTween

let MaintenanceViewJumpToNewsControllerNotification = "MaintenanceViewJumpToNewsControllerNotification"

open class MaintenanceView: SheetView {
    
    fileprivate var titleLabel: UILabel?
    fileprivate var detailLabel: UILabel?
    fileprivate var linkButton: UIButton?
    
    var isAppear: Bool {
        return superview != nil
    }
    
    open class var shared: MaintenanceView {
        struct Static {
            static let instance = MaintenanceView(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonDeviceHeight))
        }
        return Static.instance
    }
    
    required public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.defaultSetUp()
        
        titleLabel = UILabel()
        titleLabel?.frame = CGRect(x: 0,
                                   y: 33.0,
                                   width: sheetView.width,
                                   height: 25.0)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel?.textColor = kBlackColor87
        titleLabel?.text = "ただいまメンテナンス中です"
        titleLabel?.textAlignment = .center
        sheetView.addSubview(titleLabel!)
        
        detailLabel = UILabel()
        detailLabel?.frame = CGRect(x: 22.0,
                                    y: titleLabel!.bottom + 15.0,
                                    width: sheetView.width - 22.0 * 2,
                                    height: 0)
        detailLabel?.font = UIFont.systemFont(ofSize: 12)
        detailLabel?.textAlignment = .center
        detailLabel?.numberOfLines = 0
        detailLabel?.text = "メンテナンス終了まで数時間かかる場合がございます。\n少々お待ちください"
        detailLabel?.textColor = kBlackColor70
        detailLabel?.height = detailLabel!.text!.getTextHeight(detailLabel!.font, viewWidth: detailLabel!.width)
        sheetView.addSubview(detailLabel!)
        
        linkButton = UIButton()
        linkButton?.viewSize = CGSize(width: detailLabel!.width, height: UIImage(named: "img_stretch_btn")!.size.height)
        linkButton?.viewOrigin = CGPoint(x: (sheetView.width - linkButton!.width) / 2, y: detailLabel!.bottom + 24)
        linkButton?.setBackgroundColor(kMainGreenColor, state: .normal)
        linkButton?.clipsToBounds = true
        linkButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        linkButton?.setTitle("詳細を確認する", for: .normal)
        linkButton?.setTitleColor(UIColor.white, for: .normal)
        linkButton?.setBackgroundImage(UIImage(named: "img_stretch_btn")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        linkButton?.addTarget(self, action: #selector(self.linkButtonTapped(sender:)), for: .touchUpInside)
        sheetView.addSubview(linkButton!)

        sheetView.height = linkButton!.bottom + 30.0

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(delegate: SheetViewDelegate?) {
        fatalError("init(delegate:) has not been implemented")
    }
    
    func linkButtonTapped(sender: UIButton) {
        guard let maintenanceURL = ExternalServiceManager.maintenanceURL,
              let url = URL(string: maintenanceURL) else {
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(MaintenanceViewJumpToNewsControllerNotification), object: url)
    }
    
    func appear(to parentView: UIView) {
        if (self.superview != nil) {
            return
        }
        
        if let maintenanceTime = ExternalServiceManager.maintenanceTime {
            detailLabel?.text = "メンテナンスはあと\(maintenanceTime)程度で終了予定です。\n少々お待ちください"
        } else {
            detailLabel?.text = "メンテナンス終了まで数時間かかる場合がございます。\n少々お待ちください"
        }

        parentView.addSubview(self)
        
        UIView.animate(withDuration:0.3, animations: {
            self.alpha = 1.0
        }) { (finish) in
            self.sheetView.center.y = kCommonDeviceHeight / 2
            self.sheetView.center = self.center
            let targetCenter: CGPoint = self.sheetView.center
            self.sheetView.alpha = 0.0
            self.sheetView.center.y += 80.0
            
            GLDTween.add(self.sheetView,
                         withParams: ["duration": 0.3,
                                      "delay": 0.0,
                                      "alpha": 1.0,
                                      "easing": GLDEasingOutBack,
                                      "center" : NSValue(cgPoint: targetCenter)])
        }

    }
    
}
