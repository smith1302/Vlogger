//
//  LoginViewController.swift
//  Chats
//
//  Created by Eric Smith on 1/25/15.
//  Copyright (c) 2015 Acani Inc. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var top: UIView!
    var usernameBox: UITextField!
    var passwordBox: UITextField!
    var passwordBox2: UITextField!
    var thinLine3: UIView!
    var loginTextBtn: UIButton!
    var registerTextBtn: UIButton!
    var loginButton: UIButton?
    var registerButton: UIButton?
    var currentButton: UIButton!
    var arrow:UIButton!
    var currentForm = 1 // 1 = login, 2 = signup
    var requestInProgress = false
    var logoView:UIImageView!
    var activityIndicator:ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.None
        
        self.view.backgroundColor = UIColor(white: 1, alpha: 1)
        
        top = UIView(frame: CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height/2))
        top.backgroundColor = Constants.primaryColor
        self.view.addSubview(top)
        
        let boxH:CGFloat = 55
        let paddingX:CGFloat = 20
        let lineHeight:CGFloat = 0.5
        
        let arrowWidth:CGFloat = 32
        let arrowPadding:CGFloat = 8
        arrow = UIButton(type: UIButtonType.Custom)
        arrow.frame = CGRectMake(self.view.frame.size.width - paddingX - arrowWidth, 0, arrowWidth, arrowWidth)
        let image = UIImage(named: "right-arrow.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        arrow.setImage(image, forState: .Normal)
        arrow.tintColor = UIColor(hex: 0x308BF2)
        arrow.addTarget(self, action: "goPressed", forControlEvents: UIControlEvents.TouchUpInside)
        arrow.hidden = true
        self.view.addSubview(arrow)
        
        let whiteBehindInput = UIView(frame: CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, boxH*2 + lineHeight*2))
        whiteBehindInput.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(whiteBehindInput)
        
        var startingY = self.view.frame.size.height/2
        let blueLineH:CGFloat = 3
        let blueLine = UIView(frame: CGRectMake(0, startingY, self.view.frame.size.width, blueLineH))
        blueLine.backgroundColor = UIColor(hex: 0xAEC5F5)
        self.view.addSubview(blueLine)
        
        startingY += blueLineH
        usernameBox = UITextField(frame: CGRectMake(paddingX, startingY, self.view.frame.size.width - paddingX*2, boxH))
        usernameBox.placeholder = "Username"
        usernameBox.backgroundColor = UIColor.whiteColor()
        usernameBox.returnKeyType = UIReturnKeyType.Go
        usernameBox.delegate = self
        self.view.addSubview(usernameBox)
        
        startingY += boxH
        let lineColor = 0xB8B8B8
        let thinLine = UIView(frame: CGRectMake(paddingX, startingY, self.view.frame.size.width - paddingX*2, lineHeight))
        thinLine.backgroundColor = UIColor(hex: lineColor)
        self.view.addSubview(thinLine)
        
        startingY += lineHeight
        passwordBox = UITextField(frame: CGRectMake(paddingX, startingY, self.view.frame.size.width - paddingX*2 - arrowWidth - arrowPadding, boxH))
        passwordBox.placeholder = "Password"
        passwordBox.secureTextEntry = true
        passwordBox.backgroundColor = UIColor.whiteColor()
        passwordBox.returnKeyType = UIReturnKeyType.Go
        passwordBox.delegate = self
        self.view.addSubview(passwordBox)
        
        startingY += boxH
        let thinLine2 = UIView(frame: CGRectMake(paddingX, startingY, self.view.frame.size.width - paddingX*2, lineHeight))
        thinLine2.backgroundColor = UIColor(hex: lineColor)
        self.view.addSubview(thinLine2)
        
        // Part of registration
        startingY += lineHeight
        passwordBox2 = UITextField(frame: CGRectMake(paddingX, startingY, self.view.frame.size.width - paddingX*2 - arrowWidth - arrowPadding, boxH))
        passwordBox2.placeholder = "Confirm"
        passwordBox2.secureTextEntry = true
        passwordBox2.backgroundColor = UIColor.whiteColor()
        passwordBox2.returnKeyType = UIReturnKeyType.Go
        passwordBox2.delegate = self
        self.view.addSubview(passwordBox2)
        
        startingY += boxH
        thinLine3 = UIView(frame: CGRectMake(paddingX, startingY, self.view.frame.size.width - paddingX*2, lineHeight))
        thinLine3.backgroundColor = UIColor(hex: lineColor)
        self.view.addSubview(thinLine3)
        
        // Buttons to toggle form
        
        let textSize:CGFloat = 20
        loginTextBtn = UIButton(frame: CGRectMake(0, self.view.frame.size.height/2 - boxH, self.view.frame.size.width/2, boxH))
        loginTextBtn.setTitle("Login", forState: .Normal)
        loginTextBtn.titleLabel?.font = UIFont.boldSystemFontOfSize(textSize)
        loginTextBtn.addTarget(self, action: "switchToLogin", forControlEvents: UIControlEvents.TouchUpInside)
        loginTextBtn.backgroundColor = Constants.primaryColorDark
        self.view.addSubview(loginTextBtn)
        
        registerTextBtn = UIButton(frame: CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - boxH, self.view.frame.size.width/2, boxH))
        registerTextBtn.titleLabel?.textColor = UIColor.whiteColor()
        registerTextBtn.alpha = 0.6
        registerTextBtn.setTitle("Sign Up", forState: .Normal)
        registerTextBtn.titleLabel?.font = UIFont.boldSystemFontOfSize(textSize)
        registerTextBtn.addTarget(self, action: "switchToRegister", forControlEvents: UIControlEvents.TouchUpInside)
        registerTextBtn.backgroundColor = Constants.primaryColorDark
        self.view.addSubview(registerTextBtn)
        
        let buttonH:CGFloat = 60
        loginButton = UIButton(frame: CGRectMake(0, self.view.frame.size.height - buttonH, self.view.frame.size.width, buttonH))
        loginButton?.addTarget(self, action: "loginPressed", forControlEvents: UIControlEvents.TouchUpInside)
        loginButton?.backgroundColor = UIColor(hex: 0x3B5998)
        loginButton?.setTitle("Login", forState: .Normal)
        loginButton?.titleLabel?.font = UIFont.boldSystemFontOfSize(19)
        loginButton?.titleLabel?.textColor = UIColor.whiteColor()
        //self.view.addSubview(loginButton!)
        
        registerButton = UIButton(frame: CGRectMake(0, self.view.frame.size.height - buttonH, self.view.frame.size.width, buttonH))
        registerButton?.addTarget(self, action: "registerPressed", forControlEvents: UIControlEvents.TouchUpInside)
        registerButton?.backgroundColor = UIColor(hex: 0x3B5998)
        registerButton?.setTitle("Register", forState: .Normal)
        registerButton?.titleLabel?.font = UIFont.boldSystemFontOfSize(19)
        registerButton?.titleLabel?.textColor = UIColor.whiteColor()
        registerButton?.hidden = true
        //self.view.addSubview(registerButton!)
        
        let headLineH:CGFloat = 18
        let headLinePad:CGFloat = 35
        let headHeight = (self.view.frame.size.height/2 - buttonH)*0.38
        let headWidth:CGFloat = headHeight/220.0 * 216.0
        
        logoView = UIImageView(image: getLogoImage())
        logoView.frame = CGRectMake(self.view.frame.size.width/2 - headWidth/2, (self.view.frame.size.height/2 - buttonH)/2 - headHeight/2 + 20 /*- (headLineH + headLinePad)/2*/, headHeight, headWidth)
        self.view.addSubview(logoView)
        logoView.transform = CGAffineTransformMakeScale(0,0)
        
        let headLinePadX = self.view.frame.size.width * 0.2
        let headLine = UILabel(frame: CGRectMake(headLinePadX, logoView.frame.origin.y + headHeight + headLinePad, self.view.frame.size.width - headLinePadX*2, headLineH*2+10))
        headLine.text = Constants.appName
        headLine.textAlignment = .Center
        headLine.textColor = UIColor(white: 1, alpha: 0.9)
        headLine.font = UIFont.systemFontOfSize(headLineH)
        headLine.numberOfLines = 2
        //self.view.addSubview(headLine)
        
        activityIndicator = ActivityIndicatorView(frame: view.frame)
        activityIndicator.stopAnimating()
        self.view.addSubview(activityIndicator)
        
        currentForm = 1
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        switchToLogin()
        
        usernameBox.text = "smith1302"
        passwordBox.text = "lolly"
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        let currentUser = User.currentUser()
        if currentUser != nil {
            continueToMainApp()
        } else {
            UIView.animateWithDuration(1,
                delay: 0.2,
                usingSpringWithDamping: 0.55,
                initialSpringVelocity: 0.8,
                options: .CurveEaseInOut,
                animations: {
                    self.logoView.transform = CGAffineTransformMakeScale(1, 1)
                },
                completion: nil)
        }
    }
    
    func getLogoImage() -> UIImage? {
        return UIImage(named: "moose-large.png")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let height = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size.height
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
        
        var distanceSpace:CGFloat!
        if currentForm == 1 {
            let distanceFromTop = passwordBox.frame.origin.y + passwordBox.frame.size.height
            distanceSpace = self.view.frame.size.height - distanceFromTop
        } else {
            let distanceFromTop = passwordBox2.frame.origin.y + passwordBox2.frame.size.height
            distanceSpace = self.view.frame.size.height - distanceFromTop
        }
        
        var adjustedHeight = height - distanceSpace
        adjustedHeight = (adjustedHeight < 0) ? 0 : adjustedHeight
        
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
            self.view.frame.origin.y = -1*adjustedHeight
            }, completion: nil)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
        
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
            self.view.frame.origin.y = 0
            }, completion: nil)
    }
    
    func switchToRegister() {
        if passwordBox2.text!.isEmpty {
            arrow.hidden = true
        } else {
            arrow.frame.origin.y = passwordBox2.frame.origin.y + (passwordBox2.frame.size.height - arrow.frame.size.height)/2
            arrow.hidden = false
            self.view.bringSubviewToFront(arrow)
        }
        showLoginOnlyForm(false)
    }
    
    func switchToLogin() {
        if passwordBox.text!.isEmpty {
            arrow.hidden = true
        } else {
            arrow.frame.origin.y = passwordBox.frame.origin.y + (passwordBox.frame.size.height - arrow.frame.size.height)/2
            arrow.hidden = false
            self.view.bringSubviewToFront(arrow)
        }
        showLoginOnlyForm(true)
    }
    
    func showLoginOnlyForm(showLogin:Bool) {
        thinLine3.hidden = showLogin
        passwordBox2.hidden = showLogin
        
        currentForm = (showLogin) ? 1 : 2
        loginTextBtn.alpha = (showLogin) ? 1 : 0.6
        registerTextBtn.alpha = (showLogin) ? 0.6 : 1
        
        usernameBox.becomeFirstResponder()
        
        //incase we switched
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var maxCharacters:Int!
        if textField == usernameBox {
            maxCharacters = 50
        } else {
            maxCharacters = 25
        }
        let newLength = (textField.text!).characters.count + string.characters.count - range.length
        let res = newLength <= maxCharacters //Bool
        
        if res {
            if currentForm == 1 && textField == passwordBox {
                if string.isEmpty && textField.text!.isEmpty {
                    arrow.hidden = true
                } else {
                    arrow.frame.origin.y = passwordBox.frame.origin.y + (passwordBox.frame.size.height - arrow.frame.size.height)/2
                    self.view.bringSubviewToFront(arrow)
                    arrow.hidden = false
                }
            } else if currentForm == 2 && textField == passwordBox2 { // Show arrow when we edit the last required form
                if string.isEmpty && textField.text!.isEmpty {
                    arrow.hidden = true
                } else {
                    arrow.frame.origin.y = passwordBox2.frame.origin.y + (passwordBox2.frame.size.height - arrow.frame.size.height)/2
                    self.view.bringSubviewToFront(arrow)
                    arrow.hidden = false
                }
            }
        }
        return res
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        goPressed()
        textField.resignFirstResponder()
        return true
    }
    
    func goPressed() {
        if currentForm == 1 {
            loginPressed()
        } else {
            registerPressed()
        }
    }
    
    func isValidRegisterForm() -> Bool {
        if passwordBox.text != passwordBox2.text {
            MessageHandler.easyAlert("Try again", message: "Your passwords do not match.")
            return false
        } else if usernameBox.text!.isEmpty {
            MessageHandler.easyAlert("Try again", message: "Please enter a username.")
            return false
        } else if passwordBox.text!.isEmpty {
            MessageHandler.easyAlert("Try again", message: "Please choose a password.")
            return false
        } else if passwordBox2.text!.isEmpty {
            MessageHandler.easyAlert("Try again", message: "Please retype your password.")
            return false
        } else if usernameBox.text!.hasWhitespace() || passwordBox.text!.hasWhitespace() {
            MessageHandler.easyAlert("Try again", message: "Input should not contain spaces.")
            return false
        }
        //        else if !isValidEmail(usernameBox.text!) {
        //            MessageHandler.easyAlert("Try again", message: "Please type a valid email address.")
        //            return false
        //        }
        return true
    }
    
    func isValidLoginForm() -> Bool {
        if usernameBox.text!.isEmpty {
            MessageHandler.easyAlert("Try again", message: "Username is missing.")
            return false
        } else if passwordBox.text!.isEmpty {
            MessageHandler.easyAlert("Try again", message: "Password is missing.")
            return false
        }
        //        else if !isValidEmail(usernameBox.text!) {
        //            MessageHandler.easyAlert("Try again", message: "Please type a valid email address.")
        //            return false
        //        }
        return true
    }
    
    //    func isValidEmail(email:String) -> Bool {
    //        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    //        if let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx) as NSPredicate? {
    //            return emailTest.evaluateWithObject(email)
    //        }
    //        return false
    //    }
    
    func registerPressed() {
        if !isValidRegisterForm() || activityIndicator.isAnimating() {
            return
        }
        
        activityIndicator.startAnimating()
        
        let newUser = User(username: usernameBox.text!.stripWhitespace(), password: passwordBox.text!.stripWhitespace(), usernameLowercase: usernameBox.text!.stripWhitespace().lowercaseString)
        
        // Sign up the user asynchronously
        newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
            // Stop the spinner
            self.activityIndicator.stopAnimating()
            if let error = error {
                let errorString = error.userInfo["error"] as? String
                ErrorHandler.showAlert(errorString)
                // Show the errorString somewhere and let the user try again.
            } else {
                // Hooray! Let them use the app now.
                self.continueToMainApp()
            }
        })
    }
    
    func loginPressed() {
        if !isValidLoginForm() || activityIndicator.isAnimating() {
            return
        }
        
        activityIndicator.startAnimating()
        
        PFUser.logInWithUsernameInBackground(usernameBox.text!.stripWhitespace(), password:passwordBox.text!.stripWhitespace()) {
            (user: PFUser?, error: NSError?) -> Void in
            self.activityIndicator.stopAnimating()
            if user != nil {
                // Do stuff after successful login.
                self.continueToMainApp()
            } else if error?.code == 101 {
                MessageHandler.easyAlert("Invalid", message: "Incorrect username and password")
            } else {
                ErrorHandler.showAlert(error?.debugDescription)
            }
        }
        
    }
    
    func continueAfterRegister() {
        self.continueToMainApp()
    }
    
    func continueAfterLogin() {
        self.continueToMainApp()
    }
    
    func continueToMainApp() {
        fatalError("Must Override")
    }
    
}
