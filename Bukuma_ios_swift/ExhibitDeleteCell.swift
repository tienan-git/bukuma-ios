//
//  ExhibitDeleteCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/07/21.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

public protocol ExhibitDeleteCellDelegate: BaseTableViewDelegate {
    func exhibitDeleteCellDeleteButtonTapped(_ cell: ExhibitDeleteCell, completion: (() ->Void)?)
}

open class ExhibitDeleteCell: ExhibitButtonBaseCell {
    override func setup() {
        super.setup()

        self.exhibitButton.addTarget(self, action: #selector(self.deleteButtonTapped(_:)), for: .touchUpInside)
    }

    override var buttonTitle: String {
        get { return "出品を削除する" }
    }

    override var buttonColor: UIColor {
        get { return UIColor(red: 251/255, green: 98/255, blue: 118/255, alpha: 1.0) }
    }

    func deleteButtonTapped(_ sender: UIButton) {
        self.isUserInteractionEnabled = false
        (delegate as? ExhibitDeleteCellDelegate)?.exhibitDeleteCellDeleteButtonTapped(self, completion: { [weak self] in
            DispatchQueue.main.async {
                 self?.isUserInteractionEnabled = true
            }
        })
    }
}
