//
//  BarcodeScannerBookDisplayView.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/28.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

@objc public protocol BarcodeScannerBookDisplayViewDelegate: SheetViewDelegate{
    func displayViewExhibitButtonTapped(_ displayview: BarcodeScannerBookDisplayView)
    func displayViewRetryButtonTapped(_ displayview: BarcodeScannerBookDisplayView)
    func displayViewCancelButtonTapped(_ displayview: BarcodeScannerBookDisplayView)
}

open class BarcodeScannerBookDisplayView: SheetView {
    
    fileprivate let bookImageView: UIImageView! = UIImageView()
    fileprivate let bookTitleLabel: UILabel! = UILabel()
    fileprivate let scanSatusLabel: UILabel! = UILabel()
    fileprivate let exhibitButton: UIButton! = UIButton()
    fileprivate let retryButton: UIButton! = UIButton()
    fileprivate let cancelButton: UIButton! = UIButton()
    
    required public init (delegate: SheetViewDelegate?) {
        super.init(delegate: delegate)
        
        sheetView.width = 290
        sheetView.x = (kCommonDeviceWidth - sheetView.width) / 2
        
        let cancelButtonImage: UIImage = UIImage(named: "ic_nav_back")!
        cancelButton.frame = CGRect(x: sheetView.width - cancelButtonImage.size.width, y: 0, width: cancelButtonImage.size.width, height: cancelButtonImage.size.height)
        cancelButton.addTarget(self, action: #selector(self.cancelButtonTapped(_:)), for: .touchUpInside)
        sheetView.addSubview(cancelButton)
        
        bookImageView.viewSize = CGSize(width: 66.0, height: 97.0)
        bookImageView.viewOrigin = CGPoint(x: (sheetView.width -  bookImageView.width) / 2, y: 32)
        bookImageView.clipsToBounds = true
        bookImageView.layer.cornerRadius = 2.0
        sheetView.addSubview(bookImageView)
        
        bookTitleLabel.frame = CGRect(x: 20.0, y: bookImageView.bottom + 25.0, width: sheetView.width - 20 * 2, height: 30)
        bookTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        bookTitleLabel.textColor = kBlackColor87
        bookTitleLabel.textAlignment = .center
        sheetView.addSubview(bookTitleLabel)
        
        scanSatusLabel.frame = CGRect(x: 0, y: bookTitleLabel.bottom + 3.5, width: sheetView.width, height: 20)
        scanSatusLabel.font = UIFont.boldSystemFont(ofSize: 13)
        scanSatusLabel.textColor = kGray03Color
        scanSatusLabel.textAlignment = .center
        scanSatusLabel.text = "読み込みに成功しました"
        sheetView.addSubview(scanSatusLabel)
        
        exhibitButton.viewSize = CGSize(width: sheetView.width - 20 * 2, height: UIImage(named: "img_stretch_btn")!.size.height)
        exhibitButton.viewOrigin = CGPoint(x: 20.0, y: scanSatusLabel.bottom + 24)
        exhibitButton.setBackgroundColor(kMainGreenColor, state: .normal)
        exhibitButton.clipsToBounds = true
        exhibitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        exhibitButton.setTitle("この本を出品する", for: .normal)
        exhibitButton.setTitleColor(UIColor.white, for: .normal)
        exhibitButton.setBackgroundImage(UIImage(named: "img_stretch_btn")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        exhibitButton.addTarget(self, action: #selector(self.exhibitButtonTapped(_:)), for: .touchUpInside)
        sheetView.addSubview(exhibitButton)
        
        retryButton.frame = exhibitButton.frame
        retryButton.height = UIImage(named: "img_stretch_btn_02")!.size.height
        retryButton.y = exhibitButton.bottom + 11
        retryButton.setBackgroundColor(UIColor.white, state: .normal)
        retryButton.clipsToBounds = true
        retryButton.setTitle("やり直す", for: .normal)
        retryButton.setBackgroundImage(UIImage(named: "img_stretch_btn_02")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 0), for: .normal)
        retryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        retryButton.setTitleColor(kGray02Color, for: .normal)
        retryButton.addTarget(self, action: #selector(self.retryButtonTapped(_:)), for: .touchUpInside)
        sheetView.addSubview(retryButton)
        
        sheetView.height = retryButton.bottom + 18.0

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    var book: Book? {
        didSet {            
            if book?.coverImage?.url != nil {
                bookImageView.downloadImageWithURL(book?.coverImage?.url, placeholderImage: kPlacejolderBookImage)

            } else {
                bookImageView.image = kPlacejolderBookImage
            }

            bookTitleLabel.text = book?.title
        }
    }
    
    func cancelButtonTapped(_ sender: UIButton) {
        self.disappear(nil)
        (self.delegate as? BarcodeScannerBookDisplayViewDelegate)?.displayViewCancelButtonTapped(self)
    }
    
    func exhibitButtonTapped(_ sender: UIButton) {
        (self.delegate as? BarcodeScannerBookDisplayViewDelegate)?.displayViewExhibitButtonTapped(self)
    }
    
    func retryButtonTapped(_ sender: UIButton) {
        self.disappear(nil)
        (self.delegate as? BarcodeScannerBookDisplayViewDelegate)?.displayViewRetryButtonTapped(self)
    }
}
