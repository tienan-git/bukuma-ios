//
//  InvitationHeaserView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/15.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

private let InvitationHeaderViewTopImageViewHeight: CGFloat = 150.0
private let InvitationHeaderViewTitleLabelSize: CGSize = CGSize(width: kCommonDeviceWidth - 30.0, height: 25.0)

open class InvitationHeaderView: UIView {
    
    fileprivate let topImageView: UIImageView! = UIImageView()
    fileprivate let titleLabel: UILabel! = UILabel()
    fileprivate let detailLabel: UILabel! = UILabel()
    
    required public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 0))
        
        self.backgroundColor = UIColor.white
        
        let backGroundGreenView = UIView(frame: CGRect(x: 0, y: -backGroundGreenViewHeight, width: kCommonDeviceWidth, height: 0))
        backGroundGreenView.backgroundColor = kTintGreenColor
        self.addSubview(backGroundGreenView)
        
        topImageView.frame = CGRect(x: 0,
                                    y: -NavigationHeightCalculator.navigationHeight(),
                                    width: kCommonDeviceWidth,
                                    height: self.logoImageView()!.size.height)
        topImageView.image = self.logoImageView()!
        self.addSubview(topImageView)
        
        titleLabel.frame = CGRect(x: (kCommonDeviceWidth - InvitationHeaderViewTitleLabelSize.width) / 2,
                                  y: topImageView.bottom + 20.0,
                                  width: InvitationHeaderViewTitleLabelSize.width,
                                  height: InvitationHeaderViewTitleLabelSize.height)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = kDarkGray04Color
        titleLabel.text = "友達を招待してポイントゲット"
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)

        detailLabel.frame = CGRect(x: (kCommonDeviceWidth - InvitationHeaderViewTitleLabelSize.width) / 2,
                                  y: titleLabel.bottom + 20.0,
                                  width: InvitationHeaderViewTitleLabelSize.width,
                                  height: InvitationHeaderViewTitleLabelSize.height)
        detailLabel.font = UIFont.systemFont(ofSize: 15)
        detailLabel.textAlignment = .left
        detailLabel.numberOfLines = 0
        detailLabel.attributedText = InvitationHeaderView.generateAtrributeText()
        detailLabel.height = detailLabel.attributedText!.getTextHeight(detailLabel.width)
        self.addSubview(detailLabel)
    
        self.height = detailLabel.bottom + 20.0
        backGroundGreenView.height = backGroundGreenViewHeight + topImageView.height - NavigationHeightCalculator.navigationHeight()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func logoImageView() -> UIImage? {
        if UIScreen.is3_5inchDisplay() {
            return UIImage(named: "img_cover_invite_3-5inch")!
        } else if UIScreen.is4inchDisplay() {
            return UIImage(named: "img_cover_invite_4inch")!
        } else if UIScreen.is4_7inchDisplay() {
            return UIImage(named: "img_cover_invite_4-7inch")!
        } else if UIScreen.is5_5inchDisplay() {
            return UIImage(named: "img_cover_invite_5-5inch")!
        }
        return nil
    }
    
    fileprivate class func generateAtrributeText() ->NSAttributedString {
        let mutableAttributedString: NSMutableAttributedString =  NSMutableAttributedString()
        let firstSystemString: NSAttributedString = NSAttributedString.init(string: "ともだちがブクマに会員登録をするときに招待コードを入れると、",
                                                                             attributes: [NSForegroundColorAttributeName:kBlackColor54, NSFontAttributeName:UIFont.systemFont(ofSize: 15)])
        mutableAttributedString.append(firstSystemString)

        let invitationPointMessage = String(format: "あなたと友達両方に%d円分のポイントをプレゼント!! ", ExternalServiceManager.invitationPoint)
        let firstAttributedText =  NSAttributedString.init(string: invitationPointMessage,
                                                               attributes: [NSForegroundColorAttributeName:kMainGreenColor, NSFontAttributeName:UIFont.systemFont(ofSize: 15)])
        mutableAttributedString.append(firstAttributedText)
        
        let secondSystemString: NSAttributedString = NSAttributedString.init(string: "AppleStoreのレビューで紹介しよう！",
                                                                          attributes: [NSForegroundColorAttributeName:kBlackColor54, NSFontAttributeName:UIFont.systemFont(ofSize: 15)])
        mutableAttributedString.append(secondSystemString)
        
        return mutableAttributedString
    }
    
}
