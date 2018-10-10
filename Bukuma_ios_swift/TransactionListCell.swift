
//
//  TodoListCell.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/06.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

// 下記定数は他クラスでも参照されているものがあるので注意！（変更必須！！！）
let dateLabelHeight: CGFloat = 15.0

private let transactionBookImageWidth: CGFloat = 40.0
private let transactionBookImageHeight: CGFloat = transactionBookImageWidth * 1.48

let transactionIconSize: CGSize = CGSize(width: 32, height: 32)
private let leftIconMargin: CGFloat = 11.0
private let rightIconMargin: CGFloat = 9.0

let transactionTextWidth: CGFloat = kCommonDeviceWidth - transactionIconSize.width - bookImageViewWidth - 8.0 * 3 - 12.0
private let privateTransactionTextWidth: CGFloat = kCommonDeviceWidth - leftIconMargin - transactionIconSize.width - rightIconMargin - transactionTextRightMargin
private let transactionTextLineSpace: CGFloat = 3.0
private let transactionTitleTextLineSpace: CGFloat = 7.0

private let dateLabelTopMargin: CGFloat = 12.0 - transactionTextLineSpace

private let transactionTextRightMargin: CGFloat = 56.0
private let transactionTextBottomMargin: CGFloat = 40.0


open class TransactionListCell:UserIconCell {
    
    let textlabel: UILabel! = UILabel()
    let dateLabel: UILabel! = UILabel()
    let bookImageView: UIImageView! = UIImageView()

    private let whosTodoColor: UIView! = UIView()
    private let whosTodoColorWidth: CGFloat = 3.0

    required public init(reuseIdentifier: String, delegate: BaseTableViewCellDelegate) {
        super.init(reuseIdentifier: reuseIdentifier, delegate: delegate)
        self.delegate = delegate
        
        iconImageViewButton.x = leftIconMargin
        iconImageViewButton.viewSize = transactionIconSize
        iconImageViewButton.layer.borderWidth = 0.5
        iconImageViewButton.layer.borderColor = kBlackColor12.cgColor
        iconImageViewButton.layer.cornerRadius = iconImageViewButton.height / 2
        
        textlabel.frame = CGRect(x: iconImageViewButton.right + rightIconMargin,
                                 y: iconImageViewButton.y,
                                 width: privateTransactionTextWidth,
                                 height: 0)
        textlabel.lineBreakMode = .byCharWrapping
        textlabel.numberOfLines = 0
        self.contentView.addSubview(textlabel)
        
        dateLabel.frame = CGRect(x: textlabel.x,
                                 y: textlabel.bottom + dateLabelTopMargin,
                                 width: 0,
                                 height: 0)
        dateLabel.textColor = kGrayColor
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(dateLabel)
        
        bookImageView.frame = CGRect(x: kCommonDeviceWidth - transactionBookImageWidth - 8.0,
                                     y: iconImageViewButton.y,
                                     width: transactionBookImageWidth,
                                     height: transactionBookImageHeight)
        bookImageView.contentMode = .scaleAspectFill
        bookImageView.clipsToBounds = true
        bookImageView.layer.borderWidth = 0.5
        bookImageView.layer.borderColor = kBorderColor.cgColor
        self.contentView.addSubview(bookImageView)

        self.whosTodoColor.frame = CGRect(x: 0, y: 0, width: self.whosTodoColorWidth, height: self.frame.size.height)
        self.contentView.addSubview(self.whosTodoColor)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.whosTodoColor.frame = CGRect(x: 0, y: 0, width: self.whosTodoColorWidth, height: self.frame.size.height)
    }

    private let normalGrayDigit: [String: Any] = [NSForegroundColorAttributeName: UIColor(red: 112/255, green: 130/255, blue: 142/255, alpha: 1.0),
                                                  NSFontAttributeName: UIFont.init(name: "HelveticaNeue", size: 14) ?? UIFont.systemFont(ofSize: 14)]
    private let normalGraySuffix: [String: Any] = [NSForegroundColorAttributeName: UIColor(red: 112/255, green: 130/255, blue: 142/255, alpha: 1.0),
                                                  NSFontAttributeName: UIFont.systemFont(ofSize: 13)]

    override open var cellModelObject: AnyObject? {
        didSet {
            let transaction = cellModelObject as? Transaction
            
            if transaction?.oppositeUser()?.photo?.imageURL != nil {
                self.iconImageViewButton.downloadImageWithURL(transaction?.oppositeUser()?.photo?.imageURL, placeholderImage: kPlaceholderUserImage)
            } else {
                self.iconImageViewButton.setImage(kPlaceholderUserImage, for: .normal)
            }

            if transaction?.merchandise?.book?.coverImage?.url != nil {
                self.bookImageView.downloadImageWithURL(transaction?.merchandise?.book?.coverImage?.url as URL?, placeholderImage: kPlacejolderBookImage)
            } else {
                self.bookImageView.image = kPlacejolderBookImage
            }
            
            if transaction?.type != nil {
                let initialSize = CGSize(width: privateTransactionTextWidth, height: 0)
                self.textlabel.frame.size = initialSize
                self.textlabel.attributedText = type(of: self).statusString(withTransaction: transaction!)
                self.textlabel.sizeToFit()
            }

            if let timeString = transaction?.updatedAt?.timeAgoSimple() {
                if let digitRange = timeString.range(of: "\\d+", options: .regularExpression, range: nil, locale: .current) {
                    let digitString = timeString.substring(with: digitRange)
                    let suffix = timeString.substring(from: digitRange.upperBound)

                    let dateString = NSMutableAttributedString()
                    dateString.append(NSAttributedString(string: digitString, attributes: self.normalGrayDigit))
                    dateString.append(NSAttributedString(string: suffix, attributes: self.normalGraySuffix))
                    self.dateLabel.attributedText = dateString
                } else {
                    self.dateLabel.text = timeString
                }
            } else {
                self.dateLabel.text = ""
            }
            self.dateLabel.sizeToFit()
            self.dateLabel.y = self.textlabel.bottom + dateLabelTopMargin
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open class func cellHeightForObject(_ object: AnyObject?) ->CGFloat {
        var labelHeight: CGFloat = 0
        if let transaction = object as? Transaction {
            let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: privateTransactionTextWidth, height: 0))
            tempLabel.lineBreakMode = .byCharWrapping
            tempLabel.numberOfLines = 0
            tempLabel.attributedText = self.statusString(withTransaction: transaction)
            tempLabel.sizeToFit()
            labelHeight = tempLabel.frame.size.height
        }
        let minHeight = transactionBookImageHeight + (UserIconCellBaseVerticalMargin * 2)
        let maxHeight = labelHeight + UserIconCellBaseVerticalMargin + transactionTextBottomMargin
        return max(minHeight, maxHeight)
    }

    private static let nonameUser: String = "退会したユーザー"
    private static let statusGrayColor: UIColor = UIColor(red: 47/255, green: 44/255, blue: 44/255, alpha: 0.87)
    private class func lineHeightStyle(with lineSpace: CGFloat)-> NSMutableParagraphStyle {
        let lineHeightStyle = NSMutableParagraphStyle()
        lineHeightStyle.lineSpacing = lineSpace
        return lineHeightStyle
    }
    private static let boldBlackAttribute: [String: Any] = [NSForegroundColorAttributeName: kBlackColor87,
                                                            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13),
                                                            NSParagraphStyleAttributeName: lineHeightStyle(with: transactionTextLineSpace)]
    private static let normalBlackAttribute: [String: Any] = [NSForegroundColorAttributeName: kBlackColor87,
                                                              NSFontAttributeName: UIFont.systemFont(ofSize: 13),
                                                              NSParagraphStyleAttributeName: lineHeightStyle(with: transactionTextLineSpace)]
    private static let boldBlackBiggerAttribute: [String: Any] = [NSForegroundColorAttributeName: kBlackColor87,
                                                                  NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14),
                                                                  NSParagraphStyleAttributeName: lineHeightStyle(with: transactionTitleTextLineSpace)]
    private static let boldGrayAttribute: [String: Any] = [NSForegroundColorAttributeName: statusGrayColor,
                                                           NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13),
                                                           NSParagraphStyleAttributeName: lineHeightStyle(with: transactionTextLineSpace)]
    private static let normalGrayAttribute: [String: Any] = [NSForegroundColorAttributeName: statusGrayColor,
                                                             NSFontAttributeName: UIFont.systemFont(ofSize: 13),
                                                             NSParagraphStyleAttributeName: lineHeightStyle(with: transactionTextLineSpace)]

    private class func statusString(withTransaction transaction: Transaction)-> NSAttributedString {
        if transaction.isBuyer() == true {
            switch transaction.type! {
            case .sellerPrepareShipping:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: transaction.seller?.nickName ?? self.nonameUser, attributes: self.boldBlackAttribute))
                statusString.append(NSAttributedString(string: "さんの発送待ちです。発送までお待ち下さい", attributes: self.normalBlackAttribute))
                return statusString

            case .sellerShipped:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: "届いたら受け取り連絡をしてください。\n", attributes: self.boldBlackBiggerAttribute))
                statusString.append(NSAttributedString(string: transaction.seller?.nickName ?? self.nonameUser, attributes: self.boldGrayAttribute))
                statusString.append(NSAttributedString(string: "さんが本を発送しました。\n到着まで今しばらくお待ち下さい。", attributes: self.normalGrayAttribute))
                return statusString

            case .buyerItemArried, .sellerReviewBuyer:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: "取引相手がレビューを書いています。取引終了までお待ち下さい。", attributes: self.normalBlackAttribute))
                return statusString

            case .finishedTransaction:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: transaction.seller?.nickName ?? self.nonameUser, attributes: self.boldBlackAttribute))
                statusString.append(NSAttributedString(string: "さんがレビューを書きました。取引が完了しました。", attributes: self.normalBlackAttribute))
                return statusString

            case .pendingReviewByStuff, .cancelled:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: "本取引はキャンセルされました。運営からのご連絡をお待ち下さい。", attributes: self.normalBlackAttribute))
                return statusString

            default:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: "不明な取引です。", attributes: self.normalBlackAttribute))
                return statusString
            }
        } else {
            switch transaction.type! {
            case .initial:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: "本を出品しました。購入されるまでお待ち下さい。", attributes: self.normalBlackAttribute))
                return statusString

            case .sellerPrepareShipping:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: "本の発送準備を行いましょう。\n", attributes: self.boldBlackBiggerAttribute))
                statusString.append(NSAttributedString(string: transaction.boughtBy?.nickName ?? self.nonameUser, attributes: self.boldGrayAttribute))
                statusString.append(NSAttributedString(string: "さんが『", attributes: self.normalGrayAttribute))
                statusString.append(NSAttributedString(string: transaction.bookTitle(), attributes: self.boldGrayAttribute))
                statusString.append(NSAttributedString(string: "』を購入しました。", attributes: self.normalGrayAttribute))
                return statusString

            case .sellerShipped:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: transaction.boughtBy?.nickName ?? self.nonameUser, attributes: self.boldBlackAttribute))
                statusString.append(NSAttributedString(string: "さんの受け取り待ちです。", attributes: self.normalBlackAttribute))
                return statusString

            case .buyerItemArried:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: "レビューを書いて取引を完了してください。\n", attributes: self.boldBlackBiggerAttribute))
                statusString.append(NSAttributedString(string: transaction.boughtBy?.nickName ?? self.nonameUser, attributes: self.boldGrayAttribute))
                statusString.append(NSAttributedString(string: "さんが本を受け取りました。\n購入者のレビューを書きましょう。", attributes: self.normalGrayAttribute))
                return statusString

            case .sellerReviewBuyer:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: transaction.boughtBy?.nickName ?? self.nonameUser, attributes: self.boldBlackAttribute))
                statusString.append(NSAttributedString(string: "さんへレビューを送信しました。取引完了までお待ち下さい。", attributes: self.normalBlackAttribute))
                return statusString

            case .finishedTransaction:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: "取引が完了しました。", attributes: self.normalBlackAttribute))
                return statusString

            case .pendingReviewByStuff, .cancelled:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: "本取引はキャンセルされました。運営からのご連絡をお待ち下さい。", attributes: self.normalBlackAttribute))
                return statusString

            case .unknown:
                let statusString = NSMutableAttributedString()
                statusString.append(NSAttributedString(string: "不明な取引です。", attributes: self.normalBlackAttribute))
                return statusString
            }
        }
    }

    private let myTodoColor: UIColor = UIColor(red: 232/255, green: 99/255, blue: 124/255, alpha: 1)
    private let yourTodoColor: UIColor = UIColor(red: 179/255, green: 181/255, blue: 191/255, alpha: 0.99)

    func markAsMyToDo(_ markForMe: Bool) {
        self.whosTodoColor.backgroundColor = markForMe ? self.myTodoColor : self.yourTodoColor
    }
}
