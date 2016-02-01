//
//  AddVideoToStoryView.swift
//  vlogger
//
//  Created by Eric Smith on 1/30/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import Parse

protocol AddVideoToStoryViewDelegate:class {
    func newStoryClicked()
    func addStoryClicked()
}

class AddVideoToStoryView: UIView {
    
    var addButton:UIButton!
    var newButton:UIButton!
    var titleLabel:UILableOutline!
    var line:UIView!
    weak var delegate:AddVideoToStoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let sidePadding:CGFloat = 30
        let betweenPadding:CGFloat = 15
        let buttonHeight:CGFloat = 50
        let buttonWidth:CGFloat = (frame.size.width-sidePadding*2-betweenPadding)/2
        let textSize:CGFloat = 17
        var yPos:CGFloat = frame.size.height - sidePadding - buttonHeight
        addButton = UIButton(type: .Custom)
        addButton.setTitle("Add", forState: .Normal)
        addButton.addTarget(self, action: "addClicked", forControlEvents: .TouchUpInside)
        addButton.titleLabel?.font = UIFont.systemFontOfSize(textSize, weight: 0.4)
        addButton.layer.cornerRadius = 5
        addButton.backgroundColor = Constants.primaryColor
        addButton.frame = CGRectMake(sidePadding, yPos, buttonWidth, buttonHeight)
        
        newButton = UIButton(frame: CGRectMake(sidePadding+buttonWidth+betweenPadding, yPos, buttonWidth, buttonHeight))
        newButton.setTitle("New Story", forState: .Normal)
        newButton.addTarget(self, action: "newClicked", forControlEvents: .TouchUpInside)
        newButton.titleLabel?.font = UIFont.systemFontOfSize(textSize, weight: 0.3)
        newButton.layer.cornerRadius = 5
        newButton.layer.borderColor = UIColor.whiteColor().CGColor
        newButton.layer.borderWidth = 2

        
        yPos -= 20 + 1
        
        line = UIView()
        line.frame = CGRectMake(sidePadding, yPos, buttonWidth*2+betweenPadding, 1)
        line.backgroundColor = UIColor(white: 0.65, alpha: 0.9)
        
        
        titleLabel = UILableOutline(frame: CGRectZero)
        titleLabel.text = "..."
        titleLabel.textColor = UIColor(white: 1, alpha: 0.3)
        titleLabel.font = UIFont.systemFontOfSize(textSize+1)
        titleLabel.sizeToFit()
        yPos -= 8 + titleLabel.frame.size.height
        titleLabel.frame = CGRectMake(sidePadding, yPos, line.frame.size.width, titleLabel.frame.size.height)
        User.currentUser()?.currentStory?.fetchIfNeededInBackgroundWithBlock({
            (object:PFObject?, error:NSError?) in
            if let story = object as? Story {
                self.titleLabel.text = story.getCached().title
                self.titleLabel.textColor = UIColor(white: 1, alpha: 1)
            }
        })
        titleLabel.addOutline()
        
        addSubview(addButton)
        addSubview(newButton)
        addSubview(line)
        addSubview(titleLabel)
    }
    
    func newClicked() {
        delegate?.newStoryClicked()
    }
    
    func addClicked() {
        delegate?.addStoryClicked()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return point.y > 100
    }

}
