//
//  DetailRecommendBookCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public protocol DetailRecommendBookDelegate: BaseTableViewCellDelegate {
    func detailRecommendBookDidSelectAdRow(_ row: Int, book: Book)
}

// ================================================================================
// MARK: - tableViewCell
open class DetailRecommendBookCell: BaseTableViewCell,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var flowLayout: UICollectionViewFlowLayout?
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        self.selectionStyle = .none
        self.clipsToBounds = true
        flowLayout = DetailRecommendBookCollectionLayout()
        
        collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: flowLayout!)
        collectionView.delegate = self
        collectionView.dataSource  = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.width = kCommonDeviceWidth
        collectionView.x = 0
        collectionView.contentInsetLeft = 15.0
        collectionView.contentInsetRight = 15.0
        collectionView.contentInsetTop = 0
        
        collectionView.register(DetailRecommendBookCollectionCell.self, forCellWithReuseIdentifier: NSStringFromClass(DetailRecommendBookCollectionCell.self))
        self.contentView.addSubview(collectionView)
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
        return 3
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DetailRecommendBookCollectionCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(DetailRecommendBookCollectionCell.self), for: indexPath) as! DetailRecommendBookCollectionCell
        
        let books: [Book]? = self.cellModelObject as? [Book]
         _ = books.flatMap { cell.cellModelObject = $0[indexPath.row] }
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let book: Book? = (self.cellModelObject as? [Book])?[indexPath.row]
        
        if book != nil {
            (self.delegate as? DetailRecommendBookDelegate)?.detailRecommendBookDidSelectAdRow(indexPath.row, book: book!)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let book: Book? = (self.cellModelObject as? [Book])?[indexPath.row]
        
        if book?.imageWidth == nil && book?.imageHeight == nil {
            return CGSize(width: DetailRecommendBookCollectionLayout.cellWidth(), height:DetailRecommendBookCollectionLayout.cellHeight())
        } else {
            
            let bookImageView: UIImageView = UIImageView()
            bookImageView.resize(CGSize(width: CGFloat(book!.imageWidth!), height: CGFloat(book!.imageHeight!)),
                                  fixedHeight: 152.0,
                                  fixedWidth: 103.0,
                                  center: 0)
            return CGSize(width: bookImageView.width, height: DetailRecommendBookCollectionLayout.cellHeight())
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.height = DetailRecommendBookCollectionLayout.cellHeight()
    }
}

// ================================================================================
// MARK: - collectionViewLayout
open class DetailRecommendBookCollectionLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 12
        self.minimumInteritemSpacing = 12
        self.itemSize = CGSize(width: DetailRecommendBookCollectionLayout.cellWidth(), height: DetailRecommendBookCollectionLayout.cellHeight())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //default value but it will change after book image resize
    open class func cellWidth() ->CGFloat {
        return 114
    }
    
    //default value but it will change after book image resize
    open class func cellHeight() ->CGFloat {
        return 230
    }
 }

// ================================================================================
// MARK: - collectionViewCell

private let maxTitleLabelHeight: CGFloat = 29.0

open class DetailRecommendBookCollectionCell: BaseCollectionCell {
    
    var titleLabel: UILabel!
    var priceLabel: UILabel!
    
    required public init(frame: CGRect) {
        super.init(frame: frame)
        
        //bookImageView = UIImageView(frame: CGRect.zero)
        bookImageView?.frame = CGRect(x: 0, y: 15.0, width: self.contentView.width, height: 0)
        bookImageView?.height = 152.0
        bookImageView?.layer.cornerRadius = 3.0
        bookImageView?.layer.borderWidth = 0.5
        bookImageView?.layer.borderColor = kBorderColor.cgColor

        titleLabel = UILabel(frame: CGRect(x: 0, y: bookImageView!.bottom, width: self.width, height: 40))
        titleLabel.text = ""
        titleLabel.textColor = kDarkGray04Color
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.numberOfLines = 2
        self.contentView.addSubview(titleLabel)
        
        priceLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.bottom, width: self.width, height: 20))
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
            let book: Book? = cellModelObject as? Book
            
            if book?.imageWidth == nil && book?.imageHeight == nil {
                bookImageView?.viewSize = CGSize(width: self.contentView.width, height: 152.0)
            } else {
                bookImageView?.resize(CGSize(width: CGFloat(book!.imageWidth!), height: CGFloat(book!.imageHeight!)),
                                      fixedHeight: 152.0,
                                      fixedWidth: 103.0,
                                      center: 0)
                if (bookImageView?.height ?? 0) < CGFloat(152.0) {
                    bookImageView?.y = (152.0 - bookImageView!.height) / 2
                }
                bookImageView?.x = 0
            }
            
            bookImageView!.downloadImageWithURL(book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)
            titleLabel.text = book?.title
            priceLabel.text = book?.lowestPriceString(.yenMark) ?? ""
            
            let textHeight: CGFloat = titleLabel.text!.getTextHeight(titleLabel.font, viewWidth: titleLabel.width)
            
            if textHeight > maxTitleLabelHeight {
                titleLabel.height = maxTitleLabelHeight
            } else {
                titleLabel.height = textHeight
            }
            priceLabel.height = priceLabel.text!.getTextHeight(priceLabel.font, viewWidth: priceLabel.width)
            
            titleLabel.y = CGFloat(15.0 + 152.0 + 10.0)
            priceLabel.y = titleLabel.bottom + 5.0
        }
    }
}
