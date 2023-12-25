// swiftlint:disable all
import Amplify
import Foundation

extension Comment {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case commenterFullName
    case commentText
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let comment = Comment.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Comments"
    model.syncPluralName = "Comments"
    
    model.attributes(
      .index(fields: ["id"], name: nil)
    )
    
    model.fields(
      .field(comment.id, is: .required, ofType: .string),
      .field(comment.commenterFullName, is: .optional, ofType: .string),
      .field(comment.commentText, is: .optional, ofType: .string),
      .field(comment.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(comment.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}
