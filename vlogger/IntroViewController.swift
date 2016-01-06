import UIKit
import Parse
import ParseUI

class IntroViewController: LoginViewController {
    
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
    }
    
}
