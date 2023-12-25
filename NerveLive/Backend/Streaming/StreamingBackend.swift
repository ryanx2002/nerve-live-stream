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
}
