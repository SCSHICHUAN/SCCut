//
//  TestController.swift
//  SCCut
//
//  Created by Stan on 2023/4/2.
//

import Foundation

import UIKit
import AVFoundation

class TestController: UIViewController {
    
    var player:AVPlayer!
    var playerLayer:AVPlayerLayer!
    let editor = ZYVideoEditor()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //        initAssets()
        self.view.backgroundColor = UIColor.blue
    }
    
    @objc open func start(arry:NSMutableArray) {
        var assets = [AVAsset]()
        var timeRanges = [CMTimeRange]()
        
        
        
        
        for item in arry{
            let  asset = item as! AVAsset;
            assets.append(asset)
            timeRanges.append(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration))
        }
        
        
        //       for index in 1...4 {
        //            let asset = AVAsset.init(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: "test\(index)", ofType: "MP4")!))
        //            assets.append(asset)
        //            //截取视频前5秒
        //            timeRanges.append(CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMake(value: 5, timescale: 1)))
        //        }
        
        editor.clips = assets
        editor.clipRanges = timeRanges
        
        editor.buildComposition()
        
        let playItem = AVPlayerItem.init(asset: editor.compostion)
        playItem.videoComposition = editor.videoComposition
        
        player = AVPlayer.init(playerItem: playItem)
        playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = CGRect.init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 100)
        playerLayer.position = view.center
        view.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
}

