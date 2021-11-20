// swiftlint:disable all
import Amplify
import Foundation

public struct User: Model {
  public let id: String
  public var first_name: String
  public var last_name: String
  public var LatestMessages: List<LatestMessage>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      first_name: String,
      last_name: String,
      LatestMessages: List<LatestMessage>? = []) {
    self.init(id: id,
      first_name: first_name,
      last_name: last_name,
      LatestMessages: LatestMessages,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      first_name: String,
      last_name: String,
      LatestMessages: List<LatestMessage>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.first_name = first_name
      self.last_name = last_name
      self.LatestMessages = LatestMessages
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}