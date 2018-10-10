//
//  BaseTextFieldPickerCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/29.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

@objc public protocol BaseTextFieldPickerCellDelegate: BaseTableViewDelegate {
    @objc optional func baseTextFieldPickerCellFinishEditPicker(_ text: String, cell: BaseTextFieldPickerCell)
    @objc optional func baseTextFieldPickerCellEditingPicker(_ row: Int, cell: BaseTextFieldPickerCell)
}

/**
 
 pickerを保持し、textFieldに選択したものを表示させる機能を持ったCell

 */


open class BaseTextFieldPickerCell: BaseTextFieldCell,
UIPickerViewDelegate,
UIPickerViewDataSource {
    
    var pickerView: UIPickerView? = UIPickerView()
    var pickerContents: [String]? = Array()
    
    override func releaseSubViews() {
        super.releaseSubViews()
        pickerView = nil
        pickerContents = nil
    }
    
    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        
        pickerView?.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonDeviceWidth / 2)
        pickerView?.y = kCommonDeviceHeight - pickerView!.height
        pickerView?.delegate = self
        pickerView?.dataSource = self
        
        textField?.inputAccessoryView = keyboardToolbar
        textField?.inputView = pickerView
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func doneButtontapped(_ sender: UIBarButtonItem) {
        if (self.delegate as! BaseTextFieldPickerCellDelegate).responds(to: #selector(BaseTextFieldPickerCellDelegate.baseTextFieldPickerCellFinishEditPicker(_:cell:))) {
            (self.delegate as! BaseTextFieldPickerCellDelegate).baseTextFieldPickerCellFinishEditPicker!(textField!.text!, cell: self)
        }
        
        if keyboardToolbarButtonText == "完了" {
            textField?.resignFirstResponder()
        }
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return 0
    }
    
    // ================================================================================
    // MARK: - picker delegate, dataSource
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerContents?.count ?? 0
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerContents?[row]
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textFieldText = self.pickerContents?[row]
        if (self.delegate as! BaseTextFieldPickerCellDelegate).responds(to: #selector(BaseTextFieldPickerCellDelegate.baseTextFieldPickerCellEditingPicker(_:cell:))) {
            (self.delegate as! BaseTextFieldPickerCellDelegate).baseTextFieldPickerCellEditingPicker!(row, cell: self)
        }
    }
}
