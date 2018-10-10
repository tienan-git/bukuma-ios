//
//  TransactionThanksView.swift
//  Bukuma_ios_swift
//
//  Created by hara on 4/28/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import UIKit

class TransactionThanksView: BaseThanksView {
    private let introduceBukumaButton: UIButton = UIButton()

    private let introduceBukumaButtonWidth: CGFloat = 222
    private let introduceBukumaButtonHeight: CGFloat = 40
    private let introduceBukumaButtonTopMargin: CGFloat = 20
    private let introduceBukumaButtonBottomMargin: CGFloat = 15
    private let introduceBukumaButtonFrameColor = kMainGreenColor.cgColor
    private let introduceBukumaButtonFrameSize: CGFloat = 2
    private let introduceBukumaButtonFrameCorner: CGFloat = 4
    private let introduceBukumaButtonTitleFontSize: CGFloat = 16
    private let introduceBukumaButtonTitleColor = kMainGreenColor
    private let introduceBukumaButtonTitleText = "友達にブクマ！を紹介する"

    required public init(delegate: SheetViewDelegate, image: UIImage, title: String, detail: String, buttonText: String) {
        super.init(delegate: delegate, image: image, title: title, detail: detail, buttonText: buttonText)

        self.borderView?.isHidden = true

        self.introduceBukumaButton.frame = CGRect(x: 0,
                                                  y: (self.detailLabel?.frame.maxY)! + self.introduceBukumaButtonTopMargin,
                                                  width: self.introduceBukumaButtonWidth,
                                                  height: self.introduceBukumaButtonHeight)
        var center = self.introduceBukumaButton.center
        center.x = (self.detailLabel?.center.x)!
        self.introduceBukumaButton.center = center

        self.introduceBukumaButton.layer.borderColor = self.introduceBukumaButtonFrameColor
        self.introduceBukumaButton.layer.borderWidth = self.introduceBukumaButtonFrameSize
        self.introduceBukumaButton.layer.cornerRadius = self.introduceBukumaButtonFrameCorner

        self.introduceBukumaButton.titleLabel?.font = UIFont.systemFont(ofSize: introduceBukumaButtonTitleFontSize)
        self.introduceBukumaButton.setTitleColor(self.introduceBukumaButtonTitleColor, for: .normal)
        self.introduceBukumaButton.setTitle(self.introduceBukumaButtonTitleText, for: .normal)

        self.introduceBukumaButton.addTarget(self, action: #selector(self.introduceBukumaButtonTapped(_:)), for: .touchUpInside)
        self.sheetView.addSubview(self.introduceBukumaButton)

        var frame = (self.actionButton?.frame)!
        frame.origin.y = self.introduceBukumaButton.frame.maxY + self.introduceBukumaButtonBottomMargin
        self.actionButton?.frame = frame
        self.actionButton?.setTitleColor(kBlackColor70, for: .normal)

        self.sheetView.frame.size.height = (self.actionButton?.frame.maxY)!
    }
    
    required public init(delegate: SheetViewDelegate?) {
        fatalError("init(delegate:) has not been implemented")
    }
    
    required public init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func introduceBukumaButtonTapped(_ sender: UIButton) {
        if let myProtocol = self.delegate as? TransactionThanksViewProtocol {
            self.finishFirstShow = true
            myProtocol.tappedIntroduceBukumaButton(self, completion: nil)
         }
    }
}

protocol TransactionThanksViewProtocol: BaseSuggestViewDelegate {
    func tappedIntroduceBukumaButton(_ view: TransactionThanksView, completion: (()-> Void)?)
}
