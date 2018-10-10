//
//  Const.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/14.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//


// よく使うカラーとか、よく使う定数をここにまとめている

//CGFloat
public let kCommonStatusBarHeight = UIApplication.shared.statusBarFrame.size.height
public let kCommonTabBarHeight: CGFloat = 49
public let kCommonNavigationBarHeight: CGFloat = 44.0
public let kCommonDeviceWidth = UIScreen.main.bounds.size.width
public let kCommonDeviceHeight = UIScreen.main.bounds.size.height
public let kCommonTableSectionHeight: CGFloat = 8.0
public let kDrawerWidth: CGFloat = kDrawerViewController?.drawerWidth ?? 0
public let HomeCollectionGridWidth: CGFloat = (kCommonDeviceWidth - 10 * 3) / 2

//Colors
public let kMainGreenColor: UIColor = UIColor.colorWithHex(0x64C4A2)
public let kTintGreenColor: UIColor = UIColor.colorWithHex(0x5BC19D)
public let kGrayColor: UIColor = UIColor.colorWithHex(0x5D6E7B)
public let kGray01Color: UIColor = UIColor.colorWithHex(0x87919F)
public let kGray02Color: UIColor = UIColor.colorWithHex(0x7B889B)
public let kGray03Color: UIColor = UIColor.colorWithHex(0x5C6572)
public let kDarkGray01Color: UIColor = UIColor.colorWithHex(0x707078)
public let kDarkGray02Color: UIColor = UIColor.colorWithHex(0x585862)
public let kDarkGray03Color: UIColor = UIColor.colorWithHex(0x4E4E57)
public let kDarkGray04Color: UIColor = UIColor.colorWithHex(0x212121)
public let kPink01Color: UIColor = UIColor.colorWithHex(0xEF767A)
public let kPink02Color: UIColor = UIColor.colorWithHex(0xDD525F)
public let kBackGroundColor: UIColor = UIColor.colorWithHex(0xECEDED)
public let kBorderColor: UIColor = UIColor.colorWithHex(0xE0E0E0)
public let kTitleBlackColor = UIColor.colorWithHex(0x191919)
public let kSheetBackGroundColor = UIColor.colorWithHex(0x000000, alpha: 0.7)
public let kAttributeColor = UIColor.colorWithHex(0x3e4046)
public let kLightGrayColor = UIColor.colorWithHex(0xe0e0e0)
public let kCellisSelectedBackgroundColor = UIColor.colorWithHex(0xf7f7f7)
public let kTitleBoldBlackColor = UIColor.colorWithHex(0x212121)
public let kdeltailGrayColor = UIColor.colorWithHex(0x626E77)

public let kBlackColor12 = UIColor.black.withAlphaComponent(0.12)
public let kBlackColor26 = UIColor.black.withAlphaComponent(0.26)
public let kBlackColor54 = UIColor.black.withAlphaComponent(0.54)
public let kBlackColor87 = UIColor.black.withAlphaComponent(0.87)
public let kBlackColor80 = UIColor.black.withAlphaComponent(0.80)
public let kBlackColor70 = UIColor.black.withAlphaComponent(0.70)

public let kWhiteColor70 = UIColor.white.withAlphaComponent(0.70)

//Strings
//public let kLoadingBookMessage: String = "情報を取得しています。情報取得まで数分かかる場合があります。"
public let chatsTableName: String = "chats"
public let chatsLists: String = "chatsLists"

public let kAppID = "1141332201"
public let kAppName = "ブクマ！"

public let kAppStoreURL: String = "https://itunes.apple.com/app/jp/id1141332201?mt=8"
public let kTermURL: String = "http://static.bukuma.io/bkm_app/terms-of-use.html"
public let kPrivacyURL: String = "http://static.bukuma.io/bkm_app/privacy-policy.html"
public let kCommercialTransactionsLawURL: String = "http://static.bukuma.io/bkm_app/s-c-t-l.html"
public let kShareLink: String = "http://hyperurl.co/01o4af"

// image
public let kPlaceholderUserImage: UIImage = UIImage(named: "img_thumbnail_user")!
public let kPlacejolderBookImage: UIImage = UIImage(named: "img_preset_book")!


public let kAppDelegate = (UIApplication.shared.delegate! as!AppDelegate)
//色々試したけど、このアクセスの仕方じゃないとアクセスできない
public var kRootViewControllerController =  (kAppDelegate.drawerViewController.mainViewController as! NavigationController).viewControllers[0]
public var kDrawerViewController = kAppDelegate.drawerViewController

//Debug 
public let kDebugCreditCardNumber = "5555555555554444"
public let ProductionOmiseTokenKey = "pkey_54q559ummmk8se3e8pw"
public let kDebugOmiseCardName = "TARO OMISE"
public let kDebugOmiseExpireYear = "2016"
public let kDebugOmiseExpireMonth = "9"
public let kDebugOmiseSeqCode = "8887"
public let kDebugOmiseTokenKey = "pkey_test_54etvz3ds03qtbgmvbj"
