//
//  UploadFailedVideoView.swift
//  vlogger
//
//  Created by Eric Smith on 1/8/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class UploadFailedVideoView: UIView {
    
    let header:UILabel
    let subheader:UILabel
    let activityIndicator:ActivityIndicatorView

    override init(frame: CGRect) {
        
        activityIndicator = ActivityIndicatorView(frame: frame)
        
        header = UILabel()
        header.text = "Video failed to upload"
        header.textColor = UIColor(white: 1, alpha: 0.95)
        header.textAlignment = .Center
        header.font = UIFont.boldSystemFontOfSize(22)
        header.sizeToFit()
        
        subheader = UILabel()
        subheader.text = "Tap to retry"
        subheader.textColor = UIColor(white: 1, alpha: 0.8)
        subheader.textAlignment = .Center
        subheader.font = UIFont.systemFontOfSize(18)
        header.sizeToFit()
        
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        
        addSubview(activityIndicator)
        addSubview(header)
        addSubview(subheader)
        
        header.translatesAutoresizingMaskIntoConstraints = false
        subheader.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: header, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: header, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: subheader, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: subheader, attribute: .Top, relatedBy: .Equal, toItem: header, attribute: .Bottom, multiplier: 1.0, constant: 5))
        
        Utilities.autolayoutSubviewToViewEdges(activityIndicator, view: self)
        
        showFailedMessage()
    }
    
    func showLoader() {
        header.hidden = true
        subheader.hidden = true
        activityIndicator.startAnimating()
    }
    
    func showFailedMessage() {
        header.hidden = false
        subheader.hidden = false
        activityIndicator.stopAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
