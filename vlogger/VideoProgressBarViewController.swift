//
//  VideoProgressBarViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/6/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoProgressBarDelegate {
    func playerIsBuffering(isBuffering:Bool)
    func playerError()
}

class VideoProgressBarViewController: UIViewController, LoopingPlayerDelegate {
    
    var progressBar:VideoProgressView!
    var player:LoopingPlayer!
    var delegate:VideoProgressBarDelegate?
    
    var totalDuration:Float64 = 0
    var itemDurations:[Float64] = [Float64]()
    
    var isBuffering:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Progress Bar View
        let progressBarFrame = CGRectMake(0,view.frame.height-VideoProgressView.height,view.frame.size.width,VideoProgressView.height)
        progressBar = VideoProgressView(frame: progressBarFrame)
        view = progressBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getItemDurationPercentageForSeconds(seconds:Float64, index:Int) -> CGFloat {
        return CGFloat(seconds/itemDurations[index])
    }
    
    func getDurationsForItems(player:LoopingPlayer) -> [Float64] {
        var itemsDuration = [Float64]()
        for item in player.items() {
            itemsDuration.append(getDurationForItem(item))
        }
        return itemsDuration
    }
    
    func getTotalDurationForPlayer(player:LoopingPlayer) -> Float64 {
        var totalDuration:Float64 = 0
        for item in player.items() {
            totalDuration += getDurationForItem(item)
        }
        return totalDuration
    }
    
    func getDurationForItem(item:AVPlayerItem) -> Float64 {
        return CMTimeGetSeconds(item.asset.duration)
    }
    
    func setLoopingPlayer(player:LoopingPlayer) {
        self.player = player
        player.delegate = self
        self.totalDuration = getTotalDurationForPlayer(player)
        self.itemDurations = getDurationsForItems(player)
        progressBar.setSegmentsWithDurationPercents(self.itemDurations, totalDuration: self.totalDuration)
    }
    
    /* Looping Player Delegate
    ------------------------------------------------------------------------------*/
    
    func statusChanged(seconds: Float64) {
        let currentIndex = player!.indexOfCurrentItemInOriginalQueue()
        for index in 0..<player.originalQueue.count {
            if index < currentIndex {
                progressBar?.setFillPercent(1, ofIndex: index)
            } else if index == currentIndex {
                progressBar?.setFillPercent(getItemDurationPercentageForSeconds(seconds, index: index), ofIndex:index)
            } else {
                progressBar?.setFillPercent(0, ofIndex:index)
            }
        }
    }
    
    func playerIsBuffering(var isBuffering: Bool) {
        if self.isBuffering == isBuffering {
            return
        }
        if !isBuffering && player.status == .ReadyToPlay {
            player?.play()
        } else {
            player?.pause()
            isBuffering = true
        }
        self.isBuffering = isBuffering
        self.delegate?.playerIsBuffering(isBuffering)
    }
    
    func playerReady() {
        delegate?.playerIsBuffering(false)
        //player.play()
    }
    
    func playerError() {
        delegate?.playerIsBuffering(true)
        delegate?.playerError()
    }

}
