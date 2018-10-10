//
//  BKMBaseCollectionCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/17.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

@objc public protocol BaseCollectionCellDelegate: NSObjectProtocol {
    
}

/** CollectionViewCellのBase
 本のimageViewを保持*/

open class BaseCollectionCell: UICollectionViewCell {
    
    deinit {
    
        DBLog("-------deinit --- BaseCollectionCell -----")
        
    }
    
    func releaseSubViews() {
        self.delegate = nil
        bookImageView?.image = nil
        bookImageView = nil
    }
    
    dynamic var bookImageView: UIImageView?
    open var cellModelObject: AnyObject?
    open weak var delegate: BaseCollectionCellDelegate?
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.clipsToBounds = false
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 3.0
        
        bookImageView = UIImageView(frame: CGRect.zero)
        bookImageView?.y = 0
        bookImageView?.contentMode = .scaleAspectFill
        bookImageView?.clipsToBounds = false
        bookImageView?.backgroundColor = UIColor.clear
        self.contentView.addSubview(bookImageView!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        
        self.bookImageView?.image = nil
    }
    
    open class func cellHeightForObject(_ object: AnyObject?) ->CGSize {
        return CGSize.zero
    }
    
    open class func homeBookImageViewHeight() ->CGFloat {
        if UIScreen.is3_5inchDisplay() {
            return 200
        } else if UIScreen.is4inchDisplay() {
            return 200
        } else if UIScreen.is4_7inchDisplay() {
            return 240
        } else if UIScreen.is5_5inchDisplay() {
            return 270
        }
        
        return 200
    }
}
