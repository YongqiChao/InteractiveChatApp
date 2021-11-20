// swiftlint:disable all
import Amplify
import Foundation

public struct Conversation: Model {
  public let id: String
  public var Messages: List<Message>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      Messages: List<Message>? = []) {
    self.init(id: id,
      Messages: Messages,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      Messages: List<Message>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.Messages = Messages
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}