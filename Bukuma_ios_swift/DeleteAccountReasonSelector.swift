//
//  DeleteAccountSelector.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/19/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

protocol ResizableTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didChangeContentSize oldContentSize: CGSize)
}

extension UITableView {
    override open var contentSize: CGSize {
        didSet(oldValue) {
            if let delegate = self.delegate as? ResizableTableViewDelegate {
                delegate.tableView(self, didChangeContentSize: oldValue)
            }
        }
    }
}

protocol DeleteAccountReasonSelectorDelegate: class {
    func selectorDidResize(_ newSize: CGSize, _ oldSize: CGSize, with reasonSelector: DeleteAccountReasonSelector)
    func selectorDidChangeReason(_ selectedReason: DeleteAccountReasonProtocol?,  with reasonSelector: DeleteAccountReasonSelector)
}

class DeleteAccountReasonSelector: UIView {
    weak var delegate: DeleteAccountReasonSelectorDelegate?

    var resultReason: DeleteAccountReasonProtocol? { get {
        return self.selectedReason
        }}

    fileprivate var deleteAccountReasonsTable: UITableView!
    fileprivate var deleteAccountReasons: DeleteAccountReasons?
    fileprivate var selectedReason: DeleteAccountReasonProtocol?
    fileprivate var selectedIndex: IndexPath?

    fileprivate var lastSize: CGSize!
    fileprivate let topMargin: CGFloat = 8.0
    fileprivate let bottomMargin: CGFloat = 8.0

    override init(frame: CGRect) {
        super.init(frame: frame)

        var tableFrame = frame
        tableFrame.origin.x = 0
        tableFrame.origin.y = self.topMargin
        tableFrame.size.height = frame.size.height - self.topMargin - self.bottomMargin
        self.deleteAccountReasonsTable = UITableView(frame: tableFrame, style: .plain)
        self.deleteAccountReasonsTable.dataSource = self
        self.deleteAccountReasonsTable.delegate = self
        self.deleteAccountReasonsTable.separatorStyle = .none
        self.addSubview(self.deleteAccountReasonsTable)

        self.lastSize = self.deleteAccountReasonsTable.contentSize

        let nib = UINib(nibName: DeleteAccountReasonCell.nibName, bundle: nil)
        self.deleteAccountReasonsTable.register(nib, forCellReuseIdentifier: DeleteAccountReasonCell.reuseID)

        DeleteAccountRawReasons.get { [weak self] (_ rawReasons: [[String: Any?]]?, _ error: Error?) in
            if error != nil {
                return
            }
            if let rawReasons = rawReasons {
                DispatchQueue.main.async {
                    self?.deleteAccountReasons = DeleteAccountReasons(withRawReasons: rawReasons)
                    self?.deleteAccountReasonsTable.reloadData()
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension DeleteAccountReasonSelector: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.deleteAccountReasons?.reasons.count ?? 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deleteAccountReasons?.numberOfReasons(at: section) ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let reason = self.deleteAccountReasons?.reason(at: indexPath.section, with: indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: DeleteAccountReasonCell.reuseID, for: indexPath) as! DeleteAccountReasonCell
            cell.setup(withReason: reason)
            if indexPath.section == self.selectedIndex?.section && indexPath.row == self.selectedIndex?.row {
                cell.setSelected(true, animated: false)
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension DeleteAccountReasonSelector: ResizableTableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let reason = self.deleteAccountReasons?.reason(at: indexPath.section, with: indexPath.row)
        return DeleteAccountReasonCell.cellHeight(withReason: reason)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == self.selectedIndex?.section {
            if indexPath.row != self.selectedIndex?.row {
                if let selectedIndex = self.selectedIndex {
                    let selectedCell = tableView.cellForRow(at: selectedIndex)
                    selectedCell?.setSelected(false, animated: true)
                }
                let cell = tableView.cellForRow(at: indexPath)
                cell?.setSelected(true, animated: true)
                self.selectedIndex = indexPath

                if let reason = self.deleteAccountReasons?.reason(at: indexPath.section, with: indexPath.row) {
                    self.selectedReason = reason
                }
            }
        } else {
            if let selectedIndex = self.selectedIndex {
                let selectedCell = tableView.cellForRow(at: selectedIndex)
                selectedCell?.setSelected(false, animated: true)

                self.accordionEffect(atSection: selectedIndex.section, inTableView: tableView, wantToOpen: false)
            }
            let cell = tableView.cellForRow(at: indexPath)
            cell?.setSelected(true, animated: true)
            self.selectedIndex = indexPath

            self.selectedReason = nil
            if let selectedIndex = self.selectedIndex {
                if let reason = self.deleteAccountReasons?.reason(at: selectedIndex.section, with: selectedIndex.row) {
                    if let haveChildren = reason as? DeleteAccountReasonHaveChildren {
                        haveChildren.isEnableChildren = true

                        self.accordionEffect(atSection: selectedIndex.section, inTableView: tableView, wantToOpen: true)
                    }
                    self.selectedReason = reason
                }
            }
        }

        self.delegate?.selectorDidChangeReason(self.selectedReason, with: self)
    }

    // メソッド化しているが、下記コメントのような制約？から独立性の低いものとなってしまっている…
    private func accordionEffect(atSection section: Int, inTableView tableView: UITableView, wantToOpen toOpen: Bool) {
        // 本来 let numberOfRows = tableView.numberOfRows(inSection: section) としたかったが、更新のズレがあるようで、その中身に相当する
        // 下記じゃないとダメだった
        let numberOfRows = (self.deleteAccountReasons?.numberOfReasons(at: section))!

        var indexPaths: [IndexPath] = []
        for row in 1 ..< numberOfRows {
            indexPaths.append(IndexPath(row: row, section: section))
        }

        tableView.beginUpdates()
        if toOpen {
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            tableView.deleteRows(at: indexPaths, with: .fade)

            // tableView.endUpdates で tableView(_:, numberOfRowsInSection:), tableView(_:, cellForRowAt:) と更新されてしまうので、
            // tableView.deleteRows 呼び出し時は tableView.endUpdates 後に numberOfRowsInSection で正しい値が返るように情報を更新しておかねばならず、
            // 下記記述が必要
            if let haveChildren = self.selectedReason as? DeleteAccountReasonHaveChildren {
                haveChildren.isEnableChildren = false
            }
            if let reason = self.selectedReason as? DeleteAccountReason {
                if let parent = reason.parent as? DeleteAccountReasonHaveChildren {
                    parent.isEnableChildren = false
                }
            }
        }
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, didChangeContentSize oldContentSize: CGSize) {
        var tableSize = tableView.frame.size
        tableSize.height = tableView.contentSize.height
        tableView.frame.size = tableSize

        var viewSize = self.frame.size
        let oldSize = viewSize
        viewSize.height = tableView.contentSize.height + self.bottomMargin
        self.frame.size = viewSize

        self.delegate?.selectorDidResize(viewSize, oldSize, with: self)
    }
}
