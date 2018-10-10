//
//  ExhibitButtonBaseCell.swift
//  Bukuma_ios_swift
//
//  Created by khara on 9/27/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

open class ExhibitButtonBaseCell: BaseTableViewCell {
    private static let buttonHeight: CGFloat = 40.0
    private static let xMargin: CGFloat = 24.0
    private static let yMargin: CGFloat = 15.0

    var exhibitButton: UIButton!

    // MARK: - Need to override.

    func setup() {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets.zero

        self.exhibitButton = UIButton()
        self.exhibitButton.frame = self.buttonFrame
        self.exhibitButton.clipsToBounds = true
        self.exhibitButton.layer.cornerRadius = 4.0
        self.exhibitButton.layer.borderColor = UIColor.clear.cgColor
        self.exhibitButton.setBackgroundColor(self.buttonColor, state: .normal)
        self.exhibitButton.setTitle(self.buttonTitle, for: .normal)
        self.exhibitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        self.exhibitButton.setTitleColor(UIColor.white, for: .normal)
        self.contentView.addSubview(self.exhibitButton)

        self.isShortBottomLine = false
        self.bottomLineView?.isHidden = true
    }

    var buttonTitle: String {
        get { return "" }
    }

    var buttonColor: UIColor {
        get { return UIColor() }
    }

    // MARK: -

    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)

        self.setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static var cellHeight: CGFloat {
        get { return self.buttonHeight + (self.yMargin * 2) }
    }

    private var buttonFrame: CGRect {
        get { return CGRect(x: ExhibitButtonBaseCell.xMargin,
                            y: ExhibitButtonBaseCell.yMargin,
                            width: self.frame.size.width - (ExhibitButtonBaseCell.xMargin * 2),
                            height: ExhibitButtonBaseCell.buttonHeight) }
    }

    override open class func cellHeightForObject(_ object: AnyObject?) -> CGFloat {
        return self.cellHeight
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        self.exhibitButton.frame = self.buttonFrame
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }

    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }
}
