//
//  InvitationCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/15.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

@objc public protocol InvitationCellDelegate: BaseTableViewCellDelegate {
    func invitationCellShareButtonTapped(_ cell: InvitationCell)
    func invitationCellReviewButtonTapped(_ cell: InvitationCell)
}

private let InvitationCellBaseHolizonMargin: CGFloat = 10.0
private let InvitationCellTitleLabelHolizonMargin: CGFloat = 15.0
private let InvitationCellTitleLabelSize: CGSize = CGSize(width: 160.0, height: 15.0)
private let InvitationCellCodeLabelSize: CGSize = CGSize(width: 100.0, height: 20.0)
private let InvitationCellNumPeopleLabelSize: CGSize = CGSize(width: 200.0, height: 15.0)
private let InvitationCellShareButtonHolizonMargin: CGFloat = 10.0
private let InvitationCellShareButtonHeight: CGFloat = 40.0

open class InvitationCell: BaseTableViewCell {
    
    fileprivate let titleLabel: UILabel! = UILabel()
    fileprivate let codeLabel: UILabel! = UILabel()
    fileprivate let numPeopleLabel: UILabel! = UILabel()
    fileprivate let shareButton: UIButton! = UIButton()
    fileprivate let reviewButton: UIButton! = UIButton()

    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        self.delegate = delegate
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.selectionStyle = .none

        let baseView: UIView! = UIView(frame: CGRect(x: 5.0, y: 0, width: kCommonDeviceWidth - 5.0 * 2, height: 0))
        baseView.backgroundColor = UIColor.white
        baseView.clipsToBounds = true
        baseView.layer.cornerRadius = 3.0
        self.contentView.addSubview(baseView)

        titleLabel.frame = CGRect(x: (kCommonDeviceWidth - InvitationCellTitleLabelSize.width) / 2,
                                  y: InvitationCellTitleLabelHolizonMargin,
                                  width: InvitationCellTitleLabelSize.width,
                                  height: InvitationCellTitleLabelSize.height)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 11)
        titleLabel.textColor = kBlackColor54
        titleLabel.text = "あなたの招待コード"
        titleLabel.textAlignment = .center
        baseView.addSubview(titleLabel)
        
        codeLabel.frame = CGRect(x: (kCommonDeviceWidth - InvitationCellCodeLabelSize.width) / 2,
                                  y: titleLabel.bottom + InvitationCellBaseHolizonMargin,
                                  width: InvitationCellCodeLabelSize.width,
                                  height: InvitationCellCodeLabelSize.height)
        codeLabel.font = UIFont.boldSystemFont(ofSize: 17)
        codeLabel.textColor = kDarkGray04Color
        codeLabel.text = Me.sharedMe.invitationCode ?? "まだありません"
        codeLabel.width = codeLabel.text!.getTextWidthWithFont(codeLabel.font, viewHeight: codeLabel.height)
        codeLabel.x = (kCommonDeviceWidth - codeLabel.width) / 2
        codeLabel.textAlignment = .center
        baseView.addSubview(codeLabel)

        numPeopleLabel.frame = CGRect(x: (kCommonDeviceWidth - InvitationCellNumPeopleLabelSize.width) / 2,
                                 y: codeLabel.bottom + InvitationCellBaseHolizonMargin,
                                 width: InvitationCellNumPeopleLabelSize.width,
                                 height: InvitationCellNumPeopleLabelSize.height)
        numPeopleLabel.font = UIFont.systemFont(ofSize: 12)
        numPeopleLabel.textColor = kBlackColor54
        numPeopleLabel.textAlignment = .center
        baseView.addSubview(numPeopleLabel)
        
        shareButton.frame = CGRect(x: InvitationCellShareButtonHolizonMargin,
                                  y: numPeopleLabel.bottom + InvitationCellBaseHolizonMargin,
                                  width: baseView.width - (InvitationCellShareButtonHolizonMargin * 2),
                                  height: InvitationCellShareButtonHeight)
        shareButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        shareButton.setTitleColor(UIColor.white, for: .normal)
        shareButton.setTitle("ともだちにシェアする", for: .normal)
        shareButton.setBackgroundImage(UIImage(named: "img_stretch_btn")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        shareButton.contentHorizontalAlignment = .center
        shareButton.contentVerticalAlignment = .center
        shareButton.clipsToBounds = true
        shareButton.layer.cornerRadius = 3.0
        shareButton.addTarget(self, action: #selector(self.shareButtonTapped(_:)), for: .touchUpInside)
        baseView.addSubview(shareButton)
        
        reviewButton.frame = CGRect(x: shareButton.x,
                                   y: shareButton.bottom + InvitationCellBaseHolizonMargin,
                                   width: shareButton.width,
                                   height: shareButton.height)
        reviewButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        reviewButton.setTitleColor(kMainGreenColor, for: .normal)
        reviewButton.setTitle("レビューに書き込む", for: .normal)
        reviewButton.contentHorizontalAlignment = .center
        reviewButton.contentVerticalAlignment = .center
        reviewButton.clipsToBounds = true
        reviewButton.layer.cornerRadius = 3.0
        reviewButton.setBackgroundColor(UIColor.white, state: .normal)
        reviewButton.setBackgroundImage(UIImage(named: "img_stretch_btn_03")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
            reviewButton.addTarget(self, action: #selector(self.reviewButtonTapped(_:)), for: .touchUpInside)
        baseView.addSubview(reviewButton)
        
        self.height = reviewButton.bottom + 10.0
        baseView.height = reviewButton.bottom + 10.0
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        return InvitationCellTitleLabelHolizonMargin + (InvitationCellBaseHolizonMargin * 5) + InvitationCellTitleLabelSize.height + InvitationCellCodeLabelSize.height + InvitationCellNumPeopleLabelSize.height + InvitationCellShareButtonHeight * 2
    }
    
    override open var cellModelObject: AnyObject? {
        didSet {
            let numOfInvitePeople: String = cellModelObject as? String ?? 0.string()
            numPeopleLabel.text = "現在\(numOfInvitePeople)人に招待されました"
        }
    }
    
    func shareButtonTapped(_ sender: UIButton) {
        (self.delegate as? InvitationCellDelegate)?.invitationCellShareButtonTapped(self)
    }
    
    func reviewButtonTapped(_ sender: UIButton) {
        (self.delegate as? InvitationCellDelegate)?.invitationCellReviewButtonTapped(self)
    }
    
}
