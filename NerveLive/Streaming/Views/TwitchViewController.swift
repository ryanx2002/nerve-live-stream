//
//  TwitchViewController.swift
//  NerveLive
//
//  Created by Matthew Chen on 12/28/23.
//

import Foundation
import UIKit
import WebKit

class TwitchViewController : BaseViewController {
    
    let url = URL(string: "https://player.twitch.tv/?channel=asianjeff&parent=quest-livestream")!
    var frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let twitch = createViewer()
        view.addSubview(twitch)
    }
    
    func createViewer() -> WKWebView {
        // Initialize a WKWebViewConfiguration object.
        let webViewConfiguration = WKWebViewConfiguration()
        // Let HTML videos with a "playsinline" attribute play inline.
        webViewConfiguration.allowsInlineMediaPlayback = true
        // Let HTML videos with an "autoplay" attribute play automatically.
        webViewConfiguration.mediaTypesRequiringUserActionForPlayback = []
        
        let wkwebView = WKWebView(frame: frame, configuration: webViewConfiguration)
        let request = URLRequest(url: url)
        wkwebView.load(request)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
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
                    print(result)
                } else {
                    print(error)
                }
            }
        }
        return wkwebView
    }
    
    func updateUIView(_ uiView: WKWebView) {
    }
    
}
