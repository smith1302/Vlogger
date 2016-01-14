
import AVFoundation

protocol LoopingPlayerDelegate:class {
    func statusChanged(_: Float64)
    func playerIsBuffering(isBuffering:Bool)
    func playerReady()
    func playerError()
    func playerDidAdvanceToNextItem()
    func playerHasNoVideosToPlay()
}

class LoopingPlayer: AVQueuePlayer {
    
    var loopCount: Double = 0
    var timeObserver: AnyObject?
    weak var delegate:LoopingPlayerDelegate?
    var originalQueueIndexForItem:[AVPlayerItem:Int] = [AVPlayerItem:Int]()
    var originalQueue:[AVPlayerItem] = [AVPlayerItem]()
    
    override init() {
        super.init()
        self.commonInit()
    }
    
    override init(URL url: NSURL) {
        super.init(URL: url)
        self.commonInit()
    }
    
    override init(playerItem item: AVPlayerItem) {
        super.init(playerItem: item)
        self.commonInit()
    }
    
    override init(items: [AVPlayerItem]) {
        super.init(items: items)
        self.commonInit()
    }
    
    let kPlayerStatusNew = "status"
    let kCurrentItemStatusNew = "currentItem.status"
    let kCurrentItemLoadedTimeRangesNew = "currentItem.loadedTimeRanges"
    let kCurrentItemPlaybackBufferEmptyNew = "currentItem.playbackBufferEmpty"
    let kCurrentItemPlaybackBufferGoodNew = "currentItem.playbackLikelyToKeepUp"
    let kCurrentItemErrorNew = "currentItem.error"
    
    func commonInit() {
        captureAudioSession()
        for (index,item) in items().enumerate() {
            originalQueueIndexForItem[item] = index
            originalQueue.append(item)
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
        cleanUp()
    }
    
    // Some issue with AVPLayerLayer not removing a reference to the player, so cleanup manually
    func cleanUp() {
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
            if let item = currentItem where (item.playbackBufferEmpty && item.loadingProgress < 0.1) {
                self.delegate?.playerIsBuffering(true)
            }
        } else if keyPath == kCurrentItemErrorNew {
            if let item = currentItem, error = item.error {
                print(error)
                self.delegate?.playerError()
            }
        } else if keyPath == kCurrentItemPlaybackBufferGoodNew {
            if let item = currentItem where item.playbackLikelyToKeepUp {
                self.delegate?.playerIsBuffering(false)
            }
        } else if keyPath == kCurrentItemLoadedTimeRangesNew {
//            if let item = currentUnloadedItem {
//                print("Loading: \(item.loadingProgress*100)%")
//                if item.loadingProgress >= 0.9 {
//                    print("NEXT:-------------------------")
//                    self.advanceUnloadedItem()
//                }
//            }
        }
    }
    
    override func play() {
        super.play()
        captureAudioSession()
    }
    
    func captureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryAmbient)
            try audioSession.setActive(true)
        } catch {}
    }
    
    func playerDidPlayToEndTimeNotification(notification: NSNotification) {
        let playerItem: AVPlayerItem = notification.object as! AVPlayerItem
        if (playerItem != self.currentItem) {
            return
        }
        if items().count > 1 {
            self.advanceToNextItem()
        } else {
            // Let our delegate know that we are playing a new item, even though its just looping the same one
            delegate?.playerDidAdvanceToNextItem()
        }
        // Reset player and play
        self.seekToTime(kCMTimeZero)
        self.play()
    }
    
    func indexOfCurrentItemInOriginalQueue() -> Int? {
        if let item = currentItem, index = originalQueueIndexForItem[item] {
            return index
        }
        return nil
    }
    
    // Since the current item gets removed when advancing, append it to the end so it loops
    override func advanceToNextItem() {
        let aboutToBeDeletedItem = currentItem
        super.advanceToNextItem()
        delegate?.playerDidAdvanceToNextItem()
        if let item = aboutToBeDeletedItem where canInsertItem(item, afterItem: items().last) {
            item.seekToTime(CMTimeMake(0, 1))
            insertItem(item, afterItem: items().last)
        }
    }
    
    func removeCurrentItem() {
        if let item = currentItem {
            // Remove item from original queue list
            if let originalQeueueIndex = originalQueueIndexForItem[item] {
                originalQueue.removeAtIndex(originalQeueueIndex)
                originalQueueIndexForItem.removeValueForKey(item)
            }
            updateOriginalQueueIndexMapping()
            removeItem(item)
        }
        if items().count == 0 {
            delegate?.playerHasNoVideosToPlay()
        }
    }
    
    func updateOriginalQueueIndexMapping() {
        for (index, item) in originalQueue.enumerate() {
            originalQueueIndexForItem[item] = index
        }
    }
    
    func resetPlayerToBeginning() {
        if originalQueue.count == 0 {
            return
        }
        while currentItem != nil && currentItem != originalQueue[0] {
            advanceToNextItem()
        }
        pause()
    }
}