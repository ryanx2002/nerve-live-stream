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
    
//    model.attributes(
//      .primaryKey(fields: [user.id])
//    )
    
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
      .field(user.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(user.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

//extension User: ModelIdentifiable {
//  public typealias IdentifierFormat = ModelIdentifierFormat.Default
//  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
//}
