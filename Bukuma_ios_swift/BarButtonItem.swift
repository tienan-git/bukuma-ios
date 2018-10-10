//
//  BKMBarButtonItem.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

//  ButtonItem　クラス。基本的にこれを使う

private let BarButtonItemButtonBoldFontSize = UIFont.boldSystemFont(ofSize: 16)
private let BarButtonItemStartButtonBoldFontSize = UIFont.boldSystemFont(ofSize: 15)
private let BarButtonItemButtonNormalFontSize = UIFont.systemFont(ofSize: 16)
private let BarButtonItemMargin: CGFloat = 10
private let BarButtonItemStartButtonHeight: CGFloat = 30

private class BarButtonItemButton : UIButton{
     override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        self.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: UIControlState.disabled)
        
    }

     required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
}

open class BarButtonItem: UIBarButtonItem {
    
    open class func barButtonItemWithText(_ text:String, isBold:Bool, isLeft:Bool, target:AnyObject, action:Selector) ->BarButtonItem {
        let font = isBold ? BarButtonItemButtonBoldFontSize : BarButtonItemButtonNormalFontSize
        let button: BarButtonItemButton = BarButtonItemButton.init(frame: CGRect.zero)
        
        
        button.frame = CGRect(x: 0, y: 0, width: text.getTextWidthWithFont(font, viewHeight: 20) + 20, height: kCommonNavigationBarHeight)
        button.titleLabel!.font = font
        button.setTitle(text, for: UIControlState.normal)
        button.titleLabel!.textAlignment = isLeft ? NSTextAlignment.left : NSTextAlignment.right
        button.isExclusiveTouch = true
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 25 * (isLeft ? -1 : 0), 0, 25 * (isLeft ? 0 : -1))
        button.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        
        return  BarButtonItem.init(customView: button)
    }
    
    open class func barButtonItemWithText(_ text:String, s_text:String, isBold:Bool, isLeft:Bool, target:AnyObject, action:Selector) ->BarButtonItem {
        let font = isBold ? BarButtonItemButtonBoldFontSize : BarButtonItemButtonNormalFontSize
        let button: BarButtonItemButton = BarButtonItemButton.init(frame: CGRect.zero)
        
        button.frame = CGRect(x: 0, y: 0, width: text.getTextWidthWithFont(font, viewHeight: 20) + 20, height: kCommonNavigationBarHeight)
        button.titleLabel!.font = font
        button.setTitle(text, for: UIControlState.normal)
        button.setTitle(s_text, for: UIControlState.selected)

        button.titleLabel!.textAlignment = isLeft ? NSTextAlignment.left : NSTextAlignment.right
        button.isExclusiveTouch = true
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 25 * (isLeft ? -1 : 0), 0, 25 * (isLeft ? 0 : -1))
        button.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        
        return  BarButtonItem.init(customView: button)
    }
    
    open class func barButtonItemWithImage(_ image:UIImage, isLeft:Bool, target:AnyObject, action:Selector) ->BarButtonItem {
        let button: BarButtonItemButton = BarButtonItemButton.init(frame: CGRect.zero)
        button.frame = CGRect(x: 0, y: 0, width: image.size.width + 20 , height: image.size.height + 20)
        button.setImage(image, for: UIControlState.normal)
        button.isExclusiveTouch = true
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 44 * (isLeft ? -1 : 0), 0, 44 * (isLeft ? 0 : -1))
        button.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        
        return  BarButtonItem.init(customView: button)
    }
    
    open class func backButton(_ image:UIImage, target:AnyObject, action:Selector) ->BarButtonItem {
        let button: BarButtonItemButton = BarButtonItemButton.init(frame: CGRect.zero)
        button.frame = CGRect(x: 0, y: 0, width: image.size.width + 20 , height: image.size.height + 20)
        button.setImage(image, for: UIControlState.normal)
        button.isExclusiveTouch = true
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 34 * -1, 0, 44 * 0 )
        button.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        
        return  BarButtonItem.init(customView: button)

    }
    
}
