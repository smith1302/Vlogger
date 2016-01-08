//
//  AVPlayerItemCustom.swift
//  vlogger
//
//  Created by Eric Smith on 1/7/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import Foundation
import AVFoundation

class AVPlayerItemCustom : AVPlayerItem {
    var playableDuration: CMTime {
        get {
            if let item: AnyObject = self.loadedTimeRanges.first {
                if let timeRange = item.CMTimeRangeValue {
                    let playableDuration = CMTimeAdd(timeRange.start, timeRange.duration)
                    return playableDuration
                }
            }
            return kCMTimeZero
        }
    }
    
    var loadingProgress: Float {
        get {
            let playableDurationInSeconds = CMTimeGetSeconds(self.playableDuration)
            let totalDurationInSeconds = CMTimeGetSeconds(self.duration)
            if (totalDurationInSeconds.isNormal) {
                var progress = Float(playableDurationInSeconds / totalDurationInSeconds)
                if (progress > 0.90) {
                    // Fully loaded
                }
                return progress
            }
            return 0
        }
    }
}