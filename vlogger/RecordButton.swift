//
//  RecordButton.swift
//  vlogger
//
//  Created by Eric Smith on 1/4/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

protocol RecordButtonDelegate {
    func recordFinished()
    func recordStarted()
}

class RecordButton: UIButton {
    
    var isRecording:Bool = false
    var radius:CGFloat!
    var innerCircle:UIView!
    var circleLayer:CAShapeLayer!
    var delegate:RecordButtonDelegate?
    let recordLength:Double = 10
    
    let pressColor = UIColor(white: 0.6, alpha: 0.4)
    let normalColor = UIColor(white: 1, alpha: 0.4)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let radius = frame.size.width/2
        self.radius = radius
        
        makeRecordRing()
        makeBorderRing()
        backgroundColor = normalColor
        layer.cornerRadius = frame.size.height/2
        layer.borderWidth = 6
        layer.borderColor = UIColor(white: 0.9, alpha: 0.9).CGColor
    }
    
    func makeRecordRing() {
        let lineWidth:CGFloat = 5
        let startAngle:CGFloat = -CGFloat(M_PI/2)
        let endAngle:CGFloat = -CGFloat(M_PI/2)-0.0001
        let circlePath = UIBezierPath(arcCenter: CGPointMake(frame.size.width/2, frame.size.height/2), radius: self.radius+lineWidth*1.5, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        circleLayer = CAShapeLayer()
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.strokeColor = UIColor.redColor().CGColor
        circleLayer.lineWidth = lineWidth;
        circleLayer.strokeEnd = 0
        circleLayer.path = circlePath.CGPath
        layer.addSublayer(circleLayer)
    }
    
    func makeBorderRing() {
        let lineWidth:CGFloat = 1
        let startAngle:CGFloat = -CGFloat(M_PI/2)
        let endAngle:CGFloat = -CGFloat(M_PI/2)-0.0001
        let circlePath = UIBezierPath(arcCenter: CGPointMake(frame.size.width/2, frame.size.height/2), radius: self.radius+lineWidth, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let circleLayer = CAShapeLayer()
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.strokeColor = UIColor(white: 0.2, alpha: 1).CGColor
        circleLayer.lineWidth = lineWidth;
        circleLayer.strokeEnd = 1
        circleLayer.path = circlePath.CGPath
        layer.addSublayer(circleLayer)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isRecording {
            return
        }
        isRecording = true
        delegate?.recordStarted()
        animateCircle(recordLength)
        backgroundColor = pressColor
        transform = CGAffineTransformMakeScale(1.1, 1.1)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isRecording = false
        circleLayer.removeAnimationForKey("animateCircle")
        resetAppearance()
        delegate?.recordFinished()
    }
    
    func resetAppearance() {
        backgroundColor = normalColor
        circleLayer.strokeEnd = 0.0
        transform = CGAffineTransformMakeScale(1, 1)
    }
    
    func animateCircle(duration: NSTimeInterval) {
        // Completion block
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.delegate?.recordFinished()
            self.resetAppearance()
        })
        
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        // Set the animation duration appropriately
        animation.duration = duration
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = 1
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        circleLayer.strokeEnd = 1.0
        // Do the actual animation
        circleLayer.addAnimation(animation, forKey: "animateCircle")
        CATransaction.commit()
    }

}
