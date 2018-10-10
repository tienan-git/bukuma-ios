//
//  NKJPagerViewController.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/11.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

let NKJPagerViewControllerTabViewTag: Int = 1800
let NKJPagerViewControllerContentViewTag: Int = 2400

let kTabsViewBackgroundColor = UIColor.colorWithDecimal(234.0 / 255.0, green: 234.0 / 255.0, blue: 234.0 / 255.0, alpha: 0.75)
let kContentViewBackgroundColor = UIColor.colorWithDecimal(248.0 / 255.0, green: 248.0 / 255.0, blue: 248.0 / 255.0, alpha: 0.75)

public protocol NKJPagerViewControllerDataSource {
    func numberOfTabView() ->Int
    func widthOfTabViewWithIndex(_ index: Int) ->CGFloat
    func viewForTabAtIndex(_ viewPager: NKJPagerViewController, tabIndex: Int) ->UIView
    func contentViewControllerForTabAtIndex(_ viewPager: NKJPagerViewController, index: Int) ->UIViewController
}

@objc public protocol NKJPagerViewControllerDelegate : NSObjectProtocol{
    @objc optional func viewPagerDidTapMenuTabAtIndex(_ viewPager: NKJPagerViewController, index: Int)
    @objc optional func viewPagerWillTransition(_ viewPager: NKJPagerViewController)
    @objc optional func viewPagerWillSwitchAtIndex(_ viewPager: NKJPagerViewController, index: Int, tabs: Array<AnyObject>)
    @objc optional func viewPagerdidSwitchAtIndex(_ viewPager: NKJPagerViewController, index: Int, tabs: Array<AnyObject>)
    @objc optional func viewPagerDidAddContentView()
}

open class NKJPagerViewController: BaseViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate
{
    // ================================================================================
    // MARK: - private property
    //private defaultValue
     fileprivate var leftTabIndex: Int? = 0
     fileprivate var tabCount: Int = 0
     fileprivate var pageViewController: UIPageViewController?
    
    // ================================================================================
    // MARK: - public property
    open var heightOfTabView: CGFloat = 44
    open var yPositionOfTabView: CGFloat = NavigationHeightCalculator.navigationHeight() + 40.0

    open var tabsViewBackgroundColor: UIColor?
    open var infiniteSwipe: Bool?
    open var activeContentIndex: Int? = 0
    
    open var tabs: Array<UIView>? //views
    open var contents: Array<UIViewController>? // ViewControllers
    open var tabsView: UIScrollView?
    open var contentView: UIView?

    open weak var delegate: NKJPagerViewControllerDelegate?
    open var dataSource: NKJPagerViewControllerDataSource?

    // ================================================================================
    // MARK: - public setting Medhod
    
    // ================================================================================
    // MARK: -init
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
       // self.defaultSettings()
    }
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ================================================================================
    // MARK: - default setting
    
    func defaultSettings() {
        
        pageViewController =  UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll,
                                                   navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal,
                                                   options: nil)
        self.pageViewController?.dataSource = self
        self.pageViewController?.delegate = self
        self.addChildViewController(pageViewController!)
        pageViewController?.didMove(toParentViewController: self)
        
        let scrollView: UIScrollView = pageViewController!.view.subviews[0] as!UIScrollView
        scrollView.delegate = self
        
        self.heightOfTabView = 44
        self.yPositionOfTabView = NavigationHeightCalculator.navigationHeight() + 40.0
        self.tabsViewBackgroundColor = kTabsViewBackgroundColor
        self.infiniteSwipe = false
                
    }
    
    func defaultSetUp() {
        // Empty tabs and contents
        if self.tabsView != nil {
            for tabView: UIView? in self.tabs! {
                tabView?.removeFromSuperview()
            }
            self.tabsView!.contentSize = CGSize.zero
            
            self.tabs?.removeAll()
            self.contents?.removeAll()
        }
        
        // Initializes
        self.tabCount = dataSource?.numberOfTabView() ?? 0
        self.leftTabIndex = 0
        self.tabs = []
        self.contents = []
        
        // Add tabsView in Superview
        if self.tabsView == nil {
            self.tabsView =  UIScrollView.init(frame: CGRect(x: 0, y: self.yPositionOfTabView, width: kCommonDeviceWidth, height: self.heightOfTabView))
            self.tabsView!.isUserInteractionEnabled = true
            self.tabsView!.autoresizingMask = UIViewAutoresizing.flexibleWidth
            self.tabsView!.backgroundColor = self.tabsViewBackgroundColor
            self.tabsView!.scrollsToTop = false
            
            self.tabsView!.showsHorizontalScrollIndicator = false
            self.tabsView!.showsVerticalScrollIndicator = false
            self.tabsView!.tag = NKJPagerViewControllerTabViewTag
            self.tabsView!.delegate = self
            self.tabsView!.backgroundColor = UIColor.clear
            self.view.insertSubview(self.tabsView!, at: 0)
            
            if infiniteSwipe == true {
                
                self.tabsView!.bounces = false
                self.tabsView!.isScrollEnabled = true
                
            } else {
                
                self.tabsView!.bounces = true
                self.tabsView!.isScrollEnabled = true
            }
        }
        
        var contentSizeWidth: CGFloat = 0
        
        for i in 0 ..< self.tabCount {
            if self.tabs!.count >= self.tabCount {
                continue
            }
            
            let tabView: UIView = self.dataSource!.viewForTabAtIndex(self, tabIndex: i)
            tabView.tag = i
            var frame: CGRect = tabView.frame
            frame.origin.x = contentSizeWidth
            frame.size.width = self.dataSource!.widthOfTabViewWithIndex(i)
            tabView.frame = frame
            tabView.isUserInteractionEnabled = true
            
            self.tabsView?.addSubview(tabView)
            self.tabs?.append(tabView)
            
            contentSizeWidth += tabView.frame.width
            
            // To capture tap events
            
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(NKJPagerViewController.handleTapGesture(_:)))
            tabView.addGestureRecognizer(tapGestureRecognizer)
            
            // view controller
            self.contents?.append(self.dataSource!.contentViewControllerForTabAtIndex(self, index: i))
        }
         self.tabsView!.contentSize = CGSize(width: contentSizeWidth, height: self.heightOfTabView)
        
        // Positioning
        
        if infiniteSwipe == true {
            let contentOffsetWidth: CGFloat = self.dataSource!.widthOfTabViewWithIndex(0)
                + self.dataSource!.widthOfTabViewWithIndex(1)
                + self.dataSource!.widthOfTabViewWithIndex(2)
                - (UIScreen.main.bounds.size.width - self.dataSource!.widthOfTabViewWithIndex(0)) / 2
            
            self.tabsView!.contentOffset = CGPoint(x: contentOffsetWidth, y: 0)
        }
        
        // Add contentView in Superview
        self.contentView = self.view.viewWithTag(NKJPagerViewControllerContentViewTag)
        
        if self.contentView == nil {
            // Populate pageViewController.view in contentView
            self.contentView = self.pageViewController!.view
            
            self.contentView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.contentView!.backgroundColor = kContentViewBackgroundColor
            self.contentView!.backgroundColor = UIColor.clear
            self.contentView!.bounds = self.view.bounds
        
            self.contentView!.tag = NKJPagerViewControllerContentViewTag
            self.view.insertSubview(self.contentView!, at: 0)
            
            // constraints
            
            if self.delegate!.responds(to: #selector(NKJPagerViewControllerDelegate.viewPagerDidAddContentView)) {
                self.delegate!.viewPagerDidAddContentView?()
            }
        }
        
        // Setting Active 
        
        if self.infiniteSwipe == true {
            if tabCount <= 26 {
                self.selectTabAtIndex(0)
                let defaultTabView : UIView = self.tabViewAtIndex(0)
                self.transitionTabViewWithView(defaultTabView)
            } else {
                self.selectTabAtIndex(29)
                let defaultTabView : UIView = self.tabViewAtIndex(29)
                self.transitionTabViewWithView(defaultTabView)
            }
        }else {
             self.selectTabAtIndex(0)
        }
        
        // Default Design
        if self.delegate!.responds(to: #selector(NKJPagerViewControllerDelegate.viewPagerdidSwitchAtIndex(_:index:tabs:))) {
            self.delegate!.viewPagerdidSwitchAtIndex!(self, index: self.activeContentIndex!, tabs: self.tabs!)
        }
        
        let borderView: UIView = UIView(frame: CGRect(x: 0, y: tabs![0].height - 0.5, width: kCommonDeviceWidth * 24, height: 0.5))
        tabsView!.addSubview(borderView)
        borderView.backgroundColor = kBlackColor12
    }
    
    // ================================================================================
    // MARK: - Life Cycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.defaultSettings()
        self.defaultSetUp()
    }

    // ================================================================================
    // MARK: - Gesture
    
    func handleTapGesture(_ sender: UITapGestureRecognizer) {
        if self.delegate!.responds(to: #selector(NKJPagerViewControllerDelegate.viewPagerDidTapMenuTabAtIndex(_:index:))) {
            self.delegate!.viewPagerDidTapMenuTabAtIndex!(self, index: sender.view!.tag)
        }

        guard let view = sender.view else {
            return
        }
        self.transitionTabViewWithView(view)
        self.selectTabAtIndex(view.tag)
    }
    
    func transitionTabViewWithView(_ view: UIView) {
        let buttonSize: CGFloat = self.dataSource!.widthOfTabViewWithIndex(view.tag)
        
        let sizeSpace: CGFloat = (kCommonDeviceWidth - buttonSize) / 2

        if infiniteSwipe == true {
            self.tabsView!.setContentOffset(CGPoint(x: view.frame.origin.x - sizeSpace, y: 0), animated: true)
            
        } else {
            let rightEnd: CGFloat = self.tabsView!.contentSize.width - UIScreen.main.bounds.size.width
            
            if view.frame.origin.x <= sizeSpace {
                self.tabsView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            } else if view.frame.origin.x >= rightEnd + sizeSpace {
                self.tabsView?.setContentOffset(CGPoint(x: rightEnd, y: 0), animated: true)

            } else {
                self.tabsView?.setContentOffset(CGPoint(x: view.frame.origin.x - sizeSpace, y: 0), animated: true)
            }
        }
    }
    
    func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            let activeTabView : UIView = self.tabViewAtIndex(4)
            self.transitionTabViewWithView(activeTabView)
            self.selectTabAtIndex(activeTabView.tag)
        } else if sender.direction == .right {
            let activeTabView : UIView = self.tabViewAtIndex(2)
            self.transitionTabViewWithView(activeTabView)
            self.scrollWithDirection(1)
        }
    }
    
    // ================================================================================
    // MARK: - UIPageViewControllerDataSource
    
     open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
         var index: Int = self.indexForViewController(viewController)
        
         index += 1
        
        if index == self.contents!.count {
            index = 0
        }
        return self.viewControllerAtIndex(index)
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index: Int = self.indexForViewController(viewController)
        
        if index == 0 {
            index = self.contents!.count - 1
        } else {
            index -= 1
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    // ================================================================================
    // MARK: - UIPageViewControllerDelegate
    
    open func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if self.delegate!.responds(to: #selector(NKJPagerViewControllerDelegate.viewPagerWillTransition(_:))) {
            self.delegate!.viewPagerWillTransition!(self)
        }
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let viewController: UIViewController = self.pageViewController!.viewControllers![0]
        let index: Int = self.indexForViewController(viewController)
        
        self.activeContentIndex = index
        
        for view in (self.tabsView?.subviews)! {
            if view.tag == index {
                self.transitionTabViewWithView(view)
                break
            }
        }
        
        if completed == true {
            if self.delegate!.responds(to: #selector(NKJPagerViewControllerDelegate.viewPagerWillSwitchAtIndex(_:index:tabs:))) {
                self.delegate!.viewPagerWillSwitchAtIndex!(self, index: index, tabs: self.tabs!)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute:  {
            self.pageAnimationDidFinish()
        })
    }
    
    // ================================================================================
    // MARK: - UIScrollViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if infiniteSwipe == true {
            
            // To scroll
            if scrollView.tag == NKJPagerViewControllerTabViewTag {
                let buttonSize: CGFloat! = self.dataSource!.widthOfTabViewWithIndex(self.activeContentIndex!)
                let position: CGFloat! = self.tabsView!.contentOffset.x / buttonSize
                let delta: CGFloat! =  position - CGFloat(self.leftTabIndex!)
                
                if fabs(delta) >= 1.0 {
                    if delta > 0 {
                        self.scrollWithDirection(0)
                    } else {
                        self.scrollWithDirection(1)
                    }
                }
            }
        }
    }
    
    // ================================================================================
    // MARK: - public Meshod
    fileprivate var pagerDirection: UIPageViewControllerNavigationDirection = UIPageViewControllerNavigationDirection(rawValue: 0)!
    
    open func setActiveContentIndex(_ activeContentIndex: Int) {
        let viewController: UIViewController = self.viewControllerAtIndex(activeContentIndex)
        
        weak var weakSelf = self
        
        if activeContentIndex == self.activeContentIndex {
            if self.delegate!.responds(to: #selector(NKJPagerViewControllerDelegate.viewPagerWillSwitchAtIndex(_:index:tabs:))) {
                self.delegate!.viewPagerWillSwitchAtIndex!(self, index: activeContentIndex, tabs: self.tabs!)
            }
            
            self.pageViewController?.setViewControllers([viewController], direction: .forward, animated: false, completion: { (completed) -> Void in
                weakSelf?.activeContentIndex = activeContentIndex
                weakSelf?.pageAnimationDidFinish()
            })
        } else {
            
            if activeContentIndex == self.contents!.count - 1 && self.activeContentIndex == 0 {
                
                if infiniteSwipe == true {
                    pagerDirection = .reverse
                } else {
                    pagerDirection = .forward
                }
            } else if activeContentIndex == 0 && self.activeContentIndex == self.contents!.count - 1 {
                if infiniteSwipe == true {
                    pagerDirection = .forward
                } else {
                    pagerDirection = .reverse
                }
            } else if activeContentIndex < self.activeContentIndex! {
                pagerDirection = .reverse
            } else {
                pagerDirection = .forward
            }
            
            if self.delegate!.responds(to: #selector(NKJPagerViewControllerDelegate.viewPagerWillSwitchAtIndex(_:index:tabs:))) {
                self.delegate!.viewPagerWillSwitchAtIndex!(self, index: activeContentIndex, tabs: self.tabs!)
            }
            
            self.pageViewController?.setViewControllers([viewController], direction: pagerDirection, animated: true, completion: { (completed) -> Void in
                weakSelf?.activeContentIndex = activeContentIndex
                weakSelf?.pageAnimationDidFinish()
            })
        }
    }
    
    open func switchViewControllerWithIndex(_ index: Int) {
        let view: UIView = self.tabs![index]
        self.transitionTabViewWithView(view)
        self.selectTabAtIndex(index)
    }
    
    // ================================================================================
    // MARK: - private Meshod
    
    func pageAnimationDidFinish() {
        if self.delegate!.responds(to: #selector(NKJPagerViewControllerDelegate.viewPagerdidSwitchAtIndex(_:index:tabs:))) {
            self.delegate!.viewPagerdidSwitchAtIndex!(self, index: self.activeContentIndex!, tabs: self.tabs!)
        }
    }
    
    func selectTabAtIndex(_ index: Int) {
        if index >= self.tabCount {
            return
        }
        self.setActiveContentIndex(index)
    }
    
    func tabViewAtIndex(_ index: Int) ->UIView{
        if index >= self.tabCount {
            return UIView()
        }
        return self.tabs![index]
    }
    
     open  func viewControllerAtIndex(_ index: Int) ->UIViewController {
        if index >= self.tabCount {
            return UIViewController()
        }
        
        return self.contents![index]
    }
    
    func indexForViewController(_ viewController: UIViewController) ->Int {
        return self.contents?.indexOfObject(viewController) ?? 0
    }
    
    func scrollWithDirection(_ direction: Int) {
        let buttonSize: CGFloat = self.dataSource!.widthOfTabViewWithIndex(self.activeContentIndex!)
        
        if direction == 0 {
            let firstView: UIView = self.tabs!.first!
            self.tabs?.remove(at: 0)
            self.tabs?.append(firstView)
        } else {
            let lastView: UIView = self.tabs!.last!
            self.tabs?.removeLast()
            self.tabs?.insert(lastView, at: 0)
        }
        
        var index: Int = 0
        var contentSizeWidth: CGFloat = 0
        
        for pageView in self.tabs! {
            var frame: CGRect = pageView.frame
            frame.origin.x = contentSizeWidth
            frame.size.width = buttonSize
            pageView.frame = frame
            contentSizeWidth += buttonSize
            index += 1
        }
        
        if direction == 0 {
            self.tabsView!.contentOffset = CGPoint(x: self.tabsView!.contentOffset.x - buttonSize, y: 0)
        } else {
            self.tabsView!.contentOffset =  CGPoint(x: self.tabsView!.contentOffset.x + buttonSize, y: 0)
        }
    }
}
