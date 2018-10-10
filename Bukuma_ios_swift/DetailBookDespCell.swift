//
//  DetailBookDespCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/10/11.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

private let despripttionFont: UIFont = UIFont.systemFont(ofSize: 15)
private let despripttionWidth: CGFloat = kCommonDeviceWidth - 12 * 2
private let despripttionOriginY: CGFloat = 8.0

open class DetailBookDespCell: BaseTableViewCell {
    
    fileprivate var detailLabel: UILabel?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        
        detailLabel = UILabel()
        detailLabel!.x = 12.0
        detailLabel!.y = despripttionOriginY
        detailLabel!.numberOfLines = 0
        detailLabel!.width = despripttionWidth
        detailLabel!.textColor = kBlackColor87
        detailLabel!.font = despripttionFont
        //detailLabel?.adjustsFontSizeToFitWidth = true
        //detailLabel?.layer.borderWidth = 1
        self.contentView.addSubview(detailLabel!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func despriptionHeight(_ book: Book?) ->CGFloat {
        return self.spacingText(book?.summary ?? "").getTextHeight(despripttionWidth)
    }
    
    class func despriptionMinHeight() ->CGFloat {
        return 40.0
    }
    
    open class func cellHeightForObject(_ object: AnyObject?, shouldShort: Bool) ->CGFloat {
        let book: Book? = object as? Book
        if shouldShort == true {
            if self.despriptionHeight(book) > self.despriptionMinHeight() {
                return self.despriptionMinHeight() + despripttionOriginY + 12.0
            }
            return self.despriptionHeight(book) + despripttionOriginY + 12.0
        }
        
        return self.despriptionHeight(book) + despripttionOriginY + 12.0
        
    }

    func setCellModel(_ book: Book?, shouldShort: Bool) {
        detailLabel?.attributedText = type(of: self).spacingText(book?.summary ?? "")
                
        if shouldShort == true {
            if type(of: self).despriptionHeight(book) > type(of: self).despriptionMinHeight() {
                detailLabel?.height = type(of: self).despriptionMinHeight()
            } else {
                detailLabel?.height = type(of: self).despriptionHeight(book)
            }
        } else {
            detailLabel?.height = type(of: self).despriptionHeight(book)
        }
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
    class func spacingText(_ text: String) ->NSAttributedString {
        let att = NSMutableAttributedString(string: text)
        let para = NSMutableParagraphStyle()
        para.minimumLineHeight = 20
        para.maximumLineHeight = 20
        para.lineBreakMode = .byCharWrapping
        att.addAttribute(NSParagraphStyleAttributeName, value: para, range: NSRange(location: 0, length: att.length))
        att.addAttribute(NSFontAttributeName, value: despripttionFont, range: NSRange(location: 0, length: att.length))
        return att
    }
}
