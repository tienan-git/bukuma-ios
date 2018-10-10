//
//  ExhibitThanksView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/06/29.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class BaseThanksView: BaseSuggestView {
    
    required public init(delegate: SheetViewDelegate, image: UIImage, title: String, detail: String, buttonText: String) {
        super.init(delegate: delegate, image: image, title: title, detail: detail, buttonText: buttonText)
        
        imageView?.viewOrigin = CGPoint(x: 0, y: 0)
        
        sheetView.width = imageView!.width
        
        titleLabel?.width = sheetView.width
        
        detailLabel?.width = sheetView.width - BaseSuggestViewDetailLabelWidth * 2
        detailLabel?.height = detailLabel!.text!.getTextHeight(detailLabel!.font, viewWidth: detailLabel!.width)
        
        borderView?.y = detailLabel!.bottom + 30.0
        borderView?.width = sheetView.width
        actionButton?.y = borderView!.bottom
        actionButton?.width = sheetView.width
        
        sheetView.x = (kCommonDeviceWidth - self.sheetView.width) / 2
        
        cancelButton?.isHidden = true
        
        sheetView.height = actionButton!.bottom
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

    override func action() {
        self.disappear {
            DispatchQueue.main.async {
                (self.delegate as? BaseSuggestViewDelegate)?.baseSuggestViewActionButtonTapped(self, completion: nil)
            }
        }
    }
}
