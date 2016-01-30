//
//  FullMessageView.swift
//  vlogger
//
//  Created by Eric Smith on 1/25/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class FullMessageView: UIView {
    
    let label = UILabel()
    
    init(frame: CGRect, text:String) {
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        label.textColor = UIColor(white: 0.6, alpha: 1)
        label.font = UIFont.boldSystemFontOfSize(21)
        label.text = text
        label.numberOfLines = 2
        label.textAlignment = .Center
        addSubview(label)
        Utilities.autolayoutSubviewToViewEdges(label, view: self, edgeInsets: UIEdgeInsets(top: 0, left: 40, bottom: -60, right: -40))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        Utilities.springAnimation(label, completion: nil)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
