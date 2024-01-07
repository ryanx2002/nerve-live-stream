//
//  AppDataTypes.swift
//  NerveLive
//
//  Created by Matthew Chen on 12/26/23.
//

import Foundation
import UIKit

struct Pricing {
    static let testing = 2
    static let firstPrice = 5
    static let secondPrice = 10
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
    static let testingProductId = "NineDollarGift"
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

struct FakeComments {
    static let users = ["Alice Adams", "Ben Biston", "Chloe Carter", "Dylan Davis", "Ethan Evans", "Fiona Foster", "George Green", "Hannah Hayes", "Isaac Ingram", "Jack Johnson", "Kat Kelly", "Liam Lewis", "Mike Mitchell", "Nate Newman", "Olivia Owens", "Pat Parker", "Rick Robinson", "Sam Smith", "Ty Tucker", "Victor Vaughn", "Will White"]
    static let comments = ["🤣🤣",
                           "💀",
                           "☠️",
                           "bruh this is hilarious",
                           "hi",
                           "yo",
                           "RYAN WHAT IS THIS",
                           "wtf",
                           "do a flip",
                           "do a backflip",
                           "Imma share this livestream",
                           "Can you npc stream",
                           "Yo Yo",
                           "Stream with Vanya",
                           "Mr Child Genius",
                           "kid genius",
                           "boi",
                           "BRUH",
                           "Go talk to that person",
                           "do the worm",
                           "WORM bro",
                           "U got this Ryan",
                           "lmao",
                           "lol",
                           "LMAOO",
                           "LOL",
                           "wsg Ry",
                           "This just keeps getting better",
                           "go back to Yale boi",
                           "I need the confidence he has",
                           "Are u still a genius?",
                           "I know your mom doesn’t approve of this bro",
                           "good stuff",
                           "ayo",
                           "How often do you stream",
                           "this is funny imma watch your next stream",
                           "Bro these are better than ur TikTok livestreams",
                           "I have an idea",
                           "yell something",
                           "dude you should dance",
                           "Ry can you say hello",
                           "Scream",
                           "Bark at someone",
                           "do the WAP dance",
                           "growl at people",
                           "This is awesome",
                           "hahaha",
                           "HAHA",
                           "skibidi toilet",
                           "fly to the moon",
                           "OMG",
                           "beat someone up",
                           "bro really wants the $5",
                           "honestly a pretty cheap price",
                           "throw a donut at someone",
                           "Bro wilding for five bucks",
                           "take ur shirt off",
                           "skull",
                           "i have monopoly money",
                           "take your pants off",
                           "This guy",
                           "yo this guy always comes thru",
                           "Hahhaha",
                           "That was great",
                           "you wild man",
                           "dude has no filter",
                           "where you at",
                           "Where are ya rn",
                           "LETS GO",
                           "thug shake",
                           "i have no lifeeee",
                           "yung blud",
                           "take ur top Off",
                           "Yessir",
                           "Slurpy durpy",
                           "climb a tree",
                           "sexmuffins",
                           "lesgo",
                           "sing a song",
                           "ayub",
                           "HEre we go",
                           "W",
                           "www",
                           "Guy is making history",
                           "homeboy is a real one",
                           "no wayy",
                           "This is wild",
                           "how much do you bench",
                           "dub dude",
                           "Smell someone’s feet",
                           "how was Ellen",
                           "Kid was on The ellen show",
                           "bro how can I stream on this",
                           "This dual cam is cool",
                           "Imma dare you to do something",
                           "moan in someone’s ear",
                           "Walk right in front of someone",
                           "go between someone’s legs",
                           "Rizz up a grandma",
                           "get a car to honk at you",
                           "Offer someone a lap dance",
                           "pole dance",
                           "howl like a wolf",
                           "wrestle someone",
                           "Ask a homeless guy to spank you",
                           "call someone a pookie",
                           "who else here from TikTok",
                           "Who’s here from YouTube?",
                           "uh...",
                           "fr",
                           "ain’t no way",
                           "Do this in front of your parents",
                           "You gotta post these lmao",
                           "this shi way better than TikTok",
                           "jajaja",
                           "Boy if you don’t",
                           "King",
                           "slay",
                           "keep it up man",
                           "Menace to society",
                           "this stuff is viral"]
}
