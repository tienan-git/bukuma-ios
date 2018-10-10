//
//  ExhibitBulkPhotoCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/30.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

@objc public protocol ExhibitBulkPhotoCellDelegate: BaseTableViewCellDelegate {
    func exhibitBulkPhotoCellImageViewButtonTapped(_ tag: Int, cell: ExhibitBulkPhotoCell)
}

open class ExhibitBulkPhotoCell: BaseTableViewCell {
    
    fileprivate let titleLabel: UILabel! = UILabel()
    fileprivate let subTitleLabel: UILabel! = UILabel()
    fileprivate var imageViewButtonArray: Array<UIButton> = []
    open var photoImage: [Int: UIImage]? {
        didSet {
            if photoImage == nil {
                return
            }
            for (key, value) in photoImage! {
                let button: UIButton = imageViewButtonArray[key]
                button.setImage(value, for: .normal)
            }
        }
    }
    
    open var photoImageUrl: [Int: URL]? {
        didSet {
            if photoImageUrl == nil {
                return
            }
            for (key, value) in photoImageUrl! {
                let button: UIButton = imageViewButtonArray[key]
                button.downloadImageWithURL(value, placeholderImage: UIImage(named: "img_placeholder"))
            }
        }
    }
    
    var borderView1: UIView = UIView()
    var borderView2: UIView = UIView()
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
         selectionStyle = .none
        titleLabel.frame = CGRect(x: 15.0, y: 0, width: 100, height: 25)
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.text = "商品の写真"
        self.contentView.addSubview(titleLabel)
        
        subTitleLabel.frame = CGRect(x: 15.0, y: 0, width: 100, height: 25)
        subTitleLabel.font = UIFont.systemFont(ofSize: 12)
        subTitleLabel.text = "3枚まで。任意。"
        subTitleLabel.textColor = kGrayColor
        self.contentView.addSubview(subTitleLabel)
        
        for i in 0...2 {
            let imageViewButton: UIButton! = UIButton()
            imageViewButton.viewSize = CGSize(width: UIImage(named: "img_placeholder")!.size.width, height: UIImage(named: "img_placeholder")!.size.height)
            imageViewButton.setImage(UIImage(named: "img_placeholder")!, for: .normal)
            imageViewButton.contentMode = .scaleAspectFit
            imageViewButton.y = (64.0 - imageViewButton.width) / 2
            let margin = kCommonDeviceWidth - 15 * (CGFloat(i) + 1)
            let width = imageViewButton.width * (CGFloat(i) + 1)
            imageViewButton.x = margin - width
            imageViewButton.clipsToBounds = true
            imageViewButton.layer.cornerRadius = 2.0
            imageViewButton.tag = i
            imageViewButton.backgroundColor = UIColor.clear
            imageViewButton.addTarget(self, action: #selector(self.imageViewButtonTapped(_:)), for: .touchUpInside)
            imageViewButtonArray.append(imageViewButton)
            self.contentView.addSubview(imageViewButton)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let contentHeight: CGFloat = titleLabel.height + subTitleLabel.height
        titleLabel.y = (self.height - contentHeight) / 2
        subTitleLabel.y = titleLabel.bottom
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 64
    }
    
    func imageViewButtonTapped(_ sender: UIButton) {
        if (self.delegate as! ExhibitBulkPhotoCellDelegate).responds(to: #selector(ExhibitBulkPhotoCellDelegate.exhibitBulkPhotoCellImageViewButtonTapped(_:cell:))) {
            (self.delegate as! ExhibitBulkPhotoCellDelegate).exhibitBulkPhotoCellImageViewButtonTapped(sender.tag, cell: self)
        }
    }
}

