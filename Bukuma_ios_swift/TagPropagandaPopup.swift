//
//  TagPropagandaPopup.swift
//  Bukuma_ios_swift
//
//  Created by khara on 7/14/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

class TagPropagandaPopupView: UIView, NibProtocol {
    typealias NibT = TagPropagandaPopupView

    static func showOnce(onViewController viewController: UIViewController) {
        guard self.shouldGoAhead() else {
            return
        }
        guard let me = self.fromNib() else {
            return
        }
        me.setup(withViewController: viewController)
    }

    static private let saveKey = "com.labbit.bukuma.TagPropagandaPopupView"

    static private func shouldGoAhead() -> Bool {
        if UserDefaults.standard.object(forKey: self.saveKey) == nil {
            UserDefaults.standard.set(Date.timeIntervalSinceReferenceDate, forKey: self.saveKey)
            return true
        } else {
            return false
        }
    }

    private let animationDuration = Double(0.3)
    private let animationCurveAtShow = UIViewAnimationOptions.curveEaseOut
    private let animationCurveAtClose = UIViewAnimationOptions.curveEaseIn

    private func setup(withViewController viewController: UIViewController) {
        UIView.animate(withDuration: self.animationDuration, delay: 0, options: self.animationCurveAtShow, animations: {
            self.frame = viewController.view.bounds
            viewController.view.addSubview(self)
        }, completion: nil)
    }

    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tagStringsLabel: UILabel!

    private let popupCorner = CGFloat(4.0)
    private let titleString = "タグ機能が追加されました！"
    private let descriptionString = "本にタグをつけられるようになりました！\n本の詳細ページからタグをタップすると、同じタグが付いている本の一覧を見ることもできます。\nぜひご利用ください！"
    private let tagStrings = "#夏に読みたい小説  #芥川賞歴代受賞作品  #「マンガでわかる」シリーズ"

    override open func awakeFromNib() {
        super.awakeFromNib()

        self.frameView.layer.cornerRadius = self.popupCorner

        self.titleLabel.text = self.titleString
        self.titleLabel.sizeToFit()
        self.descriptionLabel.text = self.descriptionString
        self.descriptionLabel.sizeToFit()
        self.tagStringsLabel.text = self.tagStrings
        self.tagStringsLabel.sizeToFit()
    }

    @IBAction func tappedCloseButon(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        UIView.animate(withDuration: self.animationDuration, delay: 0, options: self.animationCurveAtClose, animations: {
            self.removeFromSuperview()
        }, completion: nil)
    }
}
