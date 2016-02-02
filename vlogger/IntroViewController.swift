import UIKit
import Parse
import ParseUI

class IntroViewController: LoginViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        User.logOut()
        User.enableRevocableSessionInBackground()
    }
    
    override func getLogoImage() -> UIImage? {
        return UIImage(named: "Eye.png")
    }
    
    /*
    * User is signed up or logged in. Lets take them to the main app
    */
    override func continueToMainApp() {
        activityIndicator.startAnimating()
        let storyboard = Constants.storyboard
        let mainAppVC = storyboard.instantiateViewControllerWithIdentifier("MainNavigationViewController")
        self.presentViewController(mainAppVC, animated: true, completion: {
            self.activityIndicator.stopAnimating()
        })
        PushController.subscribeToPush()
    }
    
    override func continueToSetup() {
        activityIndicator.startAnimating()
        let storyboard = Constants.storyboard
        let setupVC = storyboard.instantiateViewControllerWithIdentifier("PermissionsViewController")
        self.presentViewController(setupVC, animated: true, completion: {
            self.activityIndicator.stopAnimating()
        })
    }
    
    override func continueToTerms() {
        let storyboard = Constants.storyboard
        let termsVC = storyboard.instantiateViewControllerWithIdentifier("TermsViewController")
        self.navigationController?.pushViewController(termsVC, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as UIViewController
        toViewController.transitioningDelegate = self.navigationController!.delegate as! NavigationControllerDelegate
    }
    
}
