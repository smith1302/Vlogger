//
//  Utilities.swift
//  vlogger
//
//  Created by Eric Smith on 1/8/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    class func autolayoutSubviewToViewEdges(subview:UIView, view:UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
}