// swiftlint:disable all
import Amplify
import Foundation

extension Conversation {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case Messages
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let conversation = Conversation.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "Conversations"
    
    model.fields(
      .id(),
      .hasMany(conversation.Messages, is: .optional, ofType: Message.self, associatedWith: Message.keys.conversationID),
      .field(conversation.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(conversation.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}