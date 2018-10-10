//
//  PagerHeaderView.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2017/01/17.
//  Copyright © 2017年 Hiroshi Chiba. All rights reserved.
//

public protocol PagerHeaderViewDelegate {
    func pagerHeaderView(didSelectHeaderMenu tab: Tab)
}

private let selectedViewHeight: CGFloat = 2.0
private let scrollViewTag = 1000
private let loopScrollingMargin: CGFloat = 10

open class PagerHeaderView: UIView {
    
    fileprivate var delegate: PagerHeaderViewDelegate?
    
    fileprivate var tabs: [Tab] = []
    fileprivate var buttons: [HeaderButton] = []
    fileprivate var scrollView: UIScrollView!
    fileprivate var separatror: UIView!
    
    var isLoopScrolling = false
    
    // ================================================================================
    // MARK:-
    
    class func headerMenuHeight() ->CGFloat {
        return HeaderButton.headerMenuHeight()
    }
    
    required public init(delegate: PagerHeaderViewDelegate, tabs: [Tab]) {
        super.init(frame: CGRect(x: 0, y: 0, width: kCommonDeviceWidth, height: PagerHeaderView.headerMenuHeight()))
        self.backgroundColor = UIColor.white
        
        self.delegate = delegate
        
        scrollView = UIScrollView(frame: self.bounds)
        scrollView.bounces = false
        scrollView.isPagingEnabled = false
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isUserInteractionEnabled = true
        scrollView.tag = scrollViewTag
        scrollView.delegate = self
        self.addSubview(scrollView)
        
        var contentWidth: CGFloat = 0
        self.tabs = tabs
        
        for (i, tab) in tabs.enumerated() {
            let button = HeaderButton.generateButton(withTab: tab)
            button.x = contentWidth
            button.addTarget(self, action: #selector(self.buttonTapped(sender:)), for: .touchUpInside)
            if i == 0 {
                button.isSelected = true
            }
            scrollView.addSubview(button)
            buttons.append(button)
            
            contentWidth += button.width
        }
        
        scrollView.contentSize = CGSize(width: contentWidth, height: PagerHeaderView.headerMenuHeight())
        isLoopScrolling = scrollView.width + loopScrollingMargin * 2 + HeaderButton.headerMenuWidth() < contentWidth
        
        separatror = UIView(frame: CGRect(x: 0, y: HeaderButton.headerMenuHeight() - 2.0, width: HeaderButton.headerMenuWidth(), height: 2.0))
        separatror.backgroundColor = kMainGreenColor
        scrollView.addSubview(separatror)
        
        if let first = tabs.first {
            moveSeparatror(selectTab: first, animated: false)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonTapped(sender: UIButton) {
        guard let button = sender as? HeaderButton,
              let tab = button.tab else {
            return
        }
        self.tapButton(withTab: tab)
    }
    
    private func tapButton(withTab tab: Tab) {
        self.move(selectTab: tab)
        self.delegate?.pagerHeaderView(didSelectHeaderMenu: tab)
    }
    
    func move(selectTab tab: Tab) {
        DispatchQueue.main.async {
            if self.buttons.allUnselected() {
                self.buttons.setSelected(withTab: self.tabs[0])
                return
            }
            self.buttons.setSelected(withTab: tab)
            self.moveSeparatror(selectTab: tab)
        }
    }
    
    func moveSeparatror(selectTab tab: Tab, animated: Bool = true) {
        var target: HeaderButton?
        for button in buttons {
            if button.tab == tab {
                target = button
            }
        }
        
        guard let button = target else { return }
        
        let moveX = button.x
        let width = button.width
        
        let contentOffsetX: CGFloat = {
            if isLoopScrolling {
                let sizeSpace = (kCommonDeviceWidth - width) / 2
                return button.x - sizeSpace
            } else {
                if self.tabs.count == 1 {
                    return 0
                }
                let index = self.tabs.index(of: tab) ?? 0
                return ((self.scrollView.contentSizeWidth - kCommonDeviceWidth) / CGFloat(self.tabs.count - 1)) * CGFloat(index)
            }
        }()
        
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.separatror.x = moveX
                self.separatror.width = width
            }
            scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: true)
        } else {
            separatror.x = width
            scrollView.contentOffsetX = contentOffsetX
        }
    }
}

extension PagerHeaderView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isLoopScrolling {
            return
        }
        
        let contentWidth = scrollView.contentSize.width
        let offsetX = scrollView.contentOffset.x
        if contentWidth - kCommonDeviceWidth - offsetX <= loopScrollingMargin {
            scrollWithDirection(0)
        } else if offsetX <= loopScrollingMargin {
            scrollWithDirection(1)
        }
    }
    
    private func scrollWithDirection(_ direction: Int) {
        var buttonSize: CGFloat = 0
        
        if direction == 0 {
            let firstView = buttons.removeFirst()
            buttonSize = firstView.width
            buttons.append(firstView)
        } else {
            let lastView = buttons.removeLast()
            buttonSize = lastView.width
            buttons.insert(lastView, at: 0)
        }
        
        var contentSizeWidth: CGFloat = 0
        
        for button in buttons {
            button.x = contentSizeWidth
            contentSizeWidth += button.width
            
            if button.isSelected {
                separatror.x = button.x
            }
        }
        
        if direction == 0 {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - buttonSize, y: 0)
        } else {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x + buttonSize, y: 0)
        }
    }
}

class HeaderButton: UIButton {
    
    var tab: Tab?
    
    fileprivate class func headerMenuHeight() ->CGFloat {
        return 38.0
    }
    
    fileprivate class func headerMenuWidth() ->CGFloat {
        if UIScreen.is5_5inchDisplay() {
            return 125
        }
        return 100
    }
    
    fileprivate class func generateButton(withTab tab: Tab) ->HeaderButton {
        let button: HeaderButton = HeaderButton(frame: CGRect(x: 0, y: 0, width: HeaderButton.headerMenuWidth(), height: HeaderButton.headerMenuHeight()))
        button.tab = tab
        button.isExclusiveTouch = true
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.setTitleColor(kGray01Color, for: .normal)
        button.setTitleColor(kMainGreenColor, for: .selected)
        button.backgroundColor = UIColor.clear
        let padding: CGFloat = 10.0
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        button.setTitle(tab.name, for: .normal)
        let size = button.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: HeaderButton.headerMenuHeight()))
        button.width = max(size.width + 2 * padding, HeaderButton.headerMenuWidth())
        
        return button
    }
}

fileprivate extension Array where Element: HeaderButton {
    fileprivate func allUnselected() ->Bool {
        var unselected = true
        for i in self.enumerated() {
            if i.element.isSelected == true {
                unselected = false
            }
        }
        return unselected
    }
    
    fileprivate func setSelected(withTab tab: Tab) {
        for i in self.enumerated() {
            i.element.isSelected = false
            if i.element.tab ==  tab {
                i.element.isSelected = true
            }
        }
    }
}
