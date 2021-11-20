// swiftlint:disable all
import Amplify
import Foundation

extension LatestMessage {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case date
    case content
    case is_read
    case type
    case recipient_name
    case recipient_email
    case sender_email
    case sender_name
    case userID
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let latestMessage = LatestMessage.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "LatestMessages"
    
    model.attributes(
      .index(fields: ["userID"], name: "byUser")
    )
    
    model.fields(
      .id(),
      .field(latestMessage.date, is: .required, ofType: .string),
      .field(latestMessage.content, is: .required, ofType: .string),
      .field(latestMessage.is_read, is: .required, ofType: .bool),
      .field(latestMessage.type, is: .required, ofType: .enum(type: MesKind.self)),
      .field(latestMessage.recipient_name, is: .required, ofType: .string),
      .field(latestMessage.recipient_email, is: .required, ofType: .string),
      .field(latestMessage.sender_email, is: .required, ofType: .string),
      .field(latestMessage.sender_name, is: .required, ofType: .string),
      .field(latestMessage.userID, is: .optional, ofType: .string),
      .field(latestMessage.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(latestMessage.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}