// swiftlint:disable all
import Amplify
import Foundation

extension User {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case firstName
    case lastName
    case email
    case phone
    case profilePhoto
    case deviceToken
    case venmo
    case isMaster
    case isLive
    case streams
    case views
    case gifts
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let user = User.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Users"
    model.syncPluralName = "Users"
    
    model.attributes(
      .index(fields: ["id"], name: nil)
    )
    
    model.fields(
      .field(user.id, is: .required, ofType: .string),
      .field(user.firstName, is: .optional, ofType: .string),
      .field(user.lastName, is: .optional, ofType: .string),
      .field(user.email, is: .optional, ofType: .string),
      .field(user.phone, is: .optional, ofType: .string),
      .field(user.profilePhoto, is: .optional, ofType: .string),
      .field(user.deviceToken, is: .optional, ofType: .string),
      .field(user.venmo, is: .optional, ofType: .string),
      .field(user.isMaster, is: .optional, ofType: .bool),
      .field(user.isLive, is: .optional, ofType: .bool),
      .hasMany(user.streams, is: .optional, ofType: Stream.self, associatedWith: Stream.keys.userStreamsId),
      .hasMany(user.views, is: .optional, ofType: StreamView.self, associatedWith: StreamView.keys.userViewsId),
      .hasMany(user.gifts, is: .optional, ofType: Gift.self, associatedWith: Gift.keys.userGiftsId),
      .field(user.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(user.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}
