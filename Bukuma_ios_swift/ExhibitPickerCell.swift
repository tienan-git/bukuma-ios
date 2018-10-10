//
//  ExhibitPickerCell.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/08/22.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

open class ExhibitPickerCell: BaseTextFieldPickerCell {
    
    var useDefaultValue: Bool = false {
        didSet {
            if useDefaultValue == true {
                self.setDefaultValue()
            }
        }
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)

        self.textField!.font = UIFont.boldSystemFont(ofSize: 14)
        self.textField?.textAlignment = .right
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setDefaultValue() {
        if textFieldText != nil {
            let defaultRowIndex = pickerContents?.indexOfObject(textFieldText!)
            pickerView?.selectRow(defaultRowIndex ?? 0, inComponent: 0, animated: false)
        }
    }
}
