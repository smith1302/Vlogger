//
//  VideoProgressView.swift
//  vlogger
//
//  Created by Eric Smith on 1/5/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation

class VideoProgressView: UIView {
    
    static let height:CGFloat = 10
    let divisionWidth:CGFloat = 2

    var segmentViews:[VideoProgressSegmentView] = [VideoProgressSegmentView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.2, alpha: 0.7)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getItemDurationPercentageFromTotal(itemDurations:[Float64], totalDuration:Float64, index:Int) -> CGFloat {
        return CGFloat(itemDurations[index]/totalDuration)
    }
    
    func setSegmentsWithDurationPercents(itemDurations:[Float64], totalDuration:Float64) {
        let numberOfSegments = CGFloat(itemDurations.count)
        let totalDivisionWidth = divisionWidth*(numberOfSegments-1)
        let totalSegmentWidth = (frame.size.width-totalDivisionWidth)
        
        var segmentView:VideoProgressSegmentView!
        var xPlacement:CGFloat = 0
        for i in 0..<itemDurations.count {
            let percent = getItemDurationPercentageFromTotal(itemDurations, totalDuration: totalDuration, index: i)
            let segmentWidth = totalSegmentWidth*percent
            segmentView = VideoProgressSegmentView(frame: CGRectMake(xPlacement,0,segmentWidth,frame.size.height))
            addSubview(segmentView)
            segmentViews.append(segmentView)
            xPlacement += segmentWidth+divisionWidth
        }
    }
    
    func setFillPercent(percent:CGFloat, ofIndex index:Int) {
        if index >= segmentViews.count {
            return
        }
        let view = segmentViews[index]
        view.setFillPercent(percent)
    }
    
    override func didMoveToSuperview() {
        if superview == nil {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: VideoProgressView.height))
        superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: superview!, attribute: .Left, multiplier: 1.0, constant: 0))
        superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: superview!, attribute: .Right, multiplier: 1.0, constant: 0))
        superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: superview!, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }

}
