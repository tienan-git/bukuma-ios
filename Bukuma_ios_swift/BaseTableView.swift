//
//  BKMBaseTableView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


@objc public protocol BaseTableViewDelegate: UITableViewDelegate {
    @objc optional func footerHeight() ->CGFloat
    @objc optional func scrollIndicatorInsetBottom() ->CGFloat
    @objc optional func footerHeightUsingTag(_ tableViewTag: Int) ->CGFloat
    @objc optional func scrollIndicatorInsetBottomUsingTag(_ tableViewTag: Int) ->CGFloat
}

open class BaseTableView: UITableView {
    
    weak var tableViewDelegate : BaseTableViewDelegate?
    var isFixTableScrollWhenChangeContentsSize: Bool = false
    var isFixScrollIndicatorBottom: Bool = true
    var usingTag: Bool = false
    
    deinit{
        self.dataSource = nil
        self.delegate = nil
        self.tableViewDelegate = nil
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func reloadData() {
        super.reloadData()
        self.updateFooterInset()
    }
    
    ///keyboard出現じとかにisFixTableScrollWhenChangeContentsSizeをtrueにしてcontentSizeをいい感じにしてます
    override open var contentSize:CGSize {
        willSet(newValue) {
            if isFixTableScrollWhenChangeContentsSize == true{
                if self.contentSize.equalTo(CGSize.zero){
                    if newValue.height > self.contentSize.height{
                        var offset: CGPoint = self.contentOffset
                        offset.y += (newValue.height - self.contentSize.height)
                        self.contentOffset = offset
                    }
                }
            }
            super.contentSize = newValue
        }
    }
    
    func updateFooterInset() ->Void{
         var footerHeight: CGFloat = 0
        if usingTag == true {
            if (self.tableViewDelegate!).responds(to: #selector(BaseTableViewDelegate.footerHeightUsingTag(_:))){
                footerHeight +=  self.tableViewDelegate!.footerHeightUsingTag!(self.tag)
            }
            
            self.contentInsetBottom = footerHeight
            
            self.scrollIndicatorInsets = UIEdgeInsetsMake(self.contentInsetTop,
                                                          self.contentInsetLeft,
                                                          self.contentInsetBottom,
                                                          self.contentInsetRight)
            if tableViewDelegate!.responds(to: #selector(BaseTableViewDelegate.scrollIndicatorInsetBottomUsingTag(_:))) {
                if isFixScrollIndicatorBottom == true {
                    self.scrollIndicatorInsets.bottom = self.tableViewDelegate!.scrollIndicatorInsetBottomUsingTag!(self.tag)
                }
            }
        } else {
            if (self.tableViewDelegate!).responds(to: #selector(BaseTableViewDelegate.footerHeight)){
                footerHeight +=  self.tableViewDelegate!.footerHeight!()
            }
            
            self.contentInsetBottom = footerHeight
            
            self.scrollIndicatorInsets = UIEdgeInsetsMake(self.contentInsetTop,
                                                          self.contentInsetLeft,
                                                          self.contentInsetBottom,
                                                          self.contentInsetRight)
            if tableViewDelegate!.responds(to: #selector(BaseTableViewDelegate.scrollIndicatorInsetBottom)) {
                if isFixScrollIndicatorBottom == true {
                    self.scrollIndicatorInsets.bottom = self.tableViewDelegate!.scrollIndicatorInsetBottom!()
                }
            }
        }
    }
}
