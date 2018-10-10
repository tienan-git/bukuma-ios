//
//  SearchMerchandiseCollectionCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2017/01/11.
//  Copyright © 2017年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import UIKit

private let imageViewHM: CGFloat = 23.0
private let imageViewVM: CGFloat = 18.0

private let titleVM: CGFloat = 8.0
private let titleHeight: CGFloat = 12.0
private let additilnalMargin: CGFloat = 10.0

private let titleFont: UIFont = UIFont.boldSystemFont(ofSize: 11)

class SearchMerchandiseCollectionCell: UICollectionViewCell {
    
    private var imageView: UIImageView!
    private var titleLabel: UILabel!

    
    var title: String? {
        didSet {
            guard let t = title else { return }
            titleLabel.text = t
            titleLabel.width = t.getTextWidthWithFont(titleFont, viewHeight: titleHeight)
            titleLabel.center.x = imageView.center.x
        }
    }
    
    var category: Category? {
        didSet {
            guard let c = category else { return }
            imageView.image = self.imageList(category: c)
        }
    }
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        //self.layer.borderWidth = 1
        
        imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: SearchMerchandiseCollectionCell.imageViewSize().width, height: SearchMerchandiseCollectionCell.imageViewSize().height)
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor.clear
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2
        self.contentView.addSubview(imageView)
        
        titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: imageView.bottom + titleVM, width: 0, height: titleHeight)
        titleLabel.textColor = UIColor.colorWithHex(0x677872)
        titleLabel.textAlignment = .center
        titleLabel.font = titleFont
        //titleLabel.layer.borderWidth = 1
        self.contentView.addSubview(titleLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open class func imageViewSize() ->CGSize {
        return CGSize(width: 98.0, height: 98.0)
    }
    
    open class func cellSize() ->CGSize {
        return CGSize(width: self.imageViewSize().width, height: self.imageViewSize().height + titleVM + titleHeight + additilnalMargin)
    }
    
    func imageList(category: Category) ->UIImage {
        guard let id = category.id else {
            fatalError()
        }
        switch id {
        case "329":
            return UIImage(named: "img_novel")! // 小説
        case "294":
            return UIImage(named: "img_humanities")! // 人文
        case "281":
            return UIImage(named: "img_society")! // 社会
        case "279":
            return UIImage(named: "img_nonfiction")! // ノンフィクション
        case "270":
            return UIImage(named: "img_history")!// 歴史
        case "15":
            return UIImage(named: "img_business")!// Business
        case "30":
            return UIImage(named: "img_investment")!// 投資
        case "2":
            return UIImage(named: "img_itcomputer")! // IT
        case "134":
            return UIImage(named: "img_house")!//美容健康ダイエット
        case "74":
            return UIImage(named: "img_hobby")!// 趣味
        case "239":
            return UIImage(named: "img_magazine")!// 雑誌
        case "213":
            return UIImage(named: "img_comic")!// コミック
        case "198":
            return UIImage(named: "img_baby")! // 絵本
        case "161":
            return UIImage(named: "img_languageStudy")!// 語学
        case "117":
            return UIImage(named: "img_license")!// 資格
        case "188":
            return UIImage(named: "img_education")! // 教育
        case "41":
            return UIImage(named: "img_technology")! // 科学
        case "242":
            return UIImage(named: "img_hospital")! // 医学
        case "108":
            return UIImage(named: "img_sports")! // スポーツ
        case "155":
            return UIImage(named: "img_travelguide")! //  旅行
        case "57":
            return UIImage(named: "img_artdesign")! // 建築・デザイン
        case "241":
            return UIImage(named: "img_music")! // 楽譜
        case "229":
            return UIImage(named: "img_entertainment")! // エンターテイメント
        case "221":
            return UIImage(named: "img_lightNovel")! // ライトノベル
        case "227":
            return UIImage(named: "img_talent")! //タレント
        case "341":
            return UIImage(named: "img_westbook")! // 洋書
        default:
            fatalError()
        }
    }
}
