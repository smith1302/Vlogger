//
//  TermsViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/31/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var text = "1) By accessing and using \(Constants.appName) you agree to be bound by these Terms of Use.\n\n2) Objectionable material is not tolerated and may be taken down at any time if it is deemed too offensive.\n\n3) User accounts may also be banned at any time, for any reason. This is especially true if the user has been reported by fellow users or if they are hurting the nature of the \(Constants.appName) community.\n\n4) You alone are responsible for your interaction with other users. \(Constants.appName) does not represent and is not responsible for the actions or words of the users using the service."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = text
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        title = "Terms of Use"
        self.navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
