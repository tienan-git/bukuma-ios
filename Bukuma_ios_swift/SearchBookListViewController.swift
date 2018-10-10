//
//  SearchBookListTableViewController.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/04/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


open class SearchBookListViewController: SearchMerchandiseBookGridViewController {
    
    override open func registerCellClass() -> AnyClass? {
        return SearchBookListCell.self
    }
    
   override  open func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let book: Book? = self.dataSource!.dataAtIndex(indexPath.row, isAllowUpdate: false) as? Book
        
        let controller: ExhibitTableViewController = ExhibitTableViewController(book: book)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
