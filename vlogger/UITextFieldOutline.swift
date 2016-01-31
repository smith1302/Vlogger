//
//  UITextFieldOutline.swift
//  vlogger
//
//  Created by Eric Smith on 1/30/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class UITextFieldOutline: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        addOutline()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addOutline()
    }
    
    func addOutline() {
        let blurSize:CGFloat = 3
        let blurColor = UIColor(white: 0.2, alpha: 0.8)
        
        if let text = text {
            let attributedText = NSMutableAttributedString(string: text, attributes: [
                NSFontAttributeName : font!,
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSStrokeColorAttributeName: UIColor(white: 0.1, alpha: 1),
                NSStrokeWidthAttributeName: -1
                ])
            textAlignment = .Left
            self.attributedText = attributedText
            
            layer.shadowColor = blurColor.CGColor
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowRadius = blurSize/3
            layer.shadowOpacity = 0.8
        }
    }

}
