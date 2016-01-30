//
//  StorySelectionPopUpView.swift
//  vlogger
//
//  Created by Eric Smith on 1/24/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class StorySelectionPopUpView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 8
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
