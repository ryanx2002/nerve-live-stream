//
//  StreamingBackend.swift
//  NerveLive
//
//  Created by Matthew Chen on 12/24/23.
//

import Foundation
import UIKit
import AWSPluginsCore
import Amplify

class StreamingBackend : NSObject {
    static let stream = StreamingBackend()
    private override init() {
        
    }
    
    func getUserById(id: String, handler: @escaping (User) -> Void) {
        Amplify.API.query(request: .get(User.self, byId: id)) { event in
              switch event {
              case .success(let result):
                  switch result {
                  case .success(let user):
                      guard let res = user else {
                          print("Could not find User")
                          return
                      }
                      print("Successfully retrieved User: \(res)")
                      handler(res)
                  case .failure(let error):
                      print("Got failed result with \(error.errorDescription)")
                  }
              case .failure(let error):
                  print("Got failed event with error \(error)")
              }
          }
    }
    
    func createStream(streamerId : String) -> String {
        let stream = Stream(userStreamsId: streamerId)
        Amplify.API.mutate(request: .create(stream)){
            event in
            switch event {
            case .success(let result):
                switch result {
                case  .success(_):
                    debugPrint("Success logging stream, streamerId : " + streamerId)
                case .failure(let error):
                    debugPrint("Error logging stream: \(error.errorDescription)")
                }
            case .failure(let error):
                debugPrint("Failed to log stream: \(error)")
            }
        }
        return stream.id
    }
    
    /*
    func getCurrentStreamId() -> List<Stream>? {
        var res : List<Stream>?
        Amplify.API.query(request: .paginatedList(Stream.self)) {
            event in
            switch event {
            case .success(let result):
                switch result {
                case  .success(let streams):
                    debugPrint("Success getting stream")
                    res = streams
                case .failure(let error):
                    debugPrint("Error getting stream: \(error.errorDescription)")
                }
            case .failure(let error):
                debugPrint("Failed to get stream: \(error)")
            }
        }
        return res
    }*/
    
    func getCurrentStreamId2(suc: @escaping (_ streams: [Stream]) -> Void) {
        Amplify.API.query(request: .queryStreamList()) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    guard let postData = try? JSONEncoder().encode(data) else {
                        print("Failed 1")
                        return
                    }
                    guard  let d = try? JSONSerialization.jsonObject(with: postData, options: .mutableContainers) else {
                        print("Failed 2")
                        return
                    }
                    let dic = d as! NSDictionary
                    if let subDic = dic["listStreams"] as? NSDictionary {
                        if let items: NSArray = subDic.object(forKey: "items") as? NSArray {
                            let list = [Stream].deserialize(from: items) ?? []
                            suc(list)
                        } else {
                            print("Failed 3")
                        }
                    } else {
                        print("Failed 4")
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    print("\(error.errorDescription)")
                }
            case .failure(let error):
                print("\(error)")
            }
        }
    }
    
    func getCurrentStreamViews(suc: @escaping (_ streams: [StreamView]) -> Void) {
        Amplify.API.query(request: .queryStreamViewList()) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    guard let postData = try? JSONEncoder().encode(data) else {
                        print("Failed 1")
                        return
                    }
                    guard  let d = try? JSONSerialization.jsonObject(with: postData, options: .mutableContainers) else {
                        print("Failed 2")
                        return
                    }
                    let dic = d as! NSDictionary
                    if let subDic = dic["listStreamViews"] as? NSDictionary {
                        if let items: NSArray = subDic.object(forKey: "items") as? NSArray {
                            let list = [StreamView].deserialize(from: items) ?? []
                            suc(list)
                        } else {
                            print("Failed 3")
                        }
                    } else {
                        print("Failed 4")
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    print("\(error.errorDescription)")
                }
            case .failure(let error):
                print("epic fail: \(error)")
            }
        }
    }
    
    func finishStream(currStreamId : String, streamerId : String) {
        let stream = Stream(id: currStreamId, endTime: .now(), userStreamsId: streamerId)
        Amplify.API.mutate(request: .update(stream)){
            event in
            switch event {
            case .success(let result):
                switch result {
                case  .success(_):
                    debugPrint("Success updating stream")
                case .failure(let error):
                    debugPrint("Error updating stream: \(error.errorDescription)")
                }
            case .failure(let error):
                debugPrint("Failed to update stream: \(error)")
            }
        }
    }
    
    func startStreamView(streamId: String, userId: String) {
        let streamView = StreamView(userId: userId, streamId: streamId, sessions: 1, userViewsId: userId )
        Amplify.API.mutate(request: .create(streamView)){
            event in
            switch event {
            case .success(let result):
                switch result {
                case  .success(_):
                    debugPrint("Success logging StreamView")
                case .failure(let error):
                    debugPrint("Error logging StreamView: \(error.errorDescription)")
                }
            case .failure(let error):
                debugPrint("Failed to log StreamView: \(error)")
            }
        }
    }
    
    func createGiftFromUser(gifterId: String) -> Gift {
        return Gift(userGiftsId: gifterId)
    }
    
    func logGift(gifterId: String, value: Int, msg: String, gifterName: String) {
        var gift = createGiftFromUser(gifterId: gifterId)
        gift.giftValue = value
        gift.giftText = msg
        gift.gifterFullName = gifterName
        
        Amplify.API.mutate(request: .create(gift)){
            event in
            switch event {
            case .success(let result):
                switch result {
                case  .success(_):
                    debugPrint("Success logging gift")
                case .failure(let error):
                    debugPrint("Error logging gift: \(error.errorDescription)")
                }
            case .failure(let error):
                debugPrint("Failed to log gift: \(error)")
            }
        }
    }
    
    func logComment(name: String, msg: String) {
        let comment = Comment(commenterFullName: name, commentText: msg)
        
        Amplify.API.mutate(request: .create(comment)){
            event in
            switch event {
            case .success(let result):
                switch result {
                case  .success(_):
                    debugPrint("Success logging comment")
                case .failure(let error):
                    debugPrint("Error logging comment: \(error.errorDescription)")
                }
            case .failure(let error):
                debugPrint("Failed to log comment: \(error)")
            }

        }
    }
}
