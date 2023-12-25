// swiftlint:disable all
import Amplify
import Foundation

extension StreamView {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userId
    case streamId
    case endTime
    case sessions
    case createdAt
    case updatedAt
    case userViewsId
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let streamView = StreamView.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "StreamViews"
    model.syncPluralName = "StreamViews"
    
    model.attributes(
      .index(fields: ["id"], name: nil)    )
    
    model.fields(
      .field(streamView.id, is: .required, ofType: .string),
      .field(streamView.userId, is: .required, ofType: .string),
      .field(streamView.streamId, is: .required, ofType: .string),
      .field(streamView.endTime, is: .optional, ofType: .dateTime),
      .field(streamView.sessions, is: .required, ofType: .int),
      .field(streamView.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(streamView.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(streamView.userViewsId, is: .optional, ofType: .string)
    )
    }
}
