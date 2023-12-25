// swiftlint:disable all
import Amplify
import Foundation

extension Stream {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case endTime
    case createdAt
    case updatedAt
    case userStreamsId
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let stream = Stream.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Streams"
    model.syncPluralName = "Streams"
    
    model.attributes(
      .index(fields: ["id"], name: nil)
    )
    
    model.fields(
      .field(stream.id, is: .required, ofType: .string),
      .field(stream.endTime, is: .optional, ofType: .dateTime),
      .field(stream.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(stream.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(stream.userStreamsId, is: .optional, ofType: .string)
    )
    }
}
