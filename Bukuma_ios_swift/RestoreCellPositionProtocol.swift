//
//  RestoreCellPositionProtocol.swift
//  Bukuma_ios_swift
//
//  Created by hara on 5/16/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

protocol RestoreCellPositionProtocol {
    var lastIndexPath: IndexPath? { get set }
    var lastCell: UITableViewCell? { get set }
    var lastOffset: CGPoint? { get set }

    func saveCellPosition(with indexPath: IndexPath, of tableView: UITableView)
    func restoreCellPosition(of tableView: UITableView)
}

extension RestoreCellPositionProtocol {
    func saveCellPosition(with indexPath: IndexPath, of tableView: UITableView) {
        if let cell = tableView.cellForRow(at: indexPath) {
            var me = self
            me.lastIndexPath = indexPath
            me.lastCell = cell
            me.lastOffset = tableView.contentOffset
        }
    }

    func restoreCellPosition(of tableView: UITableView) {
        guard let lastIndexPath = self.lastIndexPath else { return }
        guard let lastCell = self.lastCell else { return }
        guard var lastOffset = self.lastOffset else { return }

        let cell = tableView.cellForRow(at: lastIndexPath)
        if cell != lastCell {
            lastOffset.y += lastCell.frame.size.height
        }
        tableView.contentOffset = lastOffset

        var me = self
        me.lastIndexPath = nil
        me.lastCell = nil
        me.lastOffset = nil
    }
}

class RestoreCellPosition: RestoreCellPositionProtocol {
    internal var lastIndexPath: IndexPath?
    internal var lastCell: UITableViewCell?
    internal var lastOffset: CGPoint?
}
