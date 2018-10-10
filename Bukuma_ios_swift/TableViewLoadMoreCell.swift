//
//  BKMBaseTableLoadMoreCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/17.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public let TableViewLoadMoreCellReuseIdentifier = "TableViewLoadMoreCellReuseIdentifier"
public let TableViewLoadMoreCellHeight: CGFloat = 40

open class TableViewLoadMoreCell: UITableViewCell {
    var indicator: UIActivityIndicatorView?

    deinit {
        indicator?.stopAnimating()
        indicator = nil
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: TableViewLoadMoreCellReuseIdentifier)
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        self.indicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        self.indicator!.color = UIColor.colorWithHex(0xaaaaaa)
        self.indicator!.startAnimating()
        self.contentView.addSubview(self.indicator!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.indicator!.center = self.contentView.center
        self.indicator!.startAnimating()
    }
    
    open func stopAnimating() {
        self.indicator!.stopAnimating()
    }
}
