//
//  BaseWebViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/04/13.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import SVProgressHUD

open class BaseWebViewController: BaseViewController {
    
    var webView: UIWebView?
    var url: URL?
    var toolBar: UIToolbar?
    var actionButton: UIBarButtonItem?
    var backButton: UIBarButtonItem?
    var fwdButton: UIBarButtonItem?

    fileprivate var progressWithDelay: ProgressWithDelay?
    fileprivate let progressDelayTime = 1.0

    deinit {
        url = nil
        DBLog("----------------- BaseWebViewController  Deinit -------------------")
    }
    
    required public init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        
        self.url = url
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white

        webView = UIWebView(frame: self.view.bounds)
        webView?.y = NavigationHeightCalculator.navigationHeight()
        webView?.delegate = self
        webView?.backgroundColor = UIColor.white
        webView?.scalesPageToFit = true
        self.view.insertSubview(webView!, belowSubview: navigationBarView!)

        toolBar = UIToolbar(frame: CGRect(x: 0,
            y: self.view.frame.size.height - 44.0,
            width: self.view.frame.size.width,
            height: 44.0))
        let space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let reload: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_web_reload"), style: .plain, target: self, action: #selector(self.pageReload))
        
        backButton = UIBarButtonItem(image: UIImage(named: "ic_web_back"), style: .plain, target: self, action: #selector(self.pageBack))
        
        fwdButton = UIBarButtonItem(image: UIImage(named: "ic_web_forward"), style: .plain, target: self, action: #selector(self.pageForward))
        
        toolBar?.items = [backButton!, flexSpace,flexSpace, space, reload]
        toolBar?.isHidden = true
        self.view.addSubview(toolBar!)

        self.progressWithDelay = ProgressWithDelay()

        if let url = self.url {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            self.webView?.loadRequest(request)
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.progressWithDelay?.installProgress(withDelay: self.progressDelayTime)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if webView?.isLoading == true {
            webView?.stopLoading()
        }

        self.progressWithDelay?.removeProgress()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    func pageReload() {
        webView?.reload()
    }
    
    func pageBack() {
        webView?.goBack()
        toolBar?.isHidden = true
        if webView?.canGoBack == true {
            toolBar?.isHidden = false
        }
    }
    
    func pageForward() {
        webView?.goForward()
    }
    
    func showActivity() {
        
    }
    
    fileprivate func hookMoveInApp(_ url: URL?) -> Bool {
        guard let url = url, let host = url.host else {
            return false
        }
        if url.scheme != "jp.com.labit.bukuma" { return false }
        
        switch host {
        case "books":
            if let bookId = url.pathComponents[safe: 1], let _ = Int(bookId) {
                moveDetailPage(bookId: bookId)
            }
            break
        case "timeline":
            let fragments = url.fragments
            if let paramUrl = fragments["url"] {
                var color: UIColor?
                if let paramColor = fragments["color"] {
                    color = UIColor.colorWithHexString(paramColor)
                }
                moveMerchandiseCollectionPage(url: paramUrl,
                                              title: fragments["title"],
                                              color: color)
            }
        default: break
        }
        
        return true
    }
    
    private func moveDetailPage(bookId: String) {
        SVProgressHUD.show()
        view.isUserInteractionEnabled = false
        
        Book.getBookInfoFromID(bookId) { [weak self] (book, error) in
            if book != nil {
                DetailPageTableViewController.generate(for: book) { (generatedViewController: DetailPageTableViewController?) in
                    guard let viewController = generatedViewController else {
                        SVProgressHUD.dismiss()
                        self?.view.isUserInteractionEnabled = true
                        return
                    }
                    self?.navigationController?.pushViewController(viewController, animated: true)

                    SVProgressHUD.dismiss()
                    self?.view.isUserInteractionEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self?.view.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    private func moveMerchandiseCollectionPage(url: String, title: String?, color: UIColor?) {
        let controller = MerchandiseCollectionViewController(url: url, title: title, color: color)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension BaseWebViewController: UIWebViewDelegate {
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        DBLog(request)

        if hookMoveInApp(request.url) {
            return false
        }

        return true
    }
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        let cache = URLCache.shared
        cache.removeAllCachedResponses()

        toolBar?.isHidden = true
        if webView.canGoBack == true {
            toolBar?.isHidden = false
            toolBar?.items?.removeObject(fwdButton!)

            if webView.canGoForward == true {
                toolBar?.isHidden = false
                toolBar?.items?.insert(fwdButton!, at: 2)
            }
        }
    }

    public func webViewDidFinishLoad(_ webView: UIWebView) {
        self.progressWithDelay?.removeProgress()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        toolBar?.isHidden = true
        if webView.canGoBack == true {
            toolBar?.isHidden = false
        }
    }

    @nonobjc public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.progressWithDelay?.removeProgress()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
