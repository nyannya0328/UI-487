//
//  PreViewPlayer.swift
//  UI-487
//
//  Created by nyannyan0328 on 2022/03/01.
//

import SwiftUI
import AVKit

struct PreViewPlayer: UIViewControllerRepresentable {
    
    @Binding var url : URL
    @Binding var progress : CGFloat
   
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
        let player = AVPlayer(url: url)
        
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        controller.player = player
        
        
        return controller
        
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
        
        let playerURL = (uiViewController.player?.currentItem?.asset as? AVURLAsset)?.url
        
        if let playerURL = playerURL,playerURL != url{
            
            
            uiViewController.player = AVPlayer(url: url)
            
        }
        
        
        let duration = uiViewController.player?.currentItem?.duration.seconds ?? 0
        
        let time = CMTime(seconds: progress * duration, preferredTimescale: 600)
        
        uiViewController.player?.seek(to: time)
        
        
    }
}

