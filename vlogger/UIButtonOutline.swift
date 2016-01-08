//
//  UIButtonOutline.swift
//  vlogger
//
//  Created by Eric Smith on 1/6/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class UIButtonOutline: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Configure post image controls
        if let text = titleLabel?.text {
            let attributedText = NSMutableAttributedString(string: text, attributes: [
                NSFontAttributeName : titleLabel!.font,
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSStrokeColorAttributeName: UIColor(white: 0.2, alpha: 1),
                NSStrokeWidthAttributeName: -2
                ])
            titleLabel?.textAlignment = .Left
            titleLabel?.attributedText = attributedText
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
