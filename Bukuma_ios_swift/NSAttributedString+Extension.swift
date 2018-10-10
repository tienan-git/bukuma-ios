//
//  NSAttributedString+Extension.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/07.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit

public extension NSAttributedString {
    
    public func getTextHeight(_ viewWidth:CGFloat) ->CGFloat{
        let paragraphRect: CGRect = self.boundingRect(with: CGSize(width: viewWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin,.usesFontLeading],
            context: nil)
        
        return ceil(paragraphRect.size.height)
    }
    
    public func getTextWidth(_ viewHeight:CGFloat) ->CGFloat{
        let paragraphRect: CGRect = self.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: viewHeight),
            options: [.usesLineFragmentOrigin,.usesFontLeading],
            context: nil)
        
        return ceil(paragraphRect.size.width)
    }
    
}
