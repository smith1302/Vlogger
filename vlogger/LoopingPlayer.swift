
import AVFoundation

protocol LoopingPlayerDelegate {
    func statusChanged(_: Float64)
    func playerIsBuffering(isBuffering:Bool)
    func playerReady()
    func playerError()
}

class LoopingPlayer: AVQueuePlayer {
    
    var loopCount: Double = 0
    var timeObserver: AnyObject?
    var delegate:LoopingPlayerDelegate?
    var originalQueue:[AVPlayerItem:Int] = [AVPlayerItem:Int]()
    var unloadedURLs:Int!
    override internal var currentItem: AVPlayerItemCustom? { get { return super.currentItem as? AVPlayerItemCustom } }
    
    var playableDuration: CMTime {
        get {
            if let item: AnyObject = self.currentItem?.loadedTimeRanges.first {
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
            if (self.currentItem == nil) {
                return 0
            }
            let playableDurationInSeconds = CMTimeGetSeconds(self.playableDuration)
            let totalDurationInSeconds = CMTimeGetSeconds(self.currentItem!.duration)
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
    
    override init() {
        super.init()
        self.commonInit()
    }
    
    override init(URL url: NSURL) {
        super.init(URL: url)
        self.commonInit()
    }
    
    /* Async load urls and play when finished */
    init(loadURLs urls:[NSURL]) {
        super.init()
        self.unloadedURLs = urls.count
        self.commonInit()
        for url in urls {
            let asset = AVURLAsset(URL: url)
            let keys = ["playable"]
            asset.loadValuesAsynchronouslyForKeys(keys, completionHandler: {
                dispatch_async(dispatch_get_main_queue(), {
                    let playerItem = AVPlayerItem(asset: asset)
                    self.insertItem(playerItem, afterItem: nil)
                    self.unloadedURLs = self.unloadedURLs-1
                    if self.unloadedURLs <= 0 {
                        
                    }
                })
            })
        }
    }
    
    override private init(playerItem item: AVPlayerItem) {
        super.init(playerItem: item)
    }
    
    override private init(items: [AVPlayerItem]) {
        super.init(items: items)
    }
    
    init(customItems: [AVPlayerItemCustom]) {
        super.init(items: customItems)
        self.commonInit()
    }
    
    init(item: AVPlayerItemCustom) {
        super.init(playerItem: item)
        self.commonInit()
    }
    
    let kPlayerStatusNew = "status"
    let kCurrentItemStatusNew = "currentItem.status"
    let kCurrentItemLoadedTimeRangesNew = "currentItem.loadedTimeRanges"
    let kCurrentItemPlaybackBufferEmptyNew = "currentItem.playbackBufferEmpty"
    let kCurrentItemPlaybackBufferGoodNew = "currentItem.playbackLikelyToKeepUp"
    let kCurrentItemErrorNew = "currentItem.error"
    
    func commonInit() {
        for (index,item) in items().enumerate() {
            originalQueue[item] = index
        }
        addObserver(self, forKeyPath: kPlayerStatusNew, options: .New, context: nil)
        addObserver(self, forKeyPath: kCurrentItemStatusNew, options: .New, context: nil)
        addObserver(self, forKeyPath: kCurrentItemLoadedTimeRangesNew, options: .New, context: nil)
        addObserver(self, forKeyPath: kCurrentItemPlaybackBufferEmptyNew, options: .New, context: nil)
        addObserver(self, forKeyPath: kCurrentItemPlaybackBufferGoodNew, options: .New, context: nil)
        addObserver(self, forKeyPath: kCurrentItemErrorNew, options: .New, context: nil)
        self.actionAtItemEnd = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"playerDidPlayToEndTimeNotification:", name:AVPlayerItemDidPlayToEndTimeNotification, object:nil)
    
        self.timeObserver = self.addPeriodicTimeObserverForInterval(CMTimeMake(1, 100), queue: dispatch_get_main_queue(), usingBlock: {
            (time: CMTime) -> Void in
            let seconds:Float64 = CMTimeGetSeconds(time)
            if (!isnan(seconds) && !isinf(seconds)) {
                self.delegate?.statusChanged(seconds)
            }
        })
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if timeObserver != nil {
            removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
        removeObserver(self, forKeyPath: kPlayerStatusNew, context: nil)
        removeObserver(self, forKeyPath: kCurrentItemStatusNew, context: nil)
        removeObserver(self, forKeyPath: kCurrentItemLoadedTimeRangesNew, context: nil)
        removeObserver(self, forKeyPath: kCurrentItemPlaybackBufferEmptyNew, context: nil)
        removeObserver(self, forKeyPath: kCurrentItemPlaybackBufferGoodNew, context: nil)
        removeObserver(self, forKeyPath: kCurrentItemErrorNew, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == kPlayerStatusNew {
            switch(status)
            {
            case .Failed:
                self.delegate?.playerError()
                break;
            case .ReadyToPlay:
                delegate?.playerReady()
                break;
            case .Unknown:
                break;
            }
        } else if keyPath == kCurrentItemPlaybackBufferEmptyNew {
            if let item = currentItem where item.playbackBufferEmpty {
                self.delegate?.playerIsBuffering(true)
            }
        } else if keyPath == kCurrentItemErrorNew {
            if let item = currentItem, error = item.error {
                self.delegate?.playerError()
            }
        } else if keyPath == kCurrentItemPlaybackBufferGoodNew {
            if let item = currentItem where item.playbackLikelyToKeepUp {
                self.delegate?.playerIsBuffering(false)
            }
        } else if keyPath == kCurrentItemLoadedTimeRangesNew {
            if let item = currentItem {
                print(item.loadingProgress)
            }
        }
    }
    
    func showLoadingProgressOfAll() {
        for (index,item) in items().enumerate() {
            if let customItem = item as? AVPlayerItemCustom {
                print("Index:\(index), Loading Progress:\(customItem.loadingProgress)")
            }
        }
        print("------------------------------")
    }
    
    func playerDidPlayToEndTimeNotification(notification: NSNotification) {
        let playerItem: AVPlayerItem = notification.object as! AVPlayerItem
        if (playerItem != self.currentItem) {
            return
        }
        if !isLastItem(playerItem) {
            self.advanceToNextItem()
        }
        // Reset player and play
        self.seekToTime(kCMTimeZero)
        self.play()
    }
    
    func indexOfCurrentItemInOriginalQueue() -> Int? {
        if let item = currentItem, index = originalQueue[item] {
            return index
        }
        return nil
    }
    
    func isLastItem(playerItem:AVPlayerItem) -> Bool {
        return self.items().last == playerItem
    }
    
    // Since the current item gets removed when advancing, append it to the end so it loops
    override func advanceToNextItem() {
        let aboutToBeDeletedItem = currentItem
        super.advanceToNextItem()
        if let item = aboutToBeDeletedItem where canInsertItem(item, afterItem: items().last) {
            item.seekToTime(CMTimeMake(0, 1))
            insertItem(item, afterItem: items().last)
        }
    }
}