// swiftlint:disable all
import Amplify
import Foundation

extension Message {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case content
    case date
    case recipient_email
    case recipient_name
    case sender_name
    case sender_email
    case is_read
    case type
    case conversationID
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let message = Message.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "Messages"
    
    model.attributes(
      .index(fields: ["conversationID"], name: "byConversation")
    )
    
    model.fields(
      .id(),
      .field(message.content, is: .required, ofType: .string),
      .field(message.date, is: .required, ofType: .string),
      .field(message.recipient_email, is: .required, ofType: .string),
      .field(message.recipient_name, is: .required, ofType: .string),
      .field(message.sender_name, is: .required, ofType: .string),
      .field(message.sender_email, is: .required, ofType: .string),
      .field(message.is_read, is: .required, ofType: .bool),
      .field(message.type, is: .required, ofType: .enum(type: MesKind.self)),
      .field(message.conversationID, is: .optional, ofType: .string),
      .field(message.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(message.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}