
import AVFoundation

class LoopingPlayer: AVPlayer {
    
    var loopCount: Double = 0
    var timer: NSTimer?
    
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
    
    func commonInit() {
        self.actionAtItemEnd = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"playerDidPlayToEndTimeNotification:", name:AVPlayerItemDidPlayToEndTimeNotification, object:nil)
    }
    
    deinit {
        self.timer?.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func playerDidPlayToEndTimeNotification(notification: NSNotification) {
        let playerItem: AVPlayerItem = notification.object as! AVPlayerItem
        if (playerItem != self.currentItem) {
            return
        }
        self.seekToTime(kCMTimeZero)
        self.play()
        loopCount += 1
    }
}