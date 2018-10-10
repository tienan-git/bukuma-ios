//
//  UserPageCollectionCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/09/26.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation

public protocol UserPageCollectionCellDelegate: BaseTableViewCellDelegate {
    func userPageCollectionDidSelectAdRow(_ row: Int, merchandise: Merchandise)
}

// ================================================================================
// MARK: - tableViewCell
open class UserPageCollectionTableCell: BaseTableViewCell,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var flowLayout: UICollectionViewFlowLayout?
    var dataSource: UserMerchandiseListDataSource?
    var currentPage: CGFloat = 0
    let stepUnit = UserPageCollectionCellLayout.cellWidth()
    
    static var lastContentOffset: CGFloat? = nil
    static var lastOffsetStep: CGFloat = 0
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.selectionStyle = .none
        self.clipsToBounds = true
        flowLayout = UserPageCollectionCellLayout()
        
        collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: flowLayout!)
        collectionView.delegate = self
        collectionView.dataSource  = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.width = kCommonDeviceWidth
        collectionView.height = UserPageCollectionCellLayout.cellHeight()
        collectionView.x = 0
        collectionView.contentInsetLeft = 0
        collectionView.contentInsetRight = 0
        collectionView.contentInsetTop = 0
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.register(UserPageCollectionCell.self, forCellWithReuseIdentifier: NSStringFromClass(UserPageCollectionCell.self))
        collectionView.register(UserPageLoadMoreCell.self, forCellWithReuseIdentifier: NSStringFromClass(UserPageLoadMoreCell.self))
        self.contentView.addSubview(collectionView)
        
        currentPage = round(collectionView.contentOffset.x / stepUnit)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 240
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count() ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: UICollectionViewCell! = UICollectionViewCell(frame: CGRect.zero)
        var cellIdentifier: String = ""
        
        let merchandise: Merchandise? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: true) as? Merchandise
        if merchandise == nil {
            cellIdentifier = NSStringFromClass(UserPageLoadMoreCell.self)
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            if cell == nil {
                cell = UserPageLoadMoreCell()
            }
            (cell as? UserPageLoadMoreCell)?.startAnimationg()
        } else {
            cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UserPageCollectionCell.self), for: indexPath) as! UserPageCollectionCell
            if cell == nil {
                cell = UserPageCollectionCell()
            }
            (cell as? UserPageCollectionCell)?.cellModelObject = merchandise
        }
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let merchandise: Merchandise? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Merchandise
        
        if merchandise != nil {
            (self.delegate as? UserPageCollectionCellDelegate)?.userPageCollectionDidSelectAdRow((indexPath as IndexPath).row, merchandise: merchandise!)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let merchandise: Merchandise? = self.dataSource?.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Merchandise
        
        if  merchandise == nil {
            return UserPageLoadMoreCell.loadMoreCellSize()
        }
        return CGSize(width: UserPageCollectionCellLayout.cellWidth(), height: UserPageCollectionCellLayout.cellHeight())
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is UserPageLoadMoreCell {
            (cell as? UserPageLoadMoreCell)?.stopAnimationg()
        }
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        var number: CGFloat = 1
        if (velocity.x >= 2.0) || (velocity.x <= -2.0) {
            number = 2
        }
        
        if velocity.x > 0 {
            if scrollView.contentOffsetX < scrollView.contentSize.width - scrollView.width {
                currentPage += number
            } else {
                targetContentOffset.pointee.x = scrollView.contentOffsetX
                return
            }
        } else if velocity.x < 0 {
            
            if scrollView.contentOffsetX < 0 {
                currentPage = 0
            } else {
                currentPage -= number
            }
        } else if velocity.x == 0 {
            let lastScroll = currentPage * stepUnit
            let diff = floor(round((scrollView.contentOffsetX - lastScroll) / stepUnit))
            currentPage += diff
        }
        
        let nextScrollPosition: CGFloat = currentPage * stepUnit
        
        targetContentOffset.pointee.x = nextScrollPosition
        
        DBLog("-----currentpage\(currentPage), nextScrollPosition\(nextScrollPosition)----velocity-------\(velocity)")
        
    }
}

// ================================================================================
// MARK: - collectionViewLayout
open class UserPageCollectionCellLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.itemSize = CGSize(width: UserPageCollectionCellLayout.cellWidth(), height: UserPageCollectionCellLayout.cellHeight())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //default value but it will change after book image resize
    open class func cellWidth() ->CGFloat {
        return bookWidth() + 15.0
    }
    
    open class func bookWidth() ->CGFloat {
        return 114
    }
    
    open class func cellHeight() ->CGFloat {
        return 230
    }
}

// ================================================================================
// MARK: - collectionViewCell

private let maxTitleLabelHeight: CGFloat = 15.0

open class UserPageCollectionCell: BaseCollectionCell {
    
    var titleLabel: UILabel!
    var priceLabel: UILabel!
    
    required public init(frame: CGRect) {
        super.init(frame: frame)
        
        bookImageView?.frame = CGRect(x: 15.0, y: 15.0, width:  UserPageCollectionCellLayout.cellWidth(), height: 0)
        bookImageView?.height = 152.0
        bookImageView?.clipsToBounds = true
        bookImageView?.layer.cornerRadius = 3.0
        bookImageView?.layer.borderWidth = 0.5
        bookImageView?.layer.borderColor = kBorderColor.cgColor
        
        titleLabel = UILabel(frame: CGRect(x: 15.0, y: bookImageView!.bottom, width: UserPageCollectionCellLayout.cellWidth(), height: 40))
        titleLabel.text = ""
        titleLabel.textColor = kDarkGray04Color
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.numberOfLines = 1
        self.contentView.addSubview(titleLabel)
        
        priceLabel = UILabel(frame: CGRect(x: 15.0, y: titleLabel.bottom, width: UserPageCollectionCellLayout.cellWidth(), height: 20))
        priceLabel.text = ""
        priceLabel.textColor = kDarkGray01Color
        priceLabel.font = UIFont.boldSystemFont(ofSize: 13)
        self.contentView.addSubview(priceLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let merchandise: Merchandise? = cellModelObject as? Merchandise
            
            if merchandise?.book?.imageWidth == nil && merchandise?.book?.imageHeight == nil {
                bookImageView?.viewSize = CGSize(width: UserPageCollectionCellLayout.bookWidth(), height: 152.0)
            } else {
                let bookWidth: CGFloat = UserPageCollectionCellLayout.bookWidth()
                let bookOriginalHeight: CGFloat = UserPageCollectionCellLayout.bookWidth() * (CGFloat(merchandise?.book?.imageHeight ?? 0) / CGFloat(merchandise?.book?.imageWidth ?? 0))
                let maxHeight: CGFloat = 170.0
                var bookHeight: CGFloat = 0
                if bookOriginalHeight > maxHeight {
                    bookHeight = maxHeight
                } else {
                    bookHeight = bookOriginalHeight
                }
                bookImageView?.viewSize = CGSize(width: bookWidth, height: bookHeight)
            }
             
            if merchandise?.book?.coverImage?.url != nil {
                bookImageView?.downloadImageWithURL(merchandise?.book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)
            } else {
                bookImageView?.image = kPlacejolderBookImage
            }
            
            titleLabel.text = merchandise?.book?.titleText()
            priceLabel.text = "¥\(merchandise?.price ?? "")"
            
            let textHeight: CGFloat = titleLabel.text!.getTextHeight(titleLabel.font, viewWidth: titleLabel.width)
            
            if textHeight > maxTitleLabelHeight {
                titleLabel.height = maxTitleLabelHeight
            } else {
                titleLabel.height = textHeight
            }
            priceLabel.height = priceLabel.text!.getTextHeight(priceLabel.font, viewWidth: priceLabel.width)
            priceLabel.bottom = self.contentView.bottom - 3.0
            
            titleLabel.y = priceLabel.top - titleLabel.height
        
        }
    }
}

open class UserPageLoadMoreCell: CollectionLoadMoreCell {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicatorView!.color = UIColor.colorWithHex(0xaaaaaa)
        indicatorView!.x = (self.contentView.width - indicatorView!.width) / 2
        indicatorView!.y = (self.contentView.height - indicatorView!.height) / 2
        indicatorView!.isHidden = false
        indicatorView?.startAnimating()
        self.contentView.addSubview(indicatorView!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        indicatorView?.x = (self.contentView.width - indicatorView!.width) / 2
        indicatorView?.y = (self.contentView.height - indicatorView!.height) / 2
        indicatorView?.startAnimating()
    }
    
    open override class func loadMoreCellSize() ->CGSize {
        return CGSize(width: UserPageCollectionCellLayout.cellWidth(), height: UserPageCollectionCellLayout.cellHeight())
    }
}
