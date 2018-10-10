//
//  BukumaSearchBar.swift
//  Bukuma_ios_swift
//
//  Created by hara on 4/3/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import UIKit
import SwiftTips

protocol BukumaSearchBarProtocol {
    static var searchTextOffset: CGFloat { get }
    static var searchBarStyle: UISearchBarStyle { get }
    static var tintColor: UIColor { get }
    static var barTintColor: UIColor { get }
    static var backgroundColor: UIColor { get }
    static var shadowColor: UIColor { get }
    static var scopeBarBackgroundImage: UIImage { get }
    static func searchFieldBackgroundImage(from frame: CGRect)-> UIImage?
    static var isTranslucent: Bool { get }
    static var cancelButtonText: String { get }

    static var textFontSize: CGFloat { get }
    static var textAttribute: [String: Any]? { get }
    static var textPlaceholder: String { get }
    static var textAttributedPlaceholder: NSAttributedString? { get }
    static var textColor: UIColor { get }
    static var textTintColor: UIColor { get }

    static var searchBarHeight: CGFloat { get }

    static var searchTextHeight: CGFloat { get }

    static var searchHeightAdjuster: CGFloat { get }

    static var searchTextMarginLeft: CGFloat { get }
    static var searchTextMarginRight: CGFloat { get }
}

// 現状定数的に extension で共通化してしまっているが、カスタマイズしたいものは各クラスでメソッド化して、生成後に変更できるようにすべきと思う
extension BukumaSearchBarProtocol {
    static var searchTextOffset: CGFloat { get { return 8 } }
    static var searchBarStyle: UISearchBarStyle { get { return .minimal } }
    static var tintColor: UIColor { get { return UIColor.white } }
    static var barTintColor: UIColor { get { return UIColor.white } }
    static var backgroundColor: UIColor { get { return UIColor.clear } }
    static var shadowColor: UIColor { get { return UIColor.clear } }
    static var scopeBarBackgroundImage: UIImage { get { return UIImage() } }
    static func searchFieldBackgroundImage(from frame: CGRect)-> UIImage? {
        let size = CGSize(width: frame.width - (BukumaSearchBar.searchTextMarginLeft + BukumaSearchBar.searchTextMarginRight),
                          height: frame.height - (BukumaSearchBar.searchBarHeight - BukumaSearchBar.searchTextHeight))
        let image = UIImage.imageWithColor(UIColor.white, 10.0, size: size)?.roundedCenterTrimImage(cornerRadius: 3.0, targetSize: size)
        return image
    }
    static var isTranslucent: Bool { get { return false } }
    static var cancelButtonText: String { get { return "キャンセル" } }

    static var textFontSize: CGFloat { get { return 15 } }
    static var textAttribute: [String: Any]? { get
        { return [NSFontAttributeName: UIFont.systemFont(ofSize: BukumaSearchBar.textFontSize),
                  NSForegroundColorAttributeName: BukumaSearchBar.textColor] }
    }
    static var textPlaceholder: String { get { return NSLocalizedString("何をお探しでしょうか?", comment:"") } }
    static var textAttributedPlaceholder: NSAttributedString? { get
        { return NSAttributedString(string: self.textPlaceholder,
                                    attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: BukumaSearchBar.textFontSize),
                                                 NSForegroundColorAttributeName: kGray01Color]) }
    }
    static var textColor: UIColor { get { return kBlackColor80 } }
    static var textTintColor: UIColor { get { return kGray01Color } }

    static var searchBarHeight: CGFloat { get { return 56 } }

    static var searchTextHeight: CGFloat { get { return 40 } }

    static var searchHeightAdjuster: CGFloat { get { return (self.searchBarHeight - kCommonNavigationBarHeight) / 2 } }

    static var searchTextMarginLeft: CGFloat { get { return 10 } }
    static var searchTextMarginRight: CGFloat { get { return 10 } }
}

class BukumaSearchBar: UISearchBar, BukumaSearchBarProtocol {
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.searchTextPositionAdjustment = UIOffset(horizontal: BukumaSearchBar.searchTextOffset, vertical: self.searchTextPositionAdjustment.vertical)
        self.searchBarStyle = BukumaSearchBar.searchBarStyle
        self.tintColor = BukumaSearchBar.tintColor
        self.barTintColor = BukumaSearchBar.barTintColor
        self.backgroundColor = BukumaSearchBar.backgroundColor
        self.layer.shadowColor = BukumaSearchBar.shadowColor.cgColor
        self.scopeBarBackgroundImage = BukumaSearchBar.scopeBarBackgroundImage
        self.setSearchFieldBackgroundImage(BukumaSearchBar.searchFieldBackgroundImage(from: frame), for: .normal)
        self.isTranslucent = BukumaSearchBar.isTranslucent
        self.setCancelButtonText(with: BukumaSearchBar.cancelButtonText)
        self.showsCancelButton = false
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true

        if let textAttribute = BukumaSearchBar.textAttribute {
            self.textField?.defaultTextAttributes = textAttribute
        }
        self.textField?.attributedPlaceholder = BukumaSearchBar.textAttributedPlaceholder
        self.textField?.tintColor = BukumaSearchBar.textTintColor
        self.textField?.isUserInteractionEnabled = true
        self.textField?.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if let textField = self.textField {
            var frame = self.frame
            frame.size.height = BukumaSearchBar.searchBarHeight
            self.frame = frame

            frame = textField.frame
            frame.size.height = BukumaSearchBar.searchTextHeight
            textField.frame = frame

            var center = textField.center
            center.y = self.center.y
            textField.center = center
        }
    }
}

// navigationItem に追加して使うタイプは、標準の高さより高いので navigationBar 等々を調整しないと表示が崩れてしまう。
// 同じ処理内容で調整できているので、protocol & extension で必要なクラスにアタッチメント的に付加して使用する。
protocol BukumaSearchBarAdjusterProtocol {
    func adjustPosition(for navigationBar: UIView?)
    func adjustHeight(for navigationBar: UIView?)
    func addItem(as searchBar: BukumaSearchBar?, on navigationItem: UINavigationItem)
    func resetPosition(for navigationBar: UIView?)
}

extension BukumaSearchBarAdjusterProtocol {
    func adjustPosition(for navigationBar: UIView?) {
        if var barFrame = navigationBar?.frame {
            barFrame.origin.y = (kCommonStatusBarHeight + BukumaSearchBar.searchHeightAdjuster)
            navigationBar?.frame = barFrame
        }
    }

    func adjustHeight(for navigationBar: UIView?) {
        if var barFrame = navigationBar?.frame {
            barFrame.size.height = (BukumaSearchBar.searchBarHeight + kCommonStatusBarHeight)
            navigationBar?.frame = barFrame
        }
    }

    func addItem(as searchBar: BukumaSearchBar?, on navigationItem: UINavigationItem) {
        if let searchBarItem = searchBar {
            let searchView = UIView(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: BukumaSearchBar.searchBarHeight))
            navigationItem.titleView = searchView
            searchView.addSubview(searchBarItem)
        } else {
            navigationItem.titleView = nil
        }
    }

    func resetPosition(for navigationBar: UIView?) {
        if var barFrame = navigationBar?.frame {
            barFrame.origin.y = kCommonStatusBarHeight
            navigationBar?.frame = barFrame
        }
    }
}
