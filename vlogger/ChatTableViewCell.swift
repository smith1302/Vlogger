//
//  ChatTableViewCell.swift
//  vlogger
//
//  Created by Eric Smith on 1/11/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

protocol ChatTableViewCellDelegate:class {
    func clickedOnUser(userID:String)
}

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var usernameLabel: UIButton!
    weak var delegate:ChatTableViewCellDelegate?
    
    var message:Message!
    
    func configure(message:Message) {
        self.message = message
        usernameLabel.setTitle("\(message.userName):", forState: .Normal)
        usernameLabel.setTitleColor(Constants.darkPrimaryColor, forState: .Normal)
        textView.text = message.text
        timeLabel.text = message.timestamp.getReadableTime()

        textView.textContainerInset = UIEdgeInsetsZero;
    }
    
    
    @IBAction func usernameClicked(sender: AnyObject) {
        delegate?.clickedOnUser(message.userID)
    }

}
