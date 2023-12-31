//
//  LiveViewController.swift
//  NerveLive
//
//  Created by wbx on 13/12/2023.
//

import UIKit
import AWSKinesisVideo
import WebRTC
import SwiftUI
import SVProgressHUD
import Amplify
import Collections
import StoreKit
import WebKit

class LiveViewController: BaseViewController {

    var mediaServerEndPoint: String?
    
    var currStreamId : String?
    
    var dareBubbles: Deque<UIView>?
    var comments: Deque<UILabel>?
    
    var cameraPositionIsFront = true
    
    var fakeCommentingEnabled = false
    
    var fresh = true
    
    let bubbleBorderColor = Colors.CGWhite
    
    var numViewers : Int = 20
    
    var newUiEnabled = false
    
    public var availableProducts : Dictionary<String,SKProduct>?
    
    fileprivate var productRequest: SKProductsRequest!
    var inAppPurchasesObserver : StoreObserver?
    
    /// 进入直播间
    func enterLiveRoom() {
        LiveManager.shared.enterLiveRoom()
    }

    /// 退出直播间
    func exitLiveRoom() {
        LiveManager.shared.exitLiveRoom()
    }

    var giftSubscription : GraphQLSubscriptionOperation<Gift>?
    
    func createGiftSubscription(handler: @escaping (Gift) -> Any) {
        giftSubscription = Amplify.API.subscribe(request: .subscription(of: Gift.self, type: .onCreate), valueListener: { (subscriptionEvent) in
            switch subscriptionEvent {
            case .connection(let subscriptionConnectionState):
                print("Gift subscription connect state is \(subscriptionConnectionState)")
            case .data(let result):
                switch result {
                case .success(let createdGift):
                    print("Successfully got gift from subscription: \(createdGift)")
                    DispatchQueue.main.async{
                        handler(createdGift)
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            }
        }) { result in
            switch result {
            case .success:
                print("Subscription has been closed successfully")
            case .failure(let apiError):
                print("Subscription has terminated with \(apiError)")
                self.createGiftSubscription(handler: handler)
            }
        }
    }
    
    func cancelGiftSubscription() {
        giftSubscription?.cancel()
    }
    
    var commentSubscription : GraphQLSubscriptionOperation<Comment>?
    
    func createCommentSubscription(handler: @escaping (Comment) -> Any) {
        commentSubscription = Amplify.API.subscribe(request: .subscription(of: Comment.self, type: .onCreate), valueListener: { (subscriptionEvent) in
            switch subscriptionEvent {
            case .connection(let subscriptionConnectionState):
                print("Comment subscription connect state is \(subscriptionConnectionState)")
            case .data(let result):
                switch result {
                case .success(let createdComment):
                    print("Successfully got comment from subscription: \(createdComment)")
                    DispatchQueue.main.async{
                        handler(createdComment)
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            }
        }) { result in
            switch result {
            case .success:
                print("Subscription has been closed successfully")
            case .failure(let apiError):
                print("Subscription has terminated with \(apiError)")
                self.createCommentSubscription(handler: handler)
            }
        }
    }
    
    func cancelCommentSubscription() {
        commentSubscription?.cancel()
    }
    
    var streamViewSubscription : GraphQLSubscriptionOperation<StreamView>?
    
    func createStreamViewSubscription(handler: @escaping (StreamView) -> Any) {
        streamViewSubscription = Amplify.API.subscribe(request: .subscription(of: StreamView.self, type: .onCreate), valueListener: { (subscriptionEvent) in
            switch subscriptionEvent {
            case .connection(let subscriptionConnectionState):
                print("StreamView subscription connect state is \(subscriptionConnectionState)")
            case .data(let result):
                switch result {
                case .success(let createdStreamView):
                    print("Successfully got StreamView from subscription: \(createdStreamView)")
                    DispatchQueue.main.async{
                        handler(createdStreamView)
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    self.createStreamViewSubscription(handler: handler)
                }
            }
        }) { result in
            switch result {
            case .success:
                print("Subscription has been closed successfully")
            case .failure(let apiError):
                print("Subscription has terminated with \(apiError)")
                self.createStreamViewSubscription(handler: handler)
            }
        }
    }
    
    func cancelStreamViewSubscription() {
        streamViewSubscription?.cancel()
    }
    
    var streamSubscription : GraphQLSubscriptionOperation<Stream>?
    
    func createStreamSubscription(handler: @escaping (Stream) -> Any) {
        streamSubscription = Amplify.API.subscribe(request: .subscription(of: Stream.self, type: .onUpdate), valueListener: { (subscriptionEvent) in
            switch subscriptionEvent {
            case .connection(let subscriptionConnectionState):
                print("StreamView subscription connect state is \(subscriptionConnectionState)")
            case .data(let result):
                switch result {
                case .success(let createdStream):
                    print("Successfully got updated Stream from subscription: \(createdStream)")
                    DispatchQueue.main.async{
                        handler(createdStream)
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
    
    func streamUpdated(stream : Stream) {
        if stream.endTime != nil {
            print("STREAM ENDED")
            getAppDelegate().isStream = false
            getAppDelegate().changeRootViewController()
        }
    }
    
    
    // get products
    func initializeInAppPurchases() {
        inAppPurchasesObserver = StoreObserver()
        inAppPurchasesObserver!.delegate = self
        SKPaymentQueue.default().add(inAppPurchasesObserver!)
        availableProducts = [:]
        fetchProductInformation(productIds: [Messages.firstPriceGiftProductId, Messages.secondPriceGiftProductId, Messages.thirdPriceGiftProductId])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeInAppPurchases()
        
        dareBubbles = Deque<UIView>()
        comments = Deque<UILabel>()
        
        if (LoginTools.sharedTools.userInfo().phone!) != "+17048901338" {
            StreamingBackend.stream.getCurrentStreamId2() {
                streams in 
                var found = false
                for stream in streams {
                    if (stream.endTime == nil) {
                        print("found id: " + stream.id)
                        self.currStreamId = stream.id
                        found = true
                        self.createStreamSubscription(handler: self.streamUpdated)
                        break
                    }
                }
                
                if !found {
                    print("NO STREAM FOUND")
                    DispatchQueue.main.async {
                        getAppDelegate().isStream = false
                        getAppDelegate().changeRootViewController()
                    }
                }
            }
            if fresh {
                DispatchQueue.main.async {
                    let welcomeQuest = WelcomeQuestViewController();
                    self.navigationController?.pushViewController(welcomeQuest, animated: true)
                }
            }
        }

        if (LoginTools.sharedTools.userInfo().phone!) != "8159912449" {
            // In viewer mode send offer once connection is established
            if let webRTCClient = LiveManager.shared.webRTCClient {
                webRTCClient.offer { sdp in
                    if let signalingClient = LiveManager.shared.signalingClient {
                        signalingClient.sendOffer(rtcSdp: sdp, senderClientid: LiveManager.shared.localSenderId)
                    }
                }
            }
            // only add text input bar in viewer mode
        } else {
            // only add close button in streamer mode
        }
        if mediaServerEndPoint == nil {
            //self.joinStorageButton?.isHidden = true
        }
        
        
        /// 如果是master隐藏对方视频内容,  如果是viewer隐藏本地视频内容
        print(LoginTools.sharedTools.userInfo().phone!)
        if (LoginTools.sharedTools.userInfo().phone!) == "+17048901338" {
            #if arch(arm64)
            // Using metal (arm64 only)
            let localRenderer = RTCMTLVideoView(frame: localVideoView.frame)
            let remoteRenderer = RTCMTLVideoView(frame: view.frame)
            localRenderer.videoContentMode = .scaleAspectFill
            remoteRenderer.videoContentMode = .scaleAspectFill
            remoteRenderer.backgroundColor = .black
            #else
            // Using OpenGLES for the rest
            let localRenderer = RTCEAGLVideoView(frame: localVideoView.frame)
            let remoteRenderer = RTCEAGLVideoView(frame: view.frame)
            remoteRenderer.backgroundColor = .black
            #endif
            
            createStreamViewSubscription(handler: createJoinerLabel)
            
            LiveManager.shared.webRTCClient?.startCaptureLocalVideo(renderer: localRenderer, camera: .front )
            LiveManager.shared.webRTCClient?.renderRemoteVideo(to: remoteRenderer)


            embedView(localRenderer, into: localVideoView)
            embedView(remoteRenderer, into: view)
            view.sendSubviewToBack(remoteRenderer)
            remoteRenderer.isHidden = true
            self.localVideoView.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            view.addSubview(localVideoView)
            view.addSubview(lookBtn)
            view.addSubview(liveBtn)
            AppDelegate.AppUtility.lockOrientation(.landscapeLeft, andRotateTo: .landscapeLeft)
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        } else {
            let screenMidX = K_SCREEN_WIDTH/2
            let screenMidY = K_SCREEN_HEIGHT/2
            
            //this is so stupid, but the twitch embedding changes its behavior at different sizes
            let viewerWidth = K_SCREEN_HEIGHT
            let viewerHeight = K_SCREEN_HEIGHT
            
            /*let viewerWidth = K_SCREEN_WIDTH*(926/428)/(1920/1080)
             let viewerHeight = K_SCREEN_WIDTH*(926/428)
             */
            
            //Pre-transform coordinates
            let twitchView = createViewer(url: "https://player.twitch.tv/?channel=ryanmillion_&parent=quest-livestream", frame: CGRect(x: screenMidX - viewerHeight/2, y: screenMidY - viewerWidth/2, width: viewerHeight, height: viewerWidth))
            
            twitchView.translatesAutoresizingMaskIntoConstraints = true
            
            twitchView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
            print("twitch view loading")
            view.addSubview(twitchView)
            twitchView.isUserInteractionEnabled = false
        }
        
        if (LoginTools.sharedTools.userInfo().phone!) != "+17048901338" /* if user is not Ryan */ {
            if (!newUiEnabled){
                view.addSubview(textInputBar)
                textInputBar.delegate = self
            } else {
                view.addSubview(newCommentButton)
                view.addSubview(newDareButton)
            }
            StreamingBackend.stream.startStreamView(streamId: currStreamId ?? "bad", userId: LoginTools.sharedTools.userInfo().id)
        } else { // when user is Ryan
            view.addSubview(closeBtn)
            currStreamId = StreamingBackend.stream.createStream(streamerId: LoginTools.sharedTools.userInfo().id)
            
            //since using Twitch screenshare stream of Nerve streamer page, only add comment and gift subscription on Ryan's screen
            createGiftSubscription(handler: createDareBubble)
            createCommentSubscription(handler: createCommentLabel)
            print("currStreamId: " + currStreamId!)
            
            //view.addSubview(textInputBar)
            //textInputBar.delegate = self
        }
        
        enterLiveRoom()
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": view]))

        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": view]))
        containerView.layoutIfNeeded()
    }

    @objc func closeLive() {
        LiveManager.shared.webRTCClient?.shutdown()
        LiveManager.shared.signalingClient?.disconnect()
        exitLiveRoom()
        let username = (LoginTools.sharedTools.userInfo().firstName ?? "[unknown first name]") + " " + (LoginTools.sharedTools.userInfo().lastName ?? "[unknown last name]")
        debugPrint("Live closed for user " + username)
        cancelGiftSubscription()
        cancelCommentSubscription()
       
        
        
        
        SKPaymentQueue.default().remove(inAppPurchasesObserver!)
        
        if fakeCommentingEnabled {
            DispatchQueue.main.async {
                self.fakeCommenting.cancel()
            }
        }
        StreamingBackend.stream.finishStream(currStreamId: currStreamId!, streamerId: LoginTools.sharedTools.userInfo().id)
        if (LoginTools.sharedTools.userInfo().phone!) == "+17048901338" {
            cancelStreamViewSubscription()
        } else {
            cancelStreamSubscription()
        }
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        dismiss(animated: true)
    }
    
    let fakeCommenting = DispatchWorkItem {
        var time = Int.random(in: 3...7)
        var fakeUser = ""
        var fakeComment = ""
        while true {
            sleep(UInt32(time))
            fakeUser = FakeComments.users[Int.random(in: 0..<FakeComments.users.count)]
            fakeComment = FakeComments.comments[Int.random(in: 0..<FakeComments.comments.count)]
            StreamingBackend.stream.logComment(name: fakeUser, msg: fakeComment)
            time = Int.random(in: 3...7)
        }
    }
    
//    @IBAction func joinStorageSession(_: Any) {
//        print("button pressed")
//        joinStorageButton?.isHidden = true
//    }
    
    func createViewer(url : String, frame : CGRect) -> WKWebView {
        // Initialize a WKWebViewConfiguration object.
        let webViewConfiguration = WKWebViewConfiguration()
        // Let HTML videos with a "playsinline" attribute play inline.
        webViewConfiguration.allowsInlineMediaPlayback = true
        // Let HTML videos with an "autoplay" attribute play automatically.
        webViewConfiguration.mediaTypesRequiringUserActionForPlayback = []
        
        let url2 = URL(string: url)
        
        let wkwebView = WKWebView(frame: frame, configuration: webViewConfiguration)
        let request = URLRequest(url: url2!)
        wkwebView.load(request)
        DispatchQueue.main.async {
            wkwebView.evaluateJavaScript("""
                                         {
                                         const hideElements = (...el) => {
                                           el.forEach((el) => {
                                             el?.style.setProperty("display", "none", "important");
                                           })
                                         }
                                         const hide = () => {
                                           const topBar = document.querySelector(".top-bar");
                                           const playerControls = document.querySelector(".player-controls");
                                           const channelDisclosures = document.querySelector("#channel-player-disclosures");
                                           hideElements(topBar, playerControls, channelDisclosures);
                                         }
                                         const observer = new MutationObserver(() => {
                                           const videoOverlay = document.querySelector('.video-player__overlay');
                                           if(!videoOverlay) return;
                                           hide();
                                           const videoOverlayObserver = new MutationObserver(hide);
                                           videoOverlayObserver.observe(videoOverlay, { childList: true, subtree: true });
                                           observer.disconnect();
                                         });
                                         observer.observe(document.body, { childList: true, subtree: true });
                                         }
                                         """) { (result, error) in
                if error == nil {
                    print("webview result", result)
                } else {
                    print("webview error", error)
                    /*
                    DispatchQueue.main.async {
                        var bubble = UIView(frame: CGRect(x: 200, y: K_SAFEAREA_TOP_HEIGHT() + 36 + 12, width: 173, height: 47))
                        bubble.layer.cornerRadius = 20
                        bubble.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
                        //bubble.layer.borderWidth = 0.5
                        
                        let layer0 = CAGradientLayer()
                        layer0.colors = [
                            UIColor(red: 148/255, green: 0/255, blue: 211/255, alpha: 1).cgColor,
                        UIColor(red: 148/255, green: 0/255, blue: 211/255, alpha: 0.3).cgColor
                        ]
                        layer0.locations = [0, 1]
                        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
                        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
                        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 192/K_SCREEN_WIDTH, b: 0, c: 0, d: 410/K_SCREEN_HEIGHT, tx: 87, ty: 23))
                        layer0.bounds = bubble.bounds.insetBy(dx: -0.5*bubble.bounds.size.width, dy: -0.5*bubble.bounds.size.height)
                        layer0.cornerRadius = 40
                        bubble.layer.addSublayer(layer0)
                        
                        var msgLabel = UILabel(frame: CGRect(x: 10, y: 3, width: 114, height: 36))
                        msgLabel.textColor = .white
                        msgLabel.font = UIFont(name: "Inter-Bold", size: 11)
                        msgLabel.lineBreakMode = .byWordWrapping
                        msgLabel.numberOfLines = 0
                        msgLabel.text = "LOADING FAILED"
                        bubble.addSubview(msgLabel)
                        
                        var priceLabel = UILabel(frame: CGRect(x: 10 + 114 + 3, y: 0, width: 41, height: 46))
                        priceLabel.textColor = Colors.darePriceLabel
                        priceLabel.font = UIFont(name: "Inter-Bold", size: 22)
                        priceLabel.text = "$NA"
                        bubble.addSubview(priceLabel)
                        self.updateDareBubbles(newBubble: bubble)
                    }
                     */
                }
            }
        }
        return wkwebView
    }
    
    
    lazy var localVideoView: UIView = {
        // let localVideoView = UIView(frame: CGRect(x: 16, y: K_SAFEAREA_TOP_HEIGHT() + 16, width: 200, height: 200))
        //let localVideoView = UIView(frame: view.bounds) // 全屏展示(full screen display)
        let localVideoView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        return localVideoView
    }()
    
    lazy var newCommentButton : UIButton = {
        let commentButton = UIButton(frame: CGRect(x: 20, y: K_SCREEN_HEIGHT - 44 - 35, width: (kScreenWidth - 40 - 8)/2, height: 44))
        commentButton.layer.backgroundColor = UIColor(red: 0.251, green: 0.251, blue: 0.251, alpha: 1).cgColor
        commentButton.layer.cornerRadius = 25
        commentButton.layer.masksToBounds = true
        return commentButton
    }()
    
    lazy var newDareButton : UIButton = {
        let dareButton = UIButton(frame: CGRect(x: 20 + (kScreenWidth - 40 - 8)/2 + 8, y: K_SCREEN_HEIGHT - 44 - 35, width: (kScreenWidth - 40 - 8)/2, height: 44))
        dareButton.layer.backgroundColor = UIColor(red: 0.597, green: 0, blue: 0.538, alpha: 1).cgColor
        dareButton.layer.cornerRadius = 25
        dareButton.layer.masksToBounds = true
        return dareButton
    }()
    
    lazy var closeBtn: UIButton = {
        let closeBtn = UIButton(frame: CGRect(x: 16, y: K_SAFEAREA_TOP_HEIGHT(), width: 44, height: 44))
        closeBtn.backgroundColor = .clear
        closeBtn.setImage(UIImage(named: "nav_close_back"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeLive), for: .touchUpInside)
        return closeBtn
    }()

    lazy var lookBtn: UIButton = {
        let lookBtn = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - 66 - 16, y: K_SAFEAREA_TOP_HEIGHT(), width: 66, height: 36))
        lookBtn.backgroundColor = UIColor.hexColorWithAlpha(color: "4E4744", alpha: 1)
        lookBtn.setImage(UIImage(named: "icon_eye"), for: .normal)
        lookBtn.setTitle(String(numViewers), for: .normal)
        lookBtn.setTitleColor(.white, for: .normal)
        lookBtn.titleLabel?.font = UIFont.font(ofSize: 14, type: .Regular)
        lookBtn.addTarget(self, action: #selector(lookBtnClick), for: .touchUpInside)
        lookBtn.layer.cornerRadius = 5
        lookBtn.layer.masksToBounds = true
        return lookBtn
    }()

    @objc func lookBtnClick() {
        if (LoginTools.sharedTools.userInfo().phone!) == "+17048901338" {
            print("Switching cameras...")
            let localRenderer = RTCMTLVideoView(frame: localVideoView.frame)
            let remoteRenderer = RTCMTLVideoView(frame: view.frame)
            localRenderer.videoContentMode = .scaleAspectFill
            LiveManager.shared.webRTCClient?.startCaptureLocalVideo(renderer: localRenderer, camera: cameraPositionIsFront ? .back : .front )
            self.localVideoView.transform = cameraPositionIsFront ? CGAffineTransformMakeScale(1.0, 1.0) : CGAffineTransformMakeScale(-1.0, 1.0)
            cameraPositionIsFront = !cameraPositionIsFront
            embedView(localRenderer, into: localVideoView)
        } else {
            print("Switch not allowed in viewer mode")
            //StreamingBackend.stream.startStreamView(streamId: currStreamId ?? "bad", userId: LoginTools.sharedTools.userInfo().id)
        }
    }

    lazy var liveBtn: UIButton = {
        let liveBtn = UIButton(frame: CGRect(x: lookBtn.frame.minX - 50 - 16, y: K_SAFEAREA_TOP_HEIGHT(), width: 50, height: 37))
        liveBtn.backgroundColor = .clear
        liveBtn.setImage(UIImage(named: "icon_onLive"), for: .normal)
        liveBtn.addTarget(self, action: #selector(liveBtnClick), for: .touchUpInside)
        return liveBtn
    }()

    @objc func liveBtnClick() {
        if !fakeCommentingEnabled {
            DispatchQueue.global(qos: .background).async(execute: fakeCommenting)
            DispatchQueue.main.async {
                self.fakeCommentingEnabled = true
            }
        } else {
            DispatchQueue.main.async {
                self.fakeCommenting.cancel()
                self.fakeCommentingEnabled = false
            }
        }
    }
    
    var textInput = Messages.emptyString
    var textTyping = false

    lazy var textInputBar: UITextField = {
        let textInputBar = UITextField(frame: CGRect(x: 20, y: K_SCREEN_HEIGHT - 70, width: K_SCREEN_WIDTH - 40, height: 30))
        textInputBar.placeholder = Messages.unselectedPlaceholder
        textInputBar.borderStyle = .roundedRect
        //textInputBar.lineBreakMode = .byWordWrapping
        //textInputBar.textAlignment = .center
        textInputBar.autocorrectionType = .no
        textInputBar.spellCheckingType = .no
        
        return textInputBar
    }()
    
    public var YOffset = CGFloat(300)
    var widthOffset = CGFloat(80)
    var heightOffset = CGFloat(40)
    
    func resizeTextUpward(_ textField : UITextField) {
        if textTyping == false {
            textField.frame = CGRectMake(textField.frame.minX + widthOffset, textField.frame.minY - YOffset, textField.frame.width - 2*widthOffset, textField.frame.height + heightOffset)
            textTyping = true
            view.addSubview(giftButton)
            view.addSubview(commentButton)
            
            view.addSubview(submitButton)
            if gift {
                textInputBar.placeholder = Messages.giftingPlaceholder
                view.addSubview(firstPriceButton)
                view.addSubview(secondPriceButton)
                view.addSubview(thirdPriceButton)
            }
            else {
                textInputBar.placeholder = Messages.commentingPlaceholder
            }
            
            for comment in comments! {
                comment.frame = CGRectMake(20, comment.frame.minY - YOffset, K_SCREEN_WIDTH - 40, 15)
            }
            
        }
    }
    
    func resizeTextDownward(_ textField : UITextField) {
        if textTyping == true{
            textField.frame = CGRectMake(textField.frame.minX - widthOffset, textField.frame.minY + YOffset, textField.frame.width + 2*widthOffset, textField.frame.height - heightOffset)
            textTyping = false
            giftButton.removeFromSuperview()
            commentButton.removeFromSuperview()
            firstPriceButton.removeFromSuperview()
            secondPriceButton.removeFromSuperview()
            thirdPriceButton.removeFromSuperview()
            submitButton.removeFromSuperview()
            textInputBar.placeholder = Messages.unselectedPlaceholder
            for comment in comments! {
                comment.frame = CGRectMake(20, comment.frame.minY + YOffset, K_SCREEN_WIDTH - 40, 15)
            }
        }
    }
    
    // buttons that will appear when text field has been opened
    
    var gift = true // !gift implies comment
    var giftValue = Pricing.secondPrice
    
    lazy var giftButton: UIButton = {
        let giftButton = UIButton(frame: CGRect(x: 10, y: K_SCREEN_HEIGHT - 70 - YOffset, width: 85, height: 32))
        giftButton.layer.borderColor = bubbleBorderColor
        giftButton.layer.borderWidth = 0.5
        giftButton.backgroundColor = .clear
        giftButton.setTitle(Messages.giftButtonText, for: .normal)
        giftButton.setTitleColor(.white, for: .normal)
        giftButton.layer.cornerRadius = 10
        giftButton.titleLabel!.font = Fonts.giftCommentButtonFont
        giftButton.addTarget(self, action: #selector(giftButtonClick), for: .touchUpInside)
        return giftButton
    }()
    
    @objc func giftButtonClick() {
        if !gift {
            giftButton.backgroundColor = .clear
            commentButton.backgroundColor = .clear
            gift = true
            textInputBar.placeholder = Messages.giftingPlaceholder
            view.addSubview(firstPriceButton)
            view.addSubview(secondPriceButton)
            view.addSubview(thirdPriceButton)
            commentButton.layer.borderWidth = 0
            giftButton.layer.borderWidth = 0.5
        }
    }
    
    lazy var commentButton: UIButton = {
        let commentButton = UIButton(frame: CGRect(x: 10, y: K_SCREEN_HEIGHT - 70 - YOffset + 36, width: 85, height: 31))
        commentButton.backgroundColor = .clear
        commentButton.layer.borderColor = bubbleBorderColor
        commentButton.setTitle(Messages.commentButtonText, for: .normal)
        commentButton.setTitleColor(.white, for: .normal)
        commentButton.layer.cornerRadius = 10
        commentButton.titleLabel!.font = Fonts.giftCommentButtonFont
        commentButton.addTarget(self, action: #selector(commentButtonClick), for: .touchUpInside)
        return commentButton
    }()
    
    @objc func commentButtonClick() {
        if gift{
            gift = false
            commentButton.layer.borderWidth = 0.5
            giftButton.layer.borderWidth = 0
            textInputBar.placeholder = Messages.commentingPlaceholder
            firstPriceButton.removeFromSuperview()
            secondPriceButton.removeFromSuperview()
            thirdPriceButton.removeFromSuperview()
        }
    }
    
    lazy var firstPriceButton : UIButton = {
        let firstButton = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - widthOffset - 16, y: K_SCREEN_HEIGHT - 70 - YOffset, width: 34, height: 20))
        firstButton.backgroundColor = .clear
        firstButton.layer.borderColor = bubbleBorderColor
        firstButton.setTitle("$" + String(Pricing.firstPrice), for: .normal)
        firstButton.setTitleColor(.white, for: .normal)
        firstButton.layer.cornerRadius = 10
        firstButton.titleLabel!.font = Fonts.priceButtonFont
        firstButton.addTarget(self, action: #selector(firstPriceButtonClick), for: .touchUpInside)
        return firstButton
    }()
    
    @objc func firstPriceButtonClick() {
        if giftValue != Pricing.firstPrice {
            firstPriceButton.layer.borderWidth = 0.5
            secondPriceButton.layer.borderWidth = 0
            thirdPriceButton.layer.borderWidth = 0
            giftValue = Pricing.firstPrice
        }
    }
    
    lazy var secondPriceButton : UIButton = {
        let secondButton = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - widthOffset - 16, y: K_SCREEN_HEIGHT - 70 - YOffset + 25, width: 34, height: 20))
        secondButton.backgroundColor = .clear
        secondButton.layer.borderColor = bubbleBorderColor
        secondButton.layer.borderWidth = 0.5
        secondButton.setTitle("$" + String(Pricing.secondPrice), for: .normal)
        secondButton.setTitleColor(.white, for: .normal)
        secondButton.layer.cornerRadius = 10
        secondButton.titleLabel!.font = Fonts.priceButtonFont
        secondButton.addTarget(self, action: #selector(secondPriceButtonClick), for: .touchUpInside)
        return secondButton
    }()
    
    @objc func secondPriceButtonClick() {
        if giftValue != Pricing.secondPrice {
            firstPriceButton.layer.borderWidth = 0
            secondPriceButton.layer.borderWidth = 0.5
            thirdPriceButton.layer.borderWidth = 0
            giftValue = Pricing.secondPrice
        }
    }
    
    lazy var thirdPriceButton : UIButton = {
        let thirdButton = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - widthOffset - 16, y: K_SCREEN_HEIGHT - 70 - YOffset + 50, width: 34, height: 20))
        thirdButton.backgroundColor = .clear
        thirdButton.layer.borderColor = bubbleBorderColor
        thirdButton.setTitle("$" + String(Pricing.thirdPrice), for: .normal)
        thirdButton.setTitleColor(.white, for: .normal)
        thirdButton.layer.cornerRadius = 10
        thirdButton.titleLabel!.font = Fonts.priceButtonFont
        thirdButton.addTarget(self, action: #selector(thirdPriceButtonClick), for: .touchUpInside)
        return thirdButton
    }()
    
    @objc func thirdPriceButtonClick() {
        if giftValue != Pricing.thirdPrice {
            firstPriceButton.layer.borderWidth = 0
            secondPriceButton.layer.borderWidth = 0
            thirdPriceButton.layer.borderWidth = 0.5
            giftValue = Pricing.thirdPrice
        }
    }
    
    lazy var submitButton : UIButton = {
        let submitButton = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - widthOffset - 15 + 33 + 8, y: K_SCREEN_HEIGHT - 70 - YOffset + 12.5, width: 45, height: 45))
        submitButton.setImage(UIImage(named: "forward_arrow"), for: .normal)
        submitButton.layer.cornerRadius = 10
        submitButton.layer.masksToBounds = true
        submitButton.addTarget(self, action: #selector(submitButtonClick), for: .touchUpInside)
        return submitButton
    }()
    
    @objc func submitButtonClick(){
        textInput = textInputBar.text!
        textInputBar.text = ""
        resizeTextDownward(textInputBar)
        textInputBar.resignFirstResponder()
        let user = LoginTools.sharedTools.userInfo()
        debugPrint((gift ? "Gift" : "Comment") + " submitted")
        if gift {
            print(availableProducts)
            if !inAppPurchasesObserver!.isAuthorizedForPayments {
                liveAlert(title: ToUser.unauthorizedTitle, message: ToUser.unauthorizedMessage)
            } else if(giftValue == Pricing.firstPrice){
                if inAppPurchasesObserver != nil {
                    inAppPurchasesObserver!.buy(availableProducts![Messages.firstPriceGiftProductId]!)
                } else {
                    debugPrint("inAppPurchasesObserver closed, in-app purchases disabled.")
                }
            } else if giftValue == Pricing.secondPrice {
                if inAppPurchasesObserver != nil {
                    inAppPurchasesObserver!.buy(availableProducts![Messages.secondPriceGiftProductId]!)
                } else {
                    debugPrint("inAppPurchasesObserver closed, in-app purchases disabled.")
                }
            } else /* if giftValue == 15*/ {
                if inAppPurchasesObserver != nil {
                    inAppPurchasesObserver!.buy(availableProducts![Messages.thirdPriceGiftProductId]!)
                } else {
                    debugPrint("inAppPurchasesObserver closed, in-app purchases disabled.")
                }
            }
        } else {
            StreamingBackend.stream.logComment(name: user.firstName! + " " + user.lastName!, msg: textInput)
        }
    }
    
    //in-app purchases helpers
    
    func fetchProductInformation(productIds : [String]) {
        if inAppPurchasesObserver!.isAuthorizedForPayments {
            productRequest = SKProductsRequest(productIdentifiers: Set(productIds))
            productRequest.delegate = self
            productRequest.start()
        } else {
            liveAlert(title: ToUser.unauthorizedTitle, message: ToUser.unauthorizedMessage)
        }
    }
    
    // dare bubble factory
    
    func createDareBubble(gift: Gift){
        //94
        let msg = gift.gifterFullName! + ": " + gift.giftText!
        let value = gift.giftValue!
        var bubble = UIView(frame: CGRect(x: 200, y: K_SAFEAREA_TOP_HEIGHT() + 36 + 12, width: 173, height: 47))
        bubble.layer.cornerRadius = 20
        bubble.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        //bubble.layer.borderWidth = 0.5
        
        let layer0 = CAGradientLayer()
        layer0.colors = [
            UIColor(red: 148/255, green: 0/255, blue: 211/255, alpha: 1).cgColor,
        UIColor(red: 148/255, green: 0/255, blue: 211/255, alpha: 0.3).cgColor
        ]
        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 192/K_SCREEN_WIDTH, b: 0, c: 0, d: 410/K_SCREEN_HEIGHT, tx: 87, ty: 23))
        layer0.bounds = bubble.bounds.insetBy(dx: -0.5*bubble.bounds.size.width, dy: -0.5*bubble.bounds.size.height)
        layer0.cornerRadius = 40
        bubble.layer.addSublayer(layer0)
        
        var msgLabel = UILabel(frame: CGRect(x: 10, y: 3, width: 114, height: 36))
        msgLabel.textColor = .white
        msgLabel.font = UIFont(name: "Inter-Bold", size: 11)
        msgLabel.lineBreakMode = .byWordWrapping
        msgLabel.numberOfLines = 0
        msgLabel.text = msg
        bubble.addSubview(msgLabel)
        
        var priceLabel = UILabel(frame: CGRect(x: 10 + 114 + 3, y: 0, width: 41, height: 46))
        priceLabel.textColor = Colors.darePriceLabel
        priceLabel.font = UIFont(name: "Inter-Bold", size: 22)
        priceLabel.text = "$" + String(value)
        bubble.addSubview(priceLabel)
        
        updateDareBubbles(newBubble: bubble)
    }
    
    func updateDareBubbles(newBubble: UIView){
        let yShift = 47 + 12
        if dareBubbles?.count == 3 {
            dareBubbles?[0].removeFromSuperview()
            dareBubbles?.removeFirst()
            for element in dareBubbles! {
                element.frame = CGRect(x: 200, y: Int(element.frame.minY) - yShift, width: 173, height: 47)
            }
        }
        
        let newY = (dareBubbles?.count ?? 0) * yShift
        
        newBubble.frame = CGRect(x: 200, y: Int(K_SAFEAREA_TOP_HEIGHT()) + 36 + 12 + newY, width: 173, height: 47)
        
        dareBubbles?.append(newBubble)
        self.view.addSubview(newBubble)
    }
    
    //comment text factory
    func createCommentLabel(comment: Comment) {
        var commentLabel = UILabel(frame: CGRect(x: 20, y: K_SCREEN_HEIGHT - 70 - 25 - (isEditing ? YOffset : 0), width: K_SCREEN_WIDTH - 40, height: 15))
        commentLabel.textColor = .white
        commentLabel.font = Fonts.commentDisplayFont
        commentLabel.text = comment.commenterFullName! + ": " +  comment.commentText!
        updateComments(newComment: commentLabel)
    }
    
    func createJoinerLabel(streamView: StreamView) {
        numViewers += 1
        lookBtn.setTitle(String(numViewers), for: .normal)
        StreamingBackend.stream.getUserById(id: streamView.userId, handler: createJoinerLabel)
        
    }
    
    func createJoinerLabel(user: User) {
        DispatchQueue.main.async {
            var joinLabel = UILabel(frame: CGRect(x: 20, y: K_SCREEN_HEIGHT - 70 - 25 - (self.isEditing ? self.YOffset : 0), width: K_SCREEN_WIDTH - 40, height: 15))
            joinLabel.textColor = .white
            joinLabel.font = Fonts.commentDisplayFont
            let firstName = user.firstName ?? "John"
            let lastName = user.lastName ?? "Doe"
            joinLabel.text =  firstName + " " + lastName + " joined"
            self.updateComments(newComment: joinLabel)
        }
    }
    
    func updateComments(newComment: UILabel){
        let yShift = 15 + 5
        if comments?.count == 3 {
            comments?[0].removeFromSuperview()
            comments?.removeFirst()
        }
        for element in comments! {
            element.frame = CGRect(x: 20, y: Int(element.frame.minY) - yShift, width: Int(K_SCREEN_WIDTH) - 40, height: 15)
        }
        comments?.append(newComment)
        self.view.addSubview(newComment)
    }
    
    // function to create alerts
    func liveAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                   style: .default, handler: nil)
        alertController.addAction(action)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
}

// text input delegate

extension LiveViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resizeTextDownward(textField)
        debugPrint("Text editing ended")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        resizeTextUpward(textField)
        debugPrint("Text editing began")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        resizeTextDownward(textField)
        print("ended")
    }
    
}

extension LiveViewController: StoreObserverDelegate {
    func storeObserverDidReceiveMessage(_ message: String) {
        liveAlert(title: ToUser.unsuccessfulPurchase, message: message)
    }
    
    func storeObserverRestoreDidSucceed() {
    }
    
    func successfulPurchase() {
        let user = LoginTools.sharedTools.userInfo()
        StreamingBackend.stream.logGift( gifterId: user.id, value: giftValue, msg: textInput, gifterName: user.firstName!)
    }
}


/// Extends StoreManager to conform to SKProductsRequestDelegate.
extension LiveViewController: SKProductsRequestDelegate {
    /// Use this to get the App Store's response to your request and notify your observer.
    /// - Tag: ProductRequest
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        // Contains products with identifiers that the App Store recognizes. As such, they are available for purchase.
        if !response.products.isEmpty {
            for product in response.products {
                availableProducts?[product.productIdentifier] = product
            }
        }
        
        // invalidProductIdentifiers contains all product identifiers that the App Store doesn’t recognize.
        if !response.invalidProductIdentifiers.isEmpty {
            for invalidProduct in response.invalidProductIdentifiers {
                print("invalid product id:", invalidProduct)
            }
        }
        
        /*if !availableProducts.isEmpty {
            storeResponse.append(Section(type: .availableProducts, elements: availableProducts))
        }*/
    }
}
/*
/// Extends StoreManager to conform to SKRequestDelegate.
extension StoreManager: SKRequestDelegate {
    /// The system calls this when the product request fails.
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.delegate?.storeManagerDidReceiveMessage(error.localizedDescription)
        }
    }
}
*/

extension LiveViewController : WKNavigationDelegate {
    
}
