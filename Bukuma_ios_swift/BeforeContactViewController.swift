//
//  BeforeContactViewController.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/26/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SwiftTips

protocol FaqTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didChangeContentSize contentSize: CGSize)
}

class FaqTableView: UITableView {
    override open var contentSize: CGSize {
        didSet {
            if let faqDelegate = self.delegate as? FaqTableViewDelegate {
                faqDelegate.tableView(self, didChangeContentSize: self.contentSize)
            }
        }
    }
}

class BeforeContactViewController: BaseViewController, NibProtocol {
    typealias NibT = BeforeContactViewController

    static func generate() -> BeforeContactViewController {
        return BeforeContactViewController.fromStoryboard()!
    }

    private let titleText: String = "お問い合わせ"
    private let mainMessage: String = "お問い合わせの前にご確認ください"
    private let subMessage: String = "よくあるご質問をぜひご確認ください。\nそれでも解決しない場合はご連絡ください。"

    private let cellHeight: CGFloat = 50.0
    private let sectionHeaderHeight: CGFloat = 42.0

    @IBOutlet private weak var mainMessageBox: UILabel!
    @IBOutlet private weak var subMessageBox: UILabel!
    @IBOutlet private weak var faqTable: FaqTableView!

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.titleText
        self.mainMessageBox.text = self.mainMessage
        self.subMessageBox.text = self.subMessage

        self.faqTable.dataSource = self
        self.faqTable.delegate = self

        self.faqTable.rowHeight = self.cellHeight
        self.faqTable.sectionHeaderHeight = self.sectionHeaderHeight

        let nibCell = UINib(nibName: BeforeContactCell.nibName, bundle: nil)
        self.faqTable.register(nibCell, forCellReuseIdentifier: BeforeContactCell.reuseID)
        let nibHeader = UINib(nibName: BeforeContactSectionHeader.nibName, bundle: nil)
        self.faqTable.register(nibHeader, forHeaderFooterViewReuseIdentifier: BeforeContactSectionHeader.reuseID)
    }

    fileprivate let numberOfSections: Int = 2
    fileprivate let sectionHeaderTexts: [String] = [
        "よくある質問",
        "解決しない場合"
    ]
    fileprivate let faqTexts: [[String]] = [
        ["着払いで出品することはできるの？",
         "支払い方法は何がありますか？",
         "商品の編集・削除はどうしたらいいですか？",
         "発送通知が来ましたが、商品が届きません。",
         "購入者から受取評価をしてもらえません。",
         "取引をキャンセルしたい。",
         "説明文と違う／不備のある商品が届いた。"],
        ["運営にお問い合わせする"]
    ]
    fileprivate let faqURLs: [String] = [
        "http://static.bukuma.io/bkm_app/faq.html#section1-04",
        "http://static.bukuma.io/bkm_app/faq.html#section1-07",
        "http://static.bukuma.io/bkm_app/faq.html#section1-13",
        "http://static.bukuma.io/bkm_app/faq.html#section1-16",
        "http://static.bukuma.io/bkm_app/faq.html#section2-01",
        "http://static.bukuma.io/bkm_app/faq.html#section2-02",
        "http://static.bukuma.io/bkm_app/faq.html#section2-07"
    ]
}

extension BeforeContactViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSections
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.faqTexts[section].count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BeforeContactCell.reuseID, for: indexPath) as! BeforeContactCell
        cell.cellTitle.text = self.faqTexts[indexPath.section][indexPath.row]
        return cell
    }
}

extension BeforeContactViewController: FaqTableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: BeforeContactSectionHeader.reuseID) as? BeforeContactSectionHeader {
            header.headerTitle.text = self.sectionHeaderTexts[section]

            let backgroundView = UIView(frame: header.bounds)
            backgroundView.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 0.8)
                // BeforeContactViewController.storyboard で alpha: 1.0 で塗りつぶしているが、
                // 隣接するこの Header では alpha: 0.8 にしないと違って見えてしまう
            header.backgroundView = backgroundView

            return header
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            let urlString = self.faqURLs[indexPath.row]
            if let url = URL(string: urlString) {
                let webView = BaseWebViewController(url: url)
                self.navigationController?.pushViewController(webView, animated: true)
            }
        } else {
            let viewController = ContactViewController(type: .none, object: nil)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didChangeContentSize contentSize: CGSize) {
        let tableHeight = tableView.frame.origin.y + contentSize.height > kCommonDeviceHeight ? kCommonDeviceHeight - tableView.frame.origin.y : contentSize.height

        var tableSize = tableView.frame.size
        tableSize.height = tableHeight
        tableView.frame.size = tableSize

        var viewSize = self.view.frame.size
        viewSize.height = tableView.frame.maxY
        self.view.frame.size = viewSize
    }
}
