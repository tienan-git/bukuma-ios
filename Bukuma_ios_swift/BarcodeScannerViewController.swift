//
//  BarcodeScannerViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/18.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD
import MTBBarcodeScanner

open class BarcodeScannerViewController: BaseDataSourceViewController,
BarcodeScannerBookDisplayViewDelegate {

    var scanner: MTBBarcodeScanner!
    var displayView: BarcodeScannerBookDisplayView?
    var tutorialView: BaseSuggestView?
    var timer: Timer?
    var loadingView: LoadingImageView?
    
    // ================================================================================
    // MARK: -init
    
    deinit {
        DBLog("---------------deinit BarcodeScannerViewController ----------")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var shouldShowLeftNavigationButton: Bool {
        get {
            return false
        }
    }
    
    // ================================================================================
    // MARK: - viewC
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarView?.backgroundColor = UIColor.black
        
        let previewImageView = UIView.init(frame: CGRect(x: 0, y: navigationBarView!.bottom, width: kCommonDeviceWidth, height: kCommonDeviceHeight - 180))
        previewImageView.backgroundColor = UIColor.black
        self.view.addSubview(previewImageView)
        
        let barcodeImage: UIImage = UIImage(named: "barcode")!
        
        let scanImageView = UIImageView.init(frame: CGRect(x: (kCommonDeviceWidth - barcodeImage.size.width) / 2, y: 0, width: barcodeImage.size.width, height: barcodeImage.size.height))
        scanImageView.y = (previewImageView.height - scanImageView.height) / 2
        scanImageView.image = barcodeImage
        previewImageView.addSubview(scanImageView)

        let descriptionView: UIView = UIView.init(frame: CGRect(x: 0, y: previewImageView.bottom, width: kCommonDeviceWidth, height: kCommonDeviceHeight - previewImageView.height))
        descriptionView.backgroundColor = UIColor.black
        self.view.addSubview(descriptionView)
        
        let descriptionLabel: UILabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: 50))
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 13)
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "978 - から始まるバーコードを読み取ります"
        descriptionView.addSubview(descriptionLabel)
        
        let searchFromTitleButton: UIButton = UIButton.init(frame: CGRect(x: 10, y: descriptionLabel.bottom, width: kCommonDeviceWidth - 10 * 2, height: 50))
        searchFromTitleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        searchFromTitleButton.titleLabel?.textAlignment = .center
        searchFromTitleButton.setTitleColor(UIColor.white, for: .normal)
        searchFromTitleButton.setTitle("直接タイトル入力", for: .normal)
        searchFromTitleButton.layer.borderWidth = 1
        searchFromTitleButton.layer.borderColor = UIColor.white.cgColor
        searchFromTitleButton.clipsToBounds = true
        searchFromTitleButton.layer.cornerRadius = 3.0
        searchFromTitleButton.addTarget(self, action: #selector(self.searchFromTitleButtonTapped(_:)), for: .touchUpInside)
        descriptionView.addSubview(searchFromTitleButton)
        
        displayView = BarcodeScannerBookDisplayView.init(delegate: self)
        
        self.scanner = MTBBarcodeScanner.init(metadataObjectTypes:[AVMetadataObjectTypeEAN13Code], previewView: previewImageView)
        self.scanner.didStartScanningBlock = { [weak self] () in
            self?.scanner.scanRect = scanImageView.frame
        }

        tutorialView = BaseSuggestView(delegate: self,
                                       image: UIImage(named: "img_tutorial_sell")!,
                                       title: "バーコードで簡単出品",
                                       detail: "本の背面にある\("97")で始まるバーコードを読み取ると、簡単に出品できます",
                                       buttonText: "OK、わかりました")
        
        if tutorialView?.finishFirstShow == true {
            self.scan()
        }
        
        loadingView = LoadingImageView()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarView?.backgroundColor = UIColor.black
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tutorialView?.finishFirstShow == false {
            tutorialView?.appearOnViewController(self.navigationController ?? self)
            return
        }
        self.restartScanning()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationBarView?.backgroundColor = kMainGreenColor
    }
    
    open override func baseSuggestViewCancelButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {
        self.scan()
    }
    
    open override func baseSuggestViewActionButtonTapped(_ view: BaseSuggestView, completion:(() ->Void)?) {
        self.scan()
    }
    
    override func cancel(_ sender: UIBarButtonItem) {
        super.cancel(sender)
        if BarcodeScannerViewController.isRetry == true {
            self.simpleAlert(nil, message: "読み込み失敗しました", cancelTitle: "OK") {
                self.restartScanning()
            }
            BarcodeScannerViewController.retryCount = 0
            BarcodeScannerViewController.isRetry = false
            timer?.invalidate()
        }
    }

    private enum ScannedActionError {
        case noErr
        case searchBookErr
        case searchOrderErr
        case searchOrderNotFinishErr
    }

    private func scannedAction(with isbn: Int64, completion withError: @escaping (_ err: ScannedActionError, _ userInfo: SearchOrder?)-> Void) {
        self.view.isUserInteractionEnabled = false

        Book.searchBook(String(isbn), type: .isbn, page: 1) { [weak self] (books, error) in
            DispatchQueue.main.async {
                if error == nil {
                    if books != nil && Utility.isEmpty(books![0].title) == false {
                        // DB に登録あり
                        self?.view.isUserInteractionEnabled = true
                        self?.displayView?.book = books![0]
                        self?.displayView?.appearOnViewController(self!)
                        withError(.noErr, nil)
                    } else {
                        SVProgressHUD.dismiss()

                        self?.loadingView?.appearOnViewController(self?.navigationController ?? self!)
                        self?.loadingView?.startAnimation()

                        Book.createSearchOrder(String(isbn), type: .isbn) { (order, error) in
                            DispatchQueue.main.async {
                                if error == nil {
                                    if order?.isFinish == true {
                                        self?.loadingView?.stopAnimation()
                                        self?.loadingView?.disappear(nil)

                                        Book.searchBook(String(isbn), type: .isbn, page: 1) { (book, error) in
                                            self?.view.isUserInteractionEnabled = true
                                            if error == nil {
                                                self?.displayView?.book = books?[0]
                                                self?.displayView?.appearOnViewController(self!)
                                                withError(.noErr, nil)
                                            } else {
                                                withError(.searchBookErr, nil)
                                            }
                                        }
                                    } else {
                                        withError(.searchOrderNotFinishErr, order)
                                    }
                                } else {
                                    self?.loadingView?.stopAnimation()
                                    self?.loadingView?.disappear(nil)

                                    self?.view.isUserInteractionEnabled = true
                                    withError(.searchOrderErr, nil)
                                }
                            }
                        }
                    }
                } else {
                    self?.view.isUserInteractionEnabled = true
                    withError(.searchBookErr, nil)
                }
            }
        }
    }

    private func scannedActions(with isbn: Int64, completion withError: ((_ err: ScannedActionError, _ userInfo: SearchOrder?)-> Void)?) {
        self.scannedAction(with: isbn) { [weak self] (_ err: ScannedActionError, _ userInfo: SearchOrder?) in
            if err == .noErr {
                self?.isbnToRequest = [Int64]()
                withError?(err, userInfo)
            } else {
                self?.isbnToRequest.remove(at: 0)
                if let count = self?.isbnToRequest.count {
                    if count > 0 {
                        self?.scannedActions(with: (self?.isbnToRequest[0])!) { (_ err: ScannedActionError, _ userInfo: SearchOrder?) in
                            withError?(err, userInfo)
                            return
                        }
                    } else {
                        withError?(err, userInfo)
                    }
                } else {
                    withError?(err, userInfo)
                }
            }
        }
    }

    private func pauseScanning() {
        self.scanner.resultBlock = nil
    }

    private func restartScanning() {
        // 時間間隔をあけて再スキャンを受け付けるようにしないと self.displayView が再表示されない…
        Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.delayRestartScanning(_:)), userInfo: nil, repeats: false)
    }

    func delayRestartScanning(_ timer: Timer?) {
        self.scanner.resultBlock = self.myResultBlock
    }

    private var myResultBlock: ((_ scannedCodes: [AVMetadataMachineReadableCodeObject]?)-> Void)!
    private var isbnToRequest: [Int64] = [Int64]()

    func scan() {
        self.myResultBlock = { [weak self] (_ scannedCodes: [AVMetadataMachineReadableCodeObject]?)-> Void in
            guard let codes = scannedCodes else { return }

            for code in codes {
                if code.type != AVMetadataObjectTypeEAN13Code {
                    continue
                }

                let value: Int64 = Int64(code.stringValue ?? "0") ?? 0
                let prefix: Int = Int(value / 10000000000)
                if (prefix == 978 || prefix == 979 || prefix == 491) == false {
                    continue
                }

                self?.isbnToRequest.append(value)
            }

            if (self?.isbnToRequest.count)! > 0 {
                self?.pauseScanning()
                SVProgressHUD.show()

                self?.scannedActions(with: (self?.isbnToRequest[0])!) { (_ err: ScannedActionError, _ userInfo: SearchOrder?) in
                    if err == .noErr {
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        return
                    } else if err == .searchBookErr {
                        self?.simpleAlert(nil, message: "エラーです、もう一度お試しください", cancelTitle: "OK") {
                            self?.restartScanning()
                        }
                    } else if err == .searchOrderErr {
                        self?.simpleAlert(nil, message: "エラーです、もう一度お試しください", cancelTitle: "OK") {
                            self?.restartScanning()
                        }
                    } else if err == .searchOrderNotFinishErr {
                        self?.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self!, selector: #selector(self!.repeatReqestOrder(_:)), userInfo: userInfo, repeats: true)
                        RunLoop.current.add(self!.timer!, forMode: .defaultRunLoopMode)
                        self?.timer?.fire()
                        return
                    }
                }
            }
        }

        MTBBarcodeScanner.requestCameraPermission { [weak self] (isSucsess) -> Void in
            if isSucsess {
                self?.scanner.resultBlock = self?.myResultBlock
                do {
                    try self?.scanner.startScanning()
                } catch {
                    self?.simpleAlert(nil, message: "エラーです、もう一度お試しください", cancelTitle: "OK", completion: nil)
                }
            } else {
                self?.loadingView?.disappear(nil)
                DBLog("バーコード読み取りエラー")
            }
        }
    }
    
    static var retryCount: Int = 0
    static var isRetry: Bool = false
    func repeatReqestOrder(_ timer: Timer?) {
        if let order = timer?.userInfo as? SearchOrder {
            Book.getSearchOrderStatusFromId(order, completion: {[weak self] (order, error) in
                DispatchQueue.main.async {
                    if order?.isFinish == true {
                        self?.loadingView?.stopAnimation()
                        self?.loadingView?.disappear(nil)
                        self?.view.isUserInteractionEnabled = true
                        BarcodeScannerViewController.retryCount = 0
                        BarcodeScannerViewController.isRetry = false
                        timer?.invalidate()
                        Book.searchBook(order?.keyword, type: .isbn, page: 1, completion: {[weak self] (books, error) in
                            DispatchQueue.main.async {
                                if error != nil {
                                    self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK") {
                                        self?.restartScanning()
                                    }
                                    return
                                }
                                
                                if books == nil {
                                    self?.simpleAlert(nil, message: "このISBNに対応した本の情報が取得できませんでした", cancelTitle: "OK") {
                                        self?.restartScanning()
                                    }
                                    return
                                }
                                
                                SVProgressHUD.dismiss()

                                self?.displayView?.book = books?[0]
                                self?.displayView?.appearOnViewController(self!)
                            }
                        })
                    } else {
                        BarcodeScannerViewController.retryCount += 1
                        BarcodeScannerViewController.isRetry = true
                        if BarcodeScannerViewController.retryCount > 5 {
                            timer?.invalidate()
                            
                            Book.searchBook(order?.keyword, type: .isbn, page: 1, completion: {[weak self] (books, error) in
                                DispatchQueue.main.async {
                                    self?.loadingView?.stopAnimation()
                                    self?.loadingView?.disappear(nil)
                                    self?.view.isUserInteractionEnabled = true
                                    BarcodeScannerViewController.isRetry = false
                                    BarcodeScannerViewController.retryCount = 0
                                    if error != nil {
                                        self?.simpleAlert(nil, message: error?.errorDespription, cancelTitle: "OK") {
                                            self?.restartScanning()
                                        }
                                        return
                                    }
                                    
                                    if books == nil {
                                        self?.simpleAlert(nil, message: "このISBNに対応した本の情報が取得できませんでした", cancelTitle: "OK") {
                                            self?.restartScanning()
                                        }
                                        return
                                    }

                                    SVProgressHUD.dismiss()

                                    self?.displayView?.book = books?[0]
                                    self?.displayView?.appearOnViewController(self!)
                                }
                            })
                        }
                    }
                }
            })
        }
    }
    
    open func displayViewExhibitButtonTapped(_ displayview: BarcodeScannerBookDisplayView) {
        displayview.disappear(nil)

        let controller: ExhibitTableViewController = ExhibitTableViewController.init(book: displayview.book)
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    open func displayViewRetryButtonTapped(_ displayview: BarcodeScannerBookDisplayView) {
        self.restartScanning()
    }

    open func displayViewCancelButtonTapped(_ displayview: BarcodeScannerBookDisplayView) {
        self.restartScanning()
    }

    func searchFromTitleButtonTapped(_ sender: UIButton) {
        let controller: SearchBookFromTitleViewController = SearchBookFromTitleViewController()
        controller.view.clipsToBounds = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
