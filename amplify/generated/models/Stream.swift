// swiftlint:disable all
import Amplify
import Foundation

public struct Stream: Model {
  public let id: String
  public var endTime: Temporal.DateTime?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  public var userStreamsId: String?
  
  public init(id: String = UUID().uuidString,
      endTime: Temporal.DateTime? = nil,
      userStreamsId: String? = nil) {
    self.init(id: id,
      endTime: endTime,
      createdAt: nil,
      updatedAt: nil,
      userStreamsId: userStreamsId)
  }
  internal init(id: String = UUID().uuidString,
      endTime: Temporal.DateTime? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil,
      userStreamsId: String? = nil) {
      self.id = id
      self.endTime = endTime
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.userStreamsId = userStreamsId
  }
}