//
//  ChatFeedViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/6/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI
import Firebase

protocol ChatFeedViewControllerDelegate:class {
    func toolBarHeightUpdated(_:CGFloat)
    func willSegueToDifferentUserFeed()
    func segueToDifferentUserFeedFailed()
}

class ChatFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ChatTableViewCellDelegate {
    
    weak var delegate:ChatFeedViewControllerDelegate?
    var firebaseRef:Firebase!
    var user:User!
    var messages:[Message] = [Message]()
    let kMaxCharacters:Int = 150
    // We want to pull messages from firebase we sent before this time, but after we ignore because we have it locally
    var feedStartedTime = NSDate()

    @IBOutlet weak var tableView: UITableView!
    // Input bar
    @IBOutlet weak var inputBar: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputBarBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled=true
        
        // Textfield
        textField.delegate = self
        textField.addTarget(self, action: "textFieldDidEdit", forControlEvents: UIControlEvents.EditingChanged)
        // Tableview
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.allowsSelection = false
        // Send Button
        sendButton.addTarget(self, action: "sendButtonClicked", forControlEvents: .TouchUpInside)
        sendButton.setTitleColor(Constants.darkPrimaryColor, forState: .Normal)
        sendButton.setTitleColor(UIColor(hex: 0xAAAAAA), forState: .Disabled)
        sendButton.enabled = false
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "swipeDownOnInputBox:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.toolBarHeightUpdated(inputBar.frame.size.height)
        feedStartedTime = NSDate()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        firebaseRef.removeAllObservers()
    }
    
    func configure(user:User) {
        self.user = user
        firebaseRef = Firebase(url: "https://vlogger.firebaseio.com/channel/\(user.objectId!)/messages")
        listenForNewMessages()
    }
    
    /* Firebase
    -------------------------------------------*/
    
    func listenForNewMessages() {
        firebaseRef.queryLimitedToFirst(30).observeEventType(.ChildAdded, withBlock: { snapshot in
            let message = Message.extractMessageFromSnapshot(snapshot, firebaseRef: self.firebaseRef)
            // If we sent it and it was after feed started time (during current session) don't append it
            if !(message.userID == User.currentUser()!.objectId && !message.isOlderThanDate(self.feedStartedTime)) {
                self.appendMessage(message)
            }
        })
    }
    
    /* Table View Datasource
    -------------------------------------------*/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as? ChatTableViewCell {
            if indexPath.row < self.messages.count {
                cell.configure(messages[indexPath.row])
                cell.delegate = self
            }
            return cell
        }
        return ChatTableViewCell()
    }

    /* Table View Delegate & Helpers
    -------------------------------------------*/
    
    func appendMessage(message:Message) {
        self.messages.append(message)
        let lastRow = self.tableView.numberOfRowsInSection(0)
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([
            NSIndexPath(forRow: lastRow, inSection: 0)
            ], withRowAnimation: .Automatic)
        tableView.endUpdates()
        tableView.scrollToBottom(true)
        
    }
    
    /* Cell Delegate
    -------------------------------------------*/
    
    func clickedOnUser(userID: String) {
        if userID == user.objectId { return }
        // Get user object and go to feed
        let query = User.query()
        query?.whereKey("objectId", equalTo: userID)
        query?.getFirstObjectInBackgroundWithBlock({
            (object:PFObject?, error:NSError?) in
            if let user = object as? User {
                self.goToUserFeed(user)
            } else {
                ErrorHandler.showAlert("Could not find user")
            }
        })
    }
    
    /* TextField Delegate & Helpers
    -------------------------------------------*/
    
    func textFieldDidEdit() {
        if textField.text == nil || textField.text!.isEmpty {
            sendButton.enabled = false
        } else {
            sendButton.enabled = true
        }
        checkMaxLength()
    }
    
    func checkMaxLength() {
        if textField.text == nil { return }
        if (textField.text!.characters.count > kMaxCharacters) {
            textField.deleteBackward()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendButtonClicked()
        return false
    }
    
    /* Actions
    -------------------------------------------*/
    
    func swipeDownOnInputBox(gesture: UIGestureRecognizer) {
        self.textField.resignFirstResponder()
    }
    
    func sendButtonClicked() {
        self.textField.resignFirstResponder()
        if textField.text == nil || textField.text!.isEmpty {
            return
        }
        
        let message = Message(userID: User.currentUser()!.objectId!, userName: User.currentUser()!.username!, text: textField.text!, timestamp: NSDate(), firebaseRef: firebaseRef)
        message.send()
        self.textField.text = ""
        self.appendMessage(message)
    }
    
    func goToUserFeed(user:User) {
        let storyboard = self.storyboard
        if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController {
            self.navigationController?.pushViewController(destinationVC, animated: true)
            destinationVC.configureWithUser(user)
        }
    }
}
