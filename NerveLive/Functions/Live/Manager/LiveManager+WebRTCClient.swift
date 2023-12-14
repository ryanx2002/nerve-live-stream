//
//  LiveManager+WebRTCClient.swift
//  NerveLive
//
//  Created by wbx on 13/12/2023.
//

import Foundation
import WebRTC

extension LiveManager: WebRTCClientDelegate {
    func webRTCClient(_: WebRTCClient, didGenerate candidate: RTCIceCandidate) {
        print("Generated local candidate")
        setRemoteSenderClientId()
        signalingClient?.sendIceCandidate(rtcIceCandidate: candidate, master: isMaster,
                                          recipientClientId: remoteSenderClientId!,
                                          senderClientId: localSenderId)
    }

    func webRTCClient(_: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        switch state {
        case .connected, .completed:
            print("WebRTC connected/completed state")
        case .disconnected:
            print("WebRTC disconnected state")
        case .new:
            print("WebRTC new state")
        case .checking:
            print("WebRTC checking state")
        case .failed:
            print("WebRTC failed state")
        case .closed:
            print("WebRTC closed state")
        case .count:
            print("WebRTC count state")
        @unknown default:
            print("WebRTC unknown state")
        }
    }

    func webRTCClient(_: WebRTCClient, didReceiveData _: Data) {
        print("Received local data")
    }
}
