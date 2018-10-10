//
//  BKMError.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/10.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

/**
 このClassではErrorの管理をしています
 serverから受け取ったError codeに応じて、Error messageの文章を作ったりしています
 */

import SwiftyJSON

public let ErrorDomain = "com.labit.error"
let ErrorAccountBanNotification = "ErrorAccountBanNotification"
let ErrorOfflineNotification = "ErrorOfflineNotification"
let ErrorMaintenanceNotification = "ErrorMaintenanceNotification"

public enum ErrorCodeType: Int {
    case unknownError                = 0 ///不明なエラー
    case invalidParameter            = -1 ///parameterが違う
    case userNotFound                = -5 ///ユーザーがいない
    case chatRoomNotFound            = -7 ///chattoomがない
    case chatMessageNotFound         = -8 ///chatroomのmessageがない
    case userNotFoundAtChatRoom      = -9 ///ユーザーがchatroomに見つからない
    case invalidPassword             = -11 ///違うpassword
    case userBlocked                 = -12 ///ブロックしているユーザーにchatしようとするとこのエラー
    case aleadyConnectSNS            = -16 ///すでにSNSにconnectしている
    case userBanned                  = -20 ///banされている
    case facebookWrongToken          = 190 ///facebookのacsesstokenがなんかおかしい
    case passWordDifference          = -201 ///違うpassword
    case emailIsAlreadyTaken         = -203 ///すでに登録してあるemailを登録しようとするとこのエラー
    case shouldRecaluclate           = -332 ///Pointがうまくシンクロしていないとき。再計算をすべき時
    case bookNotFound                = -325 ///その本がない
    case pointInsufficient           = -326 ///Pointが不足して本が買えない
    case alreadySold                 = -327 ///その本はすでに売られているので買えない
    case activeWithdraw              = -334 ///申請中の売上きんがあるので退会できない
    case badRequest                  = 400 ///悪いリクエストをendpointに送ってる
    case notFound                    = 404 ///見つからない
    case wrongRefreshToken           = 401 ///無効なacsesstokN
    case accessForbidden             = 403 ///アクセス禁止。例えば、すでにlikeしている本にlikeを送る
    case internalServerError         = 500 ///serverのエラー
    case serviceUnavailable          = 503 ///メンテナンス
    case offline                     = -1009 ///offline
    case noInternetConnection        = -1004 ///internet接続ができない
    case timeOut                     = -1001 ///リクエストが長すぎてtimeout
}

open class Error: NSError {
    
    open var isServerError: Bool?
    open var errorDespription: String {
        get {
            if errorCodeType == nil {
                return "不明なエラー"
            }            
            switch self.errorCodeType! {
            case .chatMessageNotFound:
                return "メッセージが見つかりません"
            case .chatRoomNotFound:
                return "チャットルームが見つかりません"
            case .userNotFoundAtChatRoom:
                return "チャットルームにユーザーがいません"
            case .userBlocked:
                return "ブロックされています"
            case .aleadyConnectSNS:
                return "このSNSアカウントはすでに登録されています"
            case .emailIsAlreadyTaken:
                return "すでに使われているEmailです"
            case .passWordDifference:
                return "パスワードが違います"
            case .notFound:
                return "見つかりません"
            case .bookNotFound:
                return "本が見つかりません"
            case .wrongRefreshToken:
                return "refresh_tokenがおかしいです。"
            case .accessForbidden,
                 .internalServerError:
                return "不明なエラーです"
            case .offline:
                return "端末がオフラインです"
            case .noInternetConnection:
                return "インターネット接続ができません"
            case .facebookWrongToken:
                return "不正なFacebookアクセストークンです"
            case .invalidPassword:
                return "パスワードが違います"
            case .userNotFound:
                return "ユーザーが見つかりません"
            case .activeWithdraw:
                return "振り込まれていない売上金があるため退会できません。"
            case .serviceUnavailable:
                return "メンテナンス中です"
            default:
                return "不明なエラー"
            }
        }
        set(newValue) {
            self.errorDespription = newValue
        }
    }

    open var errorCodeType: ErrorCodeType?
    open var debugErrorMessage: String?
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(domain: String, code: Int, userInfo dict: [AnyHashable: Any]?) {
        super.init(domain: domain, code: code, userInfo: dict)
        
        self.errorCodeType = ErrorCodeType(rawValue: code)
        let errorInfo: [AnyHashable: Any]? = dict
        let serverMessage: String? = errorInfo?[NSLocalizedDescriptionKey].map{String(describing: $0)}
        let remoteUrlPath: String? = errorInfo?["NSErrorFailingURLKey"].map{String(describing: $0)}
        
        debugErrorMessage = "[message]: \(String(describing: serverMessage)) [error path]: \(String(describing: remoteUrlPath))"
        DBLog(debugErrorMessage)
        
    }
    
    public init(type: ErrorCodeType) {
        super.init(domain: ErrorDomain, code: type.rawValue, userInfo: nil)
        errorCodeType = type
    }
    
    public convenience init(errorDic: [String: Any], path: URL) {
        self.init(domain: ErrorDomain, code: errorDic["error_code"] as! Int, userInfo: nil)
        let message: String? = errorDic["message"].map{String(describing: $0)}
        let errorPass: String = path.absoluteString 
        
        debugErrorMessage = "[message]: \(String(describing: message)) [error path]: \(errorPass)"
        DBLog(debugErrorMessage)
    }
    
    public convenience init(json: SwiftyJSON.JSON, path: URL?) {
        self.init(domain: ErrorDomain, code: json["error_code"].intValue, userInfo: nil)
        let message = json["message"].stringValue
        let errorPass = path?.absoluteString ?? ""
        
        debugErrorMessage = "[message]: \(message)) [error path]: \(errorPass)"
        DBLog(debugErrorMessage)
    }
    
    public convenience init(FcaebookErrorCode: Int) {
        self.init(domain: ErrorDomain, code: FcaebookErrorCode, userInfo: nil)
        
        self.errorCodeType = ErrorCodeType(rawValue: code)
    }
    
    public convenience init(facebookErrorDic: [String: AnyObject]) {
       self.init(domain: ErrorDomain, code: facebookErrorDic["error"]!["code"] as! Int, userInfo: nil)
        
        let message: String? = facebookErrorDic["message"].map{String(describing: $0)}
        
        debugErrorMessage = "[message]: \(String(describing: message))"
        DBLog(debugErrorMessage)
    }

    fileprivate class func isServerErrorWithErrorCode(_ code: Int) ->Bool{
        return code >= 500
    }
    
    func postNotification() {
        if errorCodeType == .userBanned {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ErrorAccountBanNotification), object: nil)
            NotificationCenter.default.removeObserver(UIApplication.shared.delegate!, name: NSNotification.Name(rawValue: ErrorAccountBanNotification), object: nil)
        }
        if errorCodeType == .offline {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ErrorOfflineNotification), object: nil)
        }
        if errorCodeType == .serviceUnavailable {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ErrorMaintenanceNotification), object: nil)
        }
    }
}
