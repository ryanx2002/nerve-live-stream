// swiftlint:disable all
import Amplify
import Foundation

public struct Gift: Model {
  public let id: String
  public var streamId: String?
  public var giftValue: Int?
  public var giftText: String?
  public var fulfilled: Bool?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  public var userGiftsId: String?
  
  public init(id: String = UUID().uuidString,
      streamId: String? = nil,
      giftValue: Int? = nil,
      giftText: String? = nil,
      fulfilled: Bool? = nil,
      userGiftsId: String? = nil) {
    self.init(id: id,
      streamId: streamId,
      giftValue: giftValue,
      giftText: giftText,
      fulfilled: fulfilled,
      createdAt: nil,
      updatedAt: nil,
      userGiftsId: userGiftsId)
  }
  internal init(id: String = UUID().uuidString,
      streamId: String? = nil,
      giftValue: Int? = nil,
      giftText: String? = nil,
      fulfilled: Bool? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil,
      userGiftsId: String? = nil) {
      self.id = id
      self.streamId = streamId
      self.giftValue = giftValue
      self.giftText = giftText
      self.fulfilled = fulfilled
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.userGiftsId = userGiftsId
  }
}