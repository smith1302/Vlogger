//
//  PermissionsViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/31/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class PermissionsViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var activityIndicator:ActivityIndicatorView!
    
    var currentState = 0 // 0 or 1
    let pushText = "We are about to ask if we can notify you when you get new subscribers."
    let cameraText = "We are going to ask if we can use your camera so you can film cool things."
    
    let pushImageString = "Sent-100.png"
    let cameraImageString = "Camera-100.png"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.primaryColor
        
        activityIndicator = ActivityIndicatorView(frame: view.frame)
        activityIndicator.stopAnimating()
        self.view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.label.transform = CGAffineTransformMakeScale(0.001,0.001)
        self.imageView.transform = CGAffineTransformMakeScale(0.001,0.001)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateView(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func coolClicked(sender: AnyObject) {
        if currentState == 0 {
            PushController.subscribeToPush()
        } else {
            continueToMainApp()
        }
        updateView(currentState+1)
    }
    
    func updateView(state:Int) {
        if state > 1 {
            return
        }
        currentState = state
        UIView.animateWithDuration(0.4, animations: {
                self.label.transform = CGAffineTransformMakeScale(0.001,0.001)
                self.imageView.transform = CGAffineTransformMakeScale(0.001,0.001)
            }, completion: {
                finished in
                
                if self.currentState == 0 {
                    self.label.text = self.pushText
                    self.imageView.image = UIImage(named: self.pushImageString)
                } else {
                    self.label.text = self.cameraText
                    self.imageView.image = UIImage(named: self.cameraImageString)
                }
                Utilities.springAnimation(self.label, completion: nil)
                Utilities.springAnimation(self.imageView, completion: nil)
        })
    }
    
     func continueToMainApp() {
        activityIndicator.startAnimating()
        let storyboard = Constants.storyboard
        let mainAppVC = storyboard.instantiateViewControllerWithIdentifier("MainNavigationViewController")
        self.presentViewController(mainAppVC, animated: true, completion: {
            self.activityIndicator.stopAnimating()
        })
    }

}
