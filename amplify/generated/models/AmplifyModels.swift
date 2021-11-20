// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "30a7a0d8fe6d67e3cd4de075db8e687d"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: LatestMessage.self)
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: Conversation.self)
    ModelRegistry.register(modelType: Message.self)
  }
}