// swiftlint:disable all
import Amplify
import Foundation

public struct User: Model {
  public let id: String
  public var firstName: String?
  public var lastName: String?
  public var email: String?
  public var phone: String?
  public var profilePhoto: String?
  public var deviceToken: String?
  public var venmo: String?
  public var isMaster: Bool?
  public var isLive: Bool?
  public var streams: List<Stream>?
  public var views: List<StreamView>?
  public var gifts: List<Gift>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      firstName: String? = nil,
      lastName: String? = nil,
      email: String? = nil,
      phone: String? = nil,
      profilePhoto: String? = nil,
      deviceToken: String? = nil,
      venmo: String? = nil,
      isMaster: Bool? = nil,
      isLive: Bool? = nil,
      streams: List<Stream>? = [],
      views: List<StreamView>? = [],
      gifts: List<Gift>? = []) {
    self.init(id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      profilePhoto: profilePhoto,
      deviceToken: deviceToken,
      venmo: venmo,
      isMaster: isMaster,
      isLive: isLive,
      streams: streams,
      views: views,
      gifts: gifts,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      firstName: String? = nil,
      lastName: String? = nil,
      email: String? = nil,
      phone: String? = nil,
      profilePhoto: String? = nil,
      deviceToken: String? = nil,
      venmo: String? = nil,
      isMaster: Bool? = nil,
      isLive: Bool? = nil,
      streams: List<Stream>? = [],
      views: List<StreamView>? = [],
      gifts: List<Gift>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.firstName = firstName
      self.lastName = lastName
      self.email = email
      self.phone = phone
      self.profilePhoto = profilePhoto
      self.deviceToken = deviceToken
      self.venmo = venmo
      self.isMaster = isMaster
      self.isLive = isLive
      self.streams = streams
      self.views = views
      self.gifts = gifts
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}