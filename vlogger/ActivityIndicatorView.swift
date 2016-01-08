//
//  Loader.swift
//  Chats
//
//  Created by Eric Smith on 2/8/15.
//  Copyright (c) 2015 Acani Inc. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIView {
    
    var label: UILabel!
    var view: UIView!
    var loadingIndictator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        stopAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has! not been implemented")
    }
    
    func isAnimating() -> Bool {
        return !self.hidden
    }
    
    func stopAnimating() {
        self.hidden = true
    }
    
    func startAnimating() {
        self.hidden = false
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        backgroundColor = UIColor.clearColor()
        
        view = UIView()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.85)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        loadingIndictator = UIActivityIndicatorView()
        loadingIndictator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndictator.hidden = false
        loadingIndictator.startAnimating()
        view.addSubview(loadingIndictator)
        
        label = UILabel()
        label.text = "Loading"
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        let labelWidth = label.frame.size.width
        let labelHeight = label.frame.size.height
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        addConstraint(NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 15))
        addConstraint(NSLayoutConstraint(item: label, attribute: .Right, relatedBy: .Equal, toItem: loadingIndictator, attribute: .Left, multiplier: 1.0, constant: -15))
        addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 10))
        addConstraint(NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -10))
        addConstraint(NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: labelHeight))
        addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: labelWidth))
        
        addConstraint(NSLayoutConstraint(item: loadingIndictator, attribute: .CenterY, relatedBy: .Equal, toItem: label, attribute: .CenterY, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: loadingIndictator, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: -15))
        addConstraint(NSLayoutConstraint(item: loadingIndictator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20))
        addConstraint(NSLayoutConstraint(item: loadingIndictator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20))
        
        addConstraint(NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: view.frame.size.height/2))
        
    }
    
}

class insetLabel: UILabel {
    
    let insetH:CGFloat = 10
    let insetS:CGFloat = 10 + 5
    
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets(top: insetH, left: insetS, bottom: insetH, right: insetS)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size = CGSizeMake(size.width + insetS*2, size.height + insetH*2)
        return size
    }
    
}