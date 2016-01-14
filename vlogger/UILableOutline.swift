//
//  UILableOutline.swift
//  vlogger
//
//  Created by Eric Smith on 1/11/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class UILableOutline: UILabel {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Configure post image controls
        if let text = text {
            let attributedText = NSMutableAttributedString(string: text, attributes: [
                NSFontAttributeName : font,
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSStrokeColorAttributeName: UIColor(white: 0.2, alpha: 1),
                NSStrokeWidthAttributeName: -2
                ])
            textAlignment = .Left
            self.attributedText = attributedText
        }
    }

}
