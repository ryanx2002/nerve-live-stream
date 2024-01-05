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
import Amplify

class StreamerOfflineViewController : BaseViewController {
    
    var wifiBad = false
    
    func makeVideoAppear() {
        addChild(video)
        video.view.frame = CGRect(x: 38 + 40 + 8, y: 60 + 3 + 17 + 3 + 17 + 17 + 5 + 17 + 38, width: 257, height: 257*352/199)
        view.addSubview(video.view)
        video.didMove(toParent: self)
        try! AVAudioSession.sharedInstance().setCategory(.playback)
        video.player!.play()
    }
    
    var streamSubscription : GraphQLSubscriptionOperation<Stream>?
    
    func createStreamSubscription(handler: @escaping () -> Any) {
        streamSubscription = Amplify.API.subscribe(request: .subscription(of: Stream.self, type: .onCreate), valueListener: { (subscriptionEvent) in
            switch subscriptionEvent {
            case .connection(let subscriptionConnectionState):
                print("StreamView subscription connect state is \(subscriptionConnectionState)")
            case .data(let result):
                switch result {
                case .success(let createdStream):
                    print("Successfully got Stream from subscription: \(createdStream)")
                    DispatchQueue.main.async{
                        handler()
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    self.createStreamSubscription(handler: handler)
                }
            }
        }) { result in
            switch result {
            case .success:
                print("Subscription has been closed successfully")
            case .failure(let apiError):
                print("Subscription has terminated with \(apiError)")
                self.createStreamSubscription(handler: handler)
            }
        }
    }
    
    func cancelStreamSubscription() {
        streamSubscription?.cancel()
    }
    
    func streamCreated() {
        self.cancelStreamSubscription()
        getAppDelegate().isStream = true
        let live = LiveViewController()
        live.fresh = false
        getAppDelegate().changeToViewController(root: live)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !wifiBad {
            createStreamSubscription(handler: streamCreated)
            StreamingBackend.stream.getCurrentStreamViews() {
                streamViews in 
                print("hey this works")
                for streamView in streamViews {
                    if (streamView.streamId == "show") {
                        print("found SHOW")
                        DispatchQueue.main.async {
                            self.makeVideoAppear()
                            self.view.addSubview(self.subtitleTwo)
                            self.view.addSubview(self.exampleLabel)
                            self.view.addSubview(self.examples)
                        }
                        break
                    } else {
                        print("found other:", streamView.streamId)
                    }
                }
                print("finished searching")
            }
            
        } else {
            view.addSubview(reconnectButton)
        }
        view.addSubview(ryanFace)
        view.addSubview(titleLabel)
        view.addSubview(subtitleOne)
        view.addSubview(subtitleThree)
        
        view.addSubview(menuBtn)
    }
    lazy var reconnectButton: UIButton = {
        let playBtn = UIButton(type: .custom)
        playBtn.frame = CGRect(x: (K_SCREEN_WIDTH - 175) / 2, y: K_SCREEN_HEIGHT - 300, width: 175, height: 65)
        playBtn.backgroundColor = .clear
        playBtn.setImage(UIImage(named: "reconnect_button"), for: .normal)
        playBtn.addTarget(self, action: #selector(reconnectClick), for: .touchUpInside)
        return playBtn
    }()
    
    func liveAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                   style: .default, handler: nil)
        alertController.addAction(action)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }

    @objc func reconnectClick() {
        DispatchQueue.main.async {
            if getAppDelegate().monitor?.currentPath.status == .satisfied {
                getAppDelegate().changeRootViewController()
            } else {
                self.liveAlert(title: "Internet connection not detected", message: "Please try again once a stable internet connection has been established")
            }
        }
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
        let titleLabel = UILabel(frame: CGRect(x: 38 + 40 + 8, y: 60 + 3, width: 180, height: 17))
        titleLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        titleLabel.font = UIFont(name: "Inter-Bold", size: 14)
        if wifiBad {
            titleLabel.text = "You are currently offline"
        } else {
            titleLabel.text = "Ryan is going live soon."
        }
        return titleLabel
    }()
    
    lazy var subtitleOne : UILabel = {
        let subtitleOne = UILabel(frame: CGRect(x: 38 + 40 + 8, y: 60 + 3 + 17 + 3, width: 257, height: 34))
        subtitleOne.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        subtitleOne.font = UIFont(name: "Inter-Regular", size: 14)
        if wifiBad {
            subtitleOne.text = "Please reconnect to the internet to connect to stream"
            subtitleOne.numberOfLines = 0
        } else {
            subtitleOne.text = "You'll be notified when Ryan goes Live."
        }
        return subtitleOne
    }()
    
    lazy var subtitleTwo : UILabel = {
        let subtitleTwo = UILabel(frame: CGRect(x: 38 + 40 + 8, y: 60 + 3 + 17 + 3 + 17 + 9, width: 257, height: 17))
        subtitleTwo.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        subtitleTwo.font = UIFont(name: "Inter-Regular", size: 14)
        if !wifiBad {
            subtitleTwo.text = "You can dare him to do ANYTHING."
        }
        return subtitleTwo
    }()
    lazy var subtitleThree : UILabel = {
        let subtitleThree = UILabel(frame: CGRect(x: 38 + 40 + 8, y: 60 + 3 + 17 + 3 + 17 + 17 + 20, width: 257, height: 17))
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
    
    lazy var menuBtn: UIButton = {
        let menuBtn = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - 48, y: K_SAFEAREA_TOP_HEIGHT(), width: 48, height: 48))
        menuBtn.backgroundColor = .clear
        menuBtn.setImage(UIImage(named: "icon_line_menu"), for: .normal)
        menuBtn.addTarget(self, action: #selector(menuBtnClick), for: .touchUpInside)
        return menuBtn
    }()

    @objc func menuBtnClick() {
        let vc = SettingViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    lazy var exampleLabel : UILabel = {
        let xCoord = 38 + 40 + 8
        let yCoord = 60 + 3 + 17 + 3 + 17 + 17 + 5 + 17 + 38 + 257*352/199 + 19
        let exampleLabel = UILabel(frame: CGRect(x: xCoord, y: yCoord, width: 257, height: 17))
        exampleLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        exampleLabel.font = UIFont(name: "Inter-Regular", size: 14)
        exampleLabel.text = "Examples of Previous Dares"
        exampleLabel.textAlignment = .center
        return exampleLabel
    }()
    
    lazy var examples : UILabel = {
        let yCoord = 60 + 3 + 17 + 3 + 17 + 17 + 5 + 17 + 38 + 257*352/199 + 19
        let examples = UILabel(frame: CGRect(x: 38, y: yCoord, width: 313, height: 196))
        examples.font = UIFont(name: "Inter-Regular", size: 14)
        examples.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        examples.numberOfLines = 0
        examples.lineBreakMode = .byWordWrapping
        examples.text = "$5 - say/yell anything\n$5 - do the worm\n\n$10 - take your shirt or pants off\n$10 - bark like a dog at someone on all fours\n\n$15 - twerk / WAP dance\n$15 - piss your pants"
        return examples
    }()
}


// preview stuff. note Amplify functions cause preview to crash
/*
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
*/
