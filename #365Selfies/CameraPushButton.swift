//
//  CameraPushButton.swift
//  #365Selfies
//
//  Created by Ankita Prasad on 11/26/15.
//  Copyright © 2015 Ankita Prasad. All rights reserved.
//

import UIKit

class CameraPushButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    */
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        UIColor(red: 179/255, green: 187/255, blue: 92/255, alpha: 1).setFill()
        // UIColor.yellowColor().setFill()
        path.fill()
        
        let newRect = CGRectMake(rect.minX + 5, rect.minY + 5, rect.width - 10, rect.height - 10)
        let path1 = UIBezierPath(ovalInRect: newRect)
        UIColor.purpleColor().setFill()
        path1.fill()
        
    }
}
