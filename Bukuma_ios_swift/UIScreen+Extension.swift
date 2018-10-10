//
//  UIScreen+Extension.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit

public extension UIScreen {
    
    public class func is3_5inchDisplay() ->Bool{
        return UIScreen.main.bounds.size.height == 480
    }
    
    public class func is4inchDisplay() ->Bool{
        return UIScreen.main.bounds.size.height == 568
    }
    
    public class func is4_7inchDisplay() ->Bool{
        return UIScreen.main.bounds.size.height == 667
    }
    
    public class func is5_5inchDisplay() ->Bool{
        return UIScreen.main.bounds.size.height == 736
    }
    
    public class func isOver4inchDisplay() ->Bool{
        return UIScreen.main.bounds.size.height >= 568
    }
    
    public class func isOver4_7inchDisplay() ->Bool{
        return UIScreen.main.bounds.size.height >= 667
    }
    
}

