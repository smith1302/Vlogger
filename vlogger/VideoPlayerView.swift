//
//  VideoPlayerView
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    var playerLayer:AVPlayerLayer?
    
    func addPlayerLayer(playerLayer:AVPlayerLayer) {
        self.playerLayer = playerLayer
        layer.addSublayer(playerLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }
    
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
