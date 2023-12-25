// swiftlint:disable all
import Amplify
import Foundation

public struct Comment: Model {
  public let id: String
  public var commenterFullName: String?
  public var commentText: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      commenterFullName: String? = nil,
      commentText: String? = nil) {
    self.init(id: id,
      commenterFullName: commenterFullName,
      commentText: commentText,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      commenterFullName: String? = nil,
      commentText: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.commenterFullName = commenterFullName
      self.commentText = commentText
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}