// swiftlint:disable all
import Amplify
import Foundation

public struct Message: Model {
  public let id: String
  public var content: String
  public var date: String
  public var recipient_email: String
  public var recipient_name: String
  public var sender_name: String
  public var sender_email: String
  public var is_read: Bool
  public var type: MesKind
  public var conversationID: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      content: String,
      date: String,
      recipient_email: String,
      recipient_name: String,
      sender_name: String,
      sender_email: String,
      is_read: Bool,
      type: MesKind,
      conversationID: String? = nil) {
    self.init(id: id,
      content: content,
      date: date,
      recipient_email: recipient_email,
      recipient_name: recipient_name,
      sender_name: sender_name,
      sender_email: sender_email,
      is_read: is_read,
      type: type,
      conversationID: conversationID,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      content: String,
      date: String,
      recipient_email: String,
      recipient_name: String,
      sender_name: String,
      sender_email: String,
      is_read: Bool,
      type: MesKind,
      conversationID: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.content = content
      self.date = date
      self.recipient_email = recipient_email
      self.recipient_name = recipient_name
      self.sender_name = sender_name
      self.sender_email = sender_email
      self.is_read = is_read
      self.type = type
      self.conversationID = conversationID
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}