//
//  SearchLoadMoreCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/11/25.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public protocol SearchLoadMoreCellDelegate {
    func searchLoadMoreCellLoadMoreButtonTapped(_ cell: SearchLoadMoreCell, completion: (() ->Void)?)
}

open class SearchLoadMoreCell: UITableViewCell {
    
    var loadMoreFooterView: SearchLoadMoreView?
    var loadMoreDelegate: SearchLoadMoreCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: TableViewLoadMoreCellReuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
       
        loadMoreFooterView = SearchLoadMoreView(delegate: self)
        loadMoreFooterView?.isHidden = false
        self.contentView.addSubview(loadMoreFooterView!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    open func stopAnimating() {
        loadMoreFooterView?.stopLoading()
    }
    
    open func startAnimation() {
        loadMoreFooterView?.startLoading()
    }
    
    class func size() ->CGSize {
        return SearchLoadMoreView.size()
    }
}

extension SearchLoadMoreCell: SearchLoadMoreViewLoadMoreViewDelegate {
    open func LoadMoreViewLoadMoreButtonTapped(_ view: SearchLoadMoreView, completion: (() ->Void)?) {
        loadMoreDelegate?.searchLoadMoreCellLoadMoreButtonTapped(self, completion: completion)
    }
}
