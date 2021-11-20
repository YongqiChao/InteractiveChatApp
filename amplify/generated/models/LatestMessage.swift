// swiftlint:disable all
import Amplify
import Foundation

public struct LatestMessage: Model {
  public let id: String
  public var date: String
  public var content: String
  public var is_read: Bool
  public var type: MesKind
  public var recipient_name: String
  public var recipient_email: String
  public var sender_email: String
  public var sender_name: String
  public var userID: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      date: String,
      content: String,
      is_read: Bool,
      type: MesKind,
      recipient_name: String,
      recipient_email: String,
      sender_email: String,
      sender_name: String,
      userID: String? = nil) {
    self.init(id: id,
      date: date,
      content: content,
      is_read: is_read,
      type: type,
      recipient_name: recipient_name,
      recipient_email: recipient_email,
      sender_email: sender_email,
      sender_name: sender_name,
      userID: userID,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      date: String,
      content: String,
      is_read: Bool,
      type: MesKind,
      recipient_name: String,
      recipient_email: String,
      sender_email: String,
      sender_name: String,
      userID: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.date = date
      self.content = content
      self.is_read = is_read
      self.type = type
      self.recipient_name = recipient_name
      self.recipient_email = recipient_email
      self.sender_email = sender_email
      self.sender_name = sender_name
      self.userID = userID
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}