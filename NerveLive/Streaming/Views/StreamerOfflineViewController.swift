//
//  StreamerOfflineViewController.swift
//  NerveLive
//
//  Created by Matthew Chen on 12/30/23.
//

import Foundation
import UIKit
import SwiftUI
import AVKit
import AVFoundation

class StreamerOfflineViewController : BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(ryanFace)
        view.addSubview(titleLabel)
        view.addSubview(subtitleOne)
        //view.addSubview(subtitleTwo)
        view.addSubview(subtitleThree)
        
        addChild(video)
        video.view.frame = CGRect(x: 38 + 40 + 8, y: 60 + 3 + 17 + 3 + 17 + 17 + 5 + 17 + 38, width: 257, height: 257*352/199)
        view.addSubview(video.view)
        video.didMove(toParent: self)
        try! AVAudioSession.sharedInstance().setCategory(.playback)
        video.player!.play()
    }
    
    lazy var ryanFace : UIImageView = {
        let ryansFace = UIImageView(frame: CGRect(x: 38, y: 60, width: 40, height: 45))
        ryansFace.layer.cornerRadius = 20
        ryansFace.layer.masksToBounds = true
        ryansFace.image = UIImage(named: "ryan_face")
        ryansFace.alpha = 1
        return ryansFace
    }()
    
    lazy var titleLabel : UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 38 + 40 + 8, y: 60 + 3, width: 160, height: 17))
        titleLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        titleLabel.font = UIFont(name: "Inter-Bold", size: 14)
        titleLabel.text = "Ryan is going live soon."
        return titleLabel
    }()
    
    lazy var subtitleOne : UILabel = {
        let subtitleOne = UILabel(frame: CGRect(x: 38 + 40 + 8, y: 60 + 3 + 17 + 3, width: 257, height: 17))
        subtitleOne.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        subtitleOne.font = UIFont(name: "Inter-Regular", size: 14)
        subtitleOne.text = "You'll be notified when Ryan goes Live"
        return subtitleOne
    }()
    
    lazy var subtitleTwo : UILabel = {
        let subtitleTwo = UILabel(frame: CGRect(x: 38 + 40 + 8, y: 60 + 3 + 17 + 3 + 17, width: 257, height: 17))
        subtitleTwo.textColor = UIColor(red: 0.965, green: 0, blue: 0.42, alpha: 1)
        subtitleTwo.font = UIFont(name: "Inter-Regular", size: 14)
        subtitleTwo.text = "and then you can dare him."
        return subtitleTwo
    }()
    lazy var subtitleThree : UILabel = {
        let subtitleThree = UILabel(frame: CGRect(x: 38 + 40 + 8, y: 60 + 3 + 17 + 3 + 17 + 17 + 5, width: 257, height: 17))
        subtitleThree.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        subtitleThree.font = UIFont(name: "Inter-Regular", size: 14)
        subtitleThree.text = "TikTok: @rahultok_         IG: @ryanxietv"
        return subtitleThree
    }()
    
    lazy var video : AVPlayerViewController = {
        guard let path = Bundle.main.path(forResource: "Nerve Livestream Home Screen Preview", ofType:"mov") else {
                    debugPrint("video not found")
                    return AVPlayerViewController()
                }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        return playerController
        /*
        present(playerController, animated: true) {
            player.play()
        }*/
    }()
}


// preview stuff. note Amplify functions cause preview to crash

struct StreamerOfflineView: UIViewControllerRepresentable {
    typealias UIViewControllerType = StreamerOfflineViewController
    func makeUIViewController(context: Context) -> StreamerOfflineViewController {
            let vc = StreamerOfflineViewController()
            return vc
        }
    func updateUIViewController(_ uiViewController: StreamerOfflineViewController, context: Context) {
        }
    }

struct StreamerOfflineViewControllerPreview: PreviewProvider {
    static var previews: some View {
        return StreamerOfflineView()
    }
}
