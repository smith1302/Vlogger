//
//  SelectorViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/13/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

protocol SelectorViewControllerDelegate: class {
    func leftButtonClicked()
    func rightButtonClicked()
}

enum HomeSelectorState {
    case Search
    case Home
}

class SelectorViewController: UIViewController {
    
    weak var selectedButton: UIButton? = UIButton()
    weak var RightButton: UIButton!
    weak var LeftButton: UIButton!
    weak var container: UIView!
    weak var selectorCenterXConstraint: NSLayoutConstraint!
    var selectedColor:UIColor = UIColor.whiteColor() //UIColor(hex: 0x3697FF)
    var nonSelectedColor:UIColor = UIColor(white: 1, alpha: 0.55)
    weak var delegate:SelectorViewControllerDelegate?
    var currentState:HomeSelectorState! = HomeSelectorState.Home {
        didSet {
            self.refreshLabels(self.currentState)
            if oldValue != self.currentState {
                selectedButton = UIButton()
                leftButtonClicked()
            }
        }
    }
    var stateLabels:[HomeSelectorState:[String:String]] = [HomeSelectorState.Search:["Left":"Users", "Right":"Stories"], HomeSelectorState.Home:["Left":"Trending", "Right":"Subscriptions"]]
    
    init(RightButton:UIButton, LeftButton:UIButton, selectorCenterXConstraint: NSLayoutConstraint, container:UIView, selector:UIView) {
        self.RightButton = RightButton
        self.LeftButton = LeftButton
        self.selectorCenterXConstraint = selectorCenterXConstraint
        self.container = container
        // Colors
        container.backgroundColor = Constants.primaryColor
        selector.backgroundColor = UIColor(white: 0.98, alpha: 1)
        super.init(nibName: nil, bundle: nil)
        self.RightButton.addTarget(self, action: "rightButtonClicked", forControlEvents: .TouchUpInside)
        self.LeftButton.addTarget(self, action: "leftButtonClicked", forControlEvents: .TouchUpInside)
        self.refreshLabels(currentState)
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
    
    func refreshLabels(state:HomeSelectorState) {
        if let labels = stateLabels[state] {
            LeftButton.setTitle(labels["Left"], forState: .Normal)
            RightButton.setTitle(labels["Right"], forState: .Normal)
        }
    }
    
    func rightButtonClicked() {
        if selectedButton == RightButton { return }
        changeSelectedButton(RightButton, notSelected: LeftButton)
        delegate?.rightButtonClicked()
    }
    
    func leftButtonClicked() {
        if selectedButton == LeftButton { return }
        changeSelectedButton(LeftButton, notSelected: RightButton)
        delegate?.leftButtonClicked()
    }
    
    func changeSelectedButton(selected:UIButton, notSelected:UIButton) {
        selectorCenterXConstraint.constant = selected.frame.origin.x
        notSelected.setTitleColor(nonSelectedColor, forState: .Normal)
        selected.setTitleColor(selectedColor, forState: .Normal)
        animateSelector()
        selectedButton = selected
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
