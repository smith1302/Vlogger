//
//  FeedViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/5/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Parse

class FeedViewController: UIViewController {
    
    @IBOutlet weak var chatDragCenterYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func chatDrag(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
        let newY = sender.view!.center.y + translation.y
        if newY < sender.view!.frame.size.height/2 + 70 || newY > self.view.frame.size.height-sender.view!.frame.size.height - 60 {
            return
        }
        chatDragCenterYConstraint.constant = newY - view.frame.size.height/2
        sender.setTranslation(CGPointZero, inView: self.view)
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
    }
}
