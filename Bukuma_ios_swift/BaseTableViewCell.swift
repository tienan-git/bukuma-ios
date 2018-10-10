//
//  BKMBaseTableViewCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/17.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


/** TableViewCellのBase
*/

@objc public protocol BaseTableViewCellDelegate: NSObjectProtocol {}

open class BaseTableViewCell: UITableViewCell {
    
    weak var delegate: BaseTableViewCellDelegate?
    var bottomLineView: UIView? = UIView()
    var isShortBottomLine: Bool = false
    open var cellModelObject: AnyObject?
    var rightImageView: UIImageView? = UIImageView()
    var rightImage: UIImage? {
        didSet {
            if rightImage == nil {
                rightImageView?.image = nil
                return
            }
            rightImageView!.image = rightImage
            rightImageView!.viewSize = rightImage!.size
            rightImageView!.x = kCommonDeviceWidth - rightImage!.size.width - 4.0
        }
    }
    
    deinit {
        
        for v in self.contentView.subviews {
            self.releaseView(v)
        }
        
        self.releaseView(self.contentView)
        
        DBLog("-------deinit --- tableviewcell -----")
    }
    
    func releaseView(_ view: UIView) {
        for v in view.subviews {
            if v is UIImageView {
                (v as! UIImageView).image = nil
            }
            
            if v is UIButton {
                (v as! UIButton).imageView?.image = nil
            }
            
            v.removeFromSuperview()
            self.releaseSubViews()
        }
    }
    
    func releaseSubViews() {
        self.delegate = nil
        bottomLineView = nil
        rightImageView = nil
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.delegate = delegate
        self.setup()
    }

    private func setup() {
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white

        bottomLineView!.backgroundColor = kBorderColor
        self.contentView.addSubview(bottomLineView!)

        self.contentView.addSubview(rightImageView!)

        self.layoutMargins = UIEdgeInsets.zero
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        bottomLineView!.frame = isShortBottomLine == true ?  CGRect(x: 12.0, y: self.height - 0.5, width: kCommonDeviceWidth - 12.0, height: 0.5)  :  CGRect(x: 0, y: self.height - 0.5, width: kCommonDeviceWidth, height: 0.5)
    }
    
    open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 0
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        if isSelected == true {
            self.backgroundColor = kCellisSelectedBackgroundColor
            self.contentView.backgroundColor = kCellisSelectedBackgroundColor
            return
        }
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted == true {
            self.backgroundColor = kCellisSelectedBackgroundColor
            self.contentView.backgroundColor = kCellisSelectedBackgroundColor
            return
        }
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
    }
}
