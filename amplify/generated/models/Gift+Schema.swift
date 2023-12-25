// swiftlint:disable all
import Amplify
import Foundation

extension Gift {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case streamId
    case giftValue
    case giftText
    case gifterFullName
    case fulfilled
    case createdAt
    case updatedAt
    case userGiftsId
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let gift = Gift.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Gifts"
    model.syncPluralName = "Gifts"
    
    model.attributes(
      .index(fields: ["id"], name: nil)
    )
    
    model.fields(
      .field(gift.id, is: .required, ofType: .string),
      .field(gift.streamId, is: .optional, ofType: .string),
      .field(gift.giftValue, is: .optional, ofType: .int),
      .field(gift.giftText, is: .optional, ofType: .string),
      .field(gift.gifterFullName, is: .optional, ofType: .string),
      .field(gift.fulfilled, is: .optional, ofType: .bool),
      .field(gift.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(gift.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(gift.userGiftsId, is: .optional, ofType: .string)
    )
    }
}
