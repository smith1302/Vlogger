//
//  SelectorViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/13/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

protocol SelectorViewControllerDelegate: class {
    func subscriptionClicked()
    func trendingClicked()
}

class SelectorViewController: UIViewController {
    
    weak var selectedButton: UIButton!
    weak var trendingButton: UIButton!
    weak var subscriptionsButton: UIButton!
    weak var container: UIView!
    weak var selectorCenterXConstraint: NSLayoutConstraint!
    var selectedColor:UIColor = UIColor(hex: 0x3697FF)
    var nonSelectedColor:UIColor = UIColor.grayColor()
    weak var delegate:SelectorViewControllerDelegate?
    
    init(trendingButton:UIButton, subscriptionsButton:UIButton, selectorCenterXConstraint: NSLayoutConstraint, container:UIView) {
        self.trendingButton = trendingButton
        self.subscriptionsButton = subscriptionsButton
        self.selectorCenterXConstraint = selectorCenterXConstraint
        self.container = container
        super.init(nibName: nil, bundle: nil)
        self.trendingButton.addTarget(self, action: "trendingButtonClicked", forControlEvents: .TouchUpInside)
        self.subscriptionsButton.addTarget(self, action: "subscriptionButtonClicked", forControlEvents: .TouchUpInside)
        selectedButton = subscriptionsButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func trendingButtonClicked() {
        if selectedButton == trendingButton { return }
        selectorCenterXConstraint.constant = trendingButton.frame.origin.x
        trendingButton.setTitleColor(selectedColor, forState: .Normal)
        subscriptionsButton.setTitleColor(nonSelectedColor, forState: .Normal)
        animateSelector()
        selectedButton = trendingButton
        delegate?.trendingClicked()
    }
    
    func subscriptionButtonClicked() {
        if selectedButton == subscriptionsButton { return }
        selectorCenterXConstraint.constant = subscriptionsButton.frame.origin.x
        trendingButton.setTitleColor(nonSelectedColor, forState: .Normal)
        subscriptionsButton.setTitleColor(selectedColor, forState: .Normal)
        animateSelector()
        selectedButton = subscriptionsButton
        delegate?.subscriptionClicked()
    }
    
    func animateSelector() {
        UIView.animateWithDuration(0.3, animations: {
            self.container.layoutIfNeeded()
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
