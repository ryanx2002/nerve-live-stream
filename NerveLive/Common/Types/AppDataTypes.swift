//
//  AppDataTypes.swift
//  NerveLive
//
//  Created by Matthew Chen on 12/26/23.
//

import Foundation
import UIKit

struct Pricing {
    static let firstPrice = 3
    static let secondPrice = 7
    static let thirdPrice = 15
}

struct Fonts {
    static let priceButtonFont = UIFont(name: "Inter-Regular",size: 12)
    static let giftCommentButtonFont = UIFont(name: "Inter-Regular",size: 16)
    static let commentDisplayFont = UIFont(name: "Inter-Regular",size: 12)
}

struct Messages {
    
    // general
    
    static let emptyString = ""
    
    static let giftButtonText = "Gift"
    static let commentButtonText = "Comment"
    
    // productIds
    
    static let firstPriceGiftProductId = "FirstPriceGift"
    static let secondPriceGiftProductId = "SecondPriceGift"
    static let thirdPriceGiftProductId = "ThirdPriceGift"
    
    // TextInputBar
    
    static let unselectedPlaceholder = "Gift / Comment"
    static let giftingPlaceholder = "Add a note to your gift"
    static let commentingPlaceholder = "Add a comment"
}

struct ToUser {
    static let unsuccessfulPurchase = "Purchase Unsuccessful"
    static let unauthorizedTitle = "You don’t have authorization to make payments"
    static let unauthorizedMessage = "There may be restrictions on your device for in-app purchases"
}

struct Colors {
    static let CGWhite = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    static let darePriceLabel = UIColor(red: 0, green: 1, blue: 0.16, alpha: 1)
}

struct LiveViewCoordinates {
    static let leftmostX = 16
    static let textBoxYAboveBottomScreen = 70
}
