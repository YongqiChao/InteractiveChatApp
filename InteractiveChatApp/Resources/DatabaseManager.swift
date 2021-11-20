//
//  DatabaseManager.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/12/21.
//

import Foundation
import Amplify
import AWSPluginsCore
import AmplifyPlugins
import Combine

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "+")
        safeEmail = safeEmail.replacingOccurrences(of: "[", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "]", with: "-")
        return safeEmail
    }
    
    public enum DatabaseErrors: Error {
        case failedToFetchUsers
    }
    
}

extension DatabaseManager {

//    public func userExists(with email: String,
//                           completion: @escaping ((Bool) -> Void)) {
//        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
//        database.child(safeEmail).observeSingleEvent(of: .value,
//                                                     with: { snapshot in
//            guard snapshot.exists() else {
//                completion(false)
//                return
//            }
//            completion(true)
//        })
//    }
//
//    public func getDataFor(path: String,
//                           completion : @escaping (Result<Any, Error>) -> Void) {
//        self.database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value else {
//                completion(.failure(DatabaseErrors.failedToFetchUsers))
//                return
//            }
//            completion(.success(value))
//        }
//    }

}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress : String

    var safeEmail : String {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: emailAddress)
        return safeEmail
    }

    var profilePictureName : String {
        return "\(safeEmail)_profile_picture.png"
    }
}


// MARK: - READ Operations

extension DatabaseManager {
    
    public func getAllMessages(for conversationId: String,
                               completion : @escaping (Result<[DisplayMessage],
                                                       Error>) -> Void )  {
        var targetMessages : [DisplayMessage] = []
        _ = Amplify.DataStore.query(Conversation.self, byId: conversationId)
            .compactMap { $0?.Messages }
            .flatMap { $0.loadAsPublisher() }
            .sink {
                if case let .failure(error) = $0 {
                    print("Error retrieving post \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            receiveValue: {
                for message in $0 {
                    // add recipient photo here 
                    let sender = Sender(senderId: message.sender_email,
                                        displayName: message.sender_name,
                                        photoURL: "")
                    guard let date = ChatViewController.dateFormatter.date(from: message.date) else {
                        return
                    }
                    targetMessages.append(DisplayMessage(messageId: message.id,
                                                         sentDate: date ,
                                                         kind: .text(message.content),
                                                         sender: sender))
                }
                completion(.success(targetMessages))
            }
    }
    
    public func getAllLatestMessages(for userId : String,
                                     completion : @escaping (Result<[LatestMessage],
                                                             Error>) -> Void )  {
        var targetLatestMessages : [LatestMessage] = []
        _ = Amplify.DataStore.query(User.self, byId: userId)
            .compactMap { $0?.LatestMessages }
            .flatMap { $0.loadAsPublisher() }
            .sink {
                if case let .failure(error) = $0 {
                    print("Error retrieving post \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            receiveValue: {
                for message in $0 {
                    targetLatestMessages.append(message)
                }
                completion(.success(targetLatestMessages))
            }
    }
    
    public func getAllUsers(completion : @escaping (Result<[User],
                                                    Error>) -> Void )  {
        var targetUsers : [User] = []
        _ = Amplify.DataStore.query(User.self)
            .sink {
                if case let .failure(error) = $0 {
                    print("Error retrieving post \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            receiveValue: {
                for user in $0 {
                    targetUsers.append(user)
                }
                completion(.success(targetUsers))
            }
    }
    
    public func getUser(for userId : String,
                        completion : @escaping (Result<User,
                                                    Error>) -> Void )  {
        _ = Amplify.DataStore.query(User.self, byId: userId)
            .sink {
                if case let .failure(error) = $0 {
                    print("Error retrieving post \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            receiveValue: { user in
                guard let returnUser = user else {
                    completion(.failure(DatabaseErrors.failedToFetchUsers))
                    return
                }
                completion(.success(returnUser))
            }
    }
    
    public func getConversation(for conversationId : String,
                                completion : @escaping (Result<Conversation,
                                                        Error>) -> Void )  {
        _ = Amplify.DataStore.query(Conversation.self, byId: conversationId)
            .sink {
                if case let .failure(error) = $0 {
                    print("Error retrieving post \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            receiveValue: { conver in
                guard let returnConver = conver else {
                    completion(.failure(DatabaseErrors.failedToFetchUsers))
                    return
                }
                completion(.success(returnConver))
            }
    }
    
}

// MARK: - Create / Update Operations

extension DatabaseManager {
    
    public func addUser(with user : User,
                        completion : @escaping (Bool) -> Void ) {
        Amplify.DataStore.save(user) { result in
            switch result {
            case .failure(let error):
                print("Error adding user - \(error.localizedDescription)")
                completion(false)
            case .success:
                print("User added!")
                completion(true)
            }
        }
    }
    
    public func addConversation(with conversationId : String,
                                completion : @escaping (Bool) -> Void ) {
        let newConversation = Conversation(id: conversationId, Messages: nil)
        Amplify.DataStore.save(newConversation) { result in
            switch result {
            case .failure(let error):
                print("Error adding new conversation - \(error.localizedDescription)")
                completion(false)
            case .success:
                print("Conversation added!")
                completion(true)
            }
        }
    }
    
    public func addLatestMessage(with latestMessage : LatestMessage,
                                completion : @escaping (Bool) -> Void ) {
        Amplify.DataStore.save(latestMessage) { result in
            switch result {
            case .failure(let error):
                print("Error adding latestMessage - \(error.localizedDescription)")
                completion(false)
            case .success:
                print("latestMessage added!")
                completion(true)
            }
        }
    }
    
    public func addMessage(with message : Message,
                           completion : @escaping (Bool) -> Void ) {
        Amplify.DataStore.save(message) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .failure(let error):
                print("Error adding new message - \(error.localizedDescription)")
                completion(false)
            case .success:
                print("Message added!")
                let latestSender = LatestMessage(id: "\(message.sender_email)_\(message.recipient_email)Latest",
                                                 date: message.date,
                                                 content: message.content,
                                                 is_read: message.is_read,
                                                 type: message.type,
                                                 recipient_name: message.recipient_name,
                                                 recipient_email: message.recipient_email,
                                                 sender_email: message.sender_email,
                                                 sender_name: message.sender_name,
                                                 userID: message.sender_email)
                let latestRecipient = LatestMessage(id: "\(message.recipient_email)_\(message.sender_email)Latest",
                                                 date: message.date,
                                                 content: message.content,
                                                 is_read: message.is_read,
                                                 type: message.type,
                                                 recipient_name: message.recipient_name,
                                                 recipient_email: message.recipient_email,
                                                 sender_email: message.sender_email,
                                                 sender_name: message.sender_name,
                                                 userID: message.recipient_email)
                strongSelf.addLatestMessage(with: latestSender,
                                 completion: { result in
                    switch result {
                    case false:
                        print("Error adding latest message ")
                        completion(false)
                    case true:
                        strongSelf.addLatestMessage(with: latestRecipient,
                                         completion: { result in
                            switch result {
                            case false:
                                print("Error adding latest message ")
                                completion(false)
                            case true:
                                completion(true)
                            }})
                    }})
            }
        }
    }
    
}
