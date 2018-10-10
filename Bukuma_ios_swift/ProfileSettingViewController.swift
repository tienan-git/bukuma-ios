//
//  ProfileSettingViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/05.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD

open class ProfileSettingViewController: BaseTableViewController,
ProfileSettingViewHeaderViewDelegate,
BaseCommentCellDelegate,
ProfileSettingSaveButtonCellDelegate,
BaseTextFieldDelegate,
BaseTextFieldPickerCellDelegate {

    fileprivate var sections = [Section]()
    fileprivate var headerView: ProfileSettingViewHeaderView?
    var tmpUser: User = User()
    
    // ================================================================================
    // MARK: tableView struct
    fileprivate enum ProfileSettingTableViewSectionType: Int {
        case profileSetting
    }
    
    fileprivate enum ProfileSettingTableViewRowType {
        case profileSettingNickName
        case profileSettingGender
        case profileSettingBio
        case profileSettingSaveButton
    }
    
    fileprivate struct Section {
        var sectionType: ProfileSettingTableViewSectionType
        var rowItems: [ProfileSettingTableViewRowType]
    }
    
    // ================================================================================
    // MARK: setting
    
    override open func footerHeight() -> CGFloat {
        return 0
    }
    
    override open func registerDataSourceClass() -> AnyClass? {
        return nil
    }
    
    override func initializeTableViewStruct() {
        sections = [Section(sectionType: .profileSetting, rowItems: [.profileSettingNickName, .profileSettingGender, .profileSettingBio, .profileSettingSaveButton])]
    }
    
    override open func initializeNavigationLayout() {
        self.navigationBarTitle = "プロフィール設定"
    }

    // ================================================================================
    // MARK: init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        tmpUser.updateProperty(Me.sharedMe)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = ProfileSettingViewHeaderView.init(delegate: self)
        headerView?.user = tmpUser
        tableView!.tableHeaderView = headerView
        
        tableView!.showsPullToRefresh = false
        self.automaticallyAdjustsScrollViewInsets = false
        tableView!.showsVerticalScrollIndicator = false
        self.adjustTableViewInset(tableView!, contentInsetTop: self.pullToRefreshInsetTop())
    
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapView(_:)))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)

    }
    
    override open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let img: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        tmpUser.photo = Photo(image: img)
        headerView?.user = tmpUser
        picker.dismiss(animated: true, completion: nil)
    }
    
// ================================================================================
    // MARK: - gesuure delegate
    
    func tapView(_ sender: UIGestureRecognizer) {
        self.scrollToTop()
        self.view.endEditing(true)
    }
    
    // ================================================================================
    // MARK: - headerView delegate
    
    open func headerViewIconButtonTapped(_ view: ProfileSettingViewHeaderView) {
        self.showPhotoActionSheet()
    }
    
    // ================================================================================
    // MARK: - nick name delegate
    
    open func baseTextFieldDidBeginEditting(_ textField: UITextField) {
        
        if textField.tag == 1 {
            if Me.sharedMe.gender == 1 || Me.sharedMe.gender == nil {
                textField.text = "男性"
                return
            }
        }
    }
    
    open func edittingText<T : SignedNumber>(_ string: String?, type: T?) {
        tmpUser.nickName = string
    }
    
    open func didSelectTextFieldShouldReturn() {
        
    }
    
    open func baseTextFieldReturnKeyTapped(_ textField: UITextField) {
        
    }
    
    // ================================================================================
    // MARK: - bioCell delegate
    
    open func baseCommentCellStartEditing(_ cell: BaseCommentCell) {
        let indexpath: IndexPath =  IndexPath(row: 1, section: 0)
        let rectOfCellInSuperview: CGRect = tableView!.convert(tableView!.bounds, to: tableView!.cellForRow(at: indexpath))
        self.moveContentOffsetWithTargetCellRect(rectOfCellInSuperview, index: 1)
    }
    
    open func baseCommentCellEdittingText(_ cell: BaseCommentCell, text: String) {
        tmpUser.bio = text
    }
    
    // ================================================================================
    // MARK: - saveButton delegate
    
    open func saveButtonCellSaveButtonTapped(_ cell: ProfileSettingSaveButtonCell) {
        if Me.sharedMe.isRegisterd == false {
            return
        }
        
        if Utility.isEmpty(tmpUser.nickName) == true {
            self.simpleAlert(nil, message: "ニックネームが空です", cancelTitle: "OK", completion: nil)
            return
        }
        
        if Utility.isEmpty(tmpUser.gender) == true  {
            tmpUser.gender = Gender.other.int()
        }
        
        self.view.isUserInteractionEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        SVProgressHUD.show()
        Me.sharedMe.updateUserInfo(tmpUser) {[weak self] (error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.view.isUserInteractionEnabled = true
                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                    self?.simpleAlert(nil, message: error!.errorDespription, cancelTitle: "OK", completion: nil)
                    return
                }
                SVProgressHUD.dismiss()
                self?.view.isUserInteractionEnabled = true
                self?.navigationItem.leftBarButtonItem?.isEnabled = true
                self?.simpleAlert(nil, message: "保存しました！", cancelTitle: "OK", completion: {
                    DispatchQueue.main.async {
                        if self?.isModal == true {
                            self?.dismiss(animated: true, completion: nil)
                            return
                        }
                       _ = self?.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
    }
    
    // ================================================================================
    // MARK: - tableViewDataSource delegate
    
   override public func numberOfSections(in tableView: UITableView) -> Int {
        return  sections.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowItems.count
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .profileSettingNickName:
            return ProfileSettingNickNameCell.cellHeightForObject(nil)
        case .profileSettingBio:
            return ProfileSettingBioCell.cellHeightForObject(nil)
        case .profileSettingSaveButton:
            return ProfileSettingSaveButtonCell.cellHeightForObject(nil)
        default:
            return 50.0
        }
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: UIView = UIView()
        sectionView.frame = CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: kCommonTableSectionHeight)
        sectionView.backgroundColor = UIColor.clear
        return sectionView
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kCommonTableSectionHeight
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell?
        var cellIdentifier: String! = ""
        
        switch sections[indexPath.section].rowItems[indexPath.row] {
        case .profileSettingNickName:
            cellIdentifier = NSStringFromClass(ProfileSettingNickNameCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ProfileSettingNickNameCell
            if cell == nil {
                cell = ProfileSettingNickNameCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            
            break
        case .profileSettingGender:
            cellIdentifier = NSStringFromClass(BaseTextFieldPickerCell.self) + "ProfileSettingViewController" + "Gender"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?BaseTextFieldPickerCell
            if cell == nil {
                cell = BaseTextFieldPickerCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            (cell as! BaseTextFieldPickerCell).selectionStyle = .none
            (cell as! BaseTextFieldPickerCell).titleText = "性別"
            (cell as! BaseTextFieldPickerCell).placeholderText = Gender.placeholderString
            if Me.sharedMe.isOldGender() == false {
                (cell as! BaseTextFieldPickerCell).textFieldText = tmpUser.genderString()
            }
            
            (cell as! BaseTextFieldPickerCell).pickerContents = Gender.strings
            (cell as! BaseTextFieldPickerCell).textField?.returnKeyType = .done
            (cell as! BaseTextFieldPickerCell).textField?.textAlignment = .right
            (cell as! BaseTextFieldPickerCell).textField?.tag = 1
            break
        case .profileSettingBio:
            cellIdentifier = NSStringFromClass(ProfileSettingBioCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ProfileSettingBioCell
            if cell == nil {
                cell = ProfileSettingBioCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            break
        case .profileSettingSaveButton:
            cellIdentifier = NSStringFromClass(ProfileSettingSaveButtonCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?ProfileSettingSaveButtonCell
            if cell == nil {
                cell = ProfileSettingSaveButtonCell.init(reuseIdentifier: cellIdentifier, delegate: self)
            }
            break
        }
        return cell!
    }
    
    public func baseTextFieldPickerCellFinishEditPicker(_ text: String, cell: BaseTextFieldPickerCell) {
        self.view.endEditing(true)
    }
    
    public func baseTextFieldPickerCellEditingPicker(_ row: Int, cell: BaseTextFieldPickerCell) {
        tmpUser.gender = tmpUser.gender(fromRow: row)
    }
    
}

