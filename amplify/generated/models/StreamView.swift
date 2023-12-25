// swiftlint:disable all
import Amplify
import Foundation

public struct StreamView: Model {
  public let id: String
  public var userId: String
  public var streamId: String
  public var endTime: Temporal.DateTime?
  public var sessions: Int
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  public var userViewsId: String?
  
  public init(id: String = UUID().uuidString,
      userId: String,
      streamId: String,
      endTime: Temporal.DateTime? = nil,
      sessions: Int,
      userViewsId: String? = nil) {
    self.init(id: id,
      userId: userId,
      streamId: streamId,
      endTime: endTime,
      sessions: sessions,
      createdAt: nil,
      updatedAt: nil,
      userViewsId: userViewsId)
  }
  internal init(id: String = UUID().uuidString,
      userId: String,
      streamId: String,
      endTime: Temporal.DateTime? = nil,
      sessions: Int,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil,
      userViewsId: String? = nil) {
      self.id = id
      self.userId = userId
      self.streamId = streamId
      self.endTime = endTime
      self.sessions = sessions
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.userViewsId = userViewsId
  }
}