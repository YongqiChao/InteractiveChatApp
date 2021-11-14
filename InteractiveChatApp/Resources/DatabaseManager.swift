//
//  DatabaseManager.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/12/21.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database(url: "https://interactivechatapp-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    //    Database.database().reference()
    
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
    
    public func insertUser(with user : ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName],
            withCompletionBlock: { error, _ in
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value,
                                                            with: { snapshot in
                if var usersCollection = snapshot.value as? [[String : String]] {
                    // append to local dictionary
                    let newUser = [ "name": user.firstName + " " + user.lastName,
                                    "email": user.safeEmail]
                    usersCollection.append(newUser)
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("append user colletion failed")
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                else {
                    //create new dictionary
                    let newUsersCollection : [[String:String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newUsersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("create user colletion failed")
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
        })
    }
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value,
                                                     with: { snapshot in
            guard snapshot.exists() else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    public func fetchAllUsers(completion : @escaping (Result<[[String:String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value,
                                                   with:  { snapshot in
            guard let value = snapshot.value as? [[String : String]] else {
                completion(.failure(DatabaseErrors.failedToFetchUsers))
                return
            }
            completion(.success(value))
        })
    }
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


extension DatabaseManager {
    // user => [["name" : data, "safeEmail" : data]]
    // conversation => [["conversationId" : data, "other_user_email" : data, "other_user_name" : string
    //                   "latestMessage : => { "date" : Date(), "latestMessage" : data, "is_read" : true/false}]]
    // conversation id => { "messages" [ { "id" : String, "type" : text/photo/video, "content": String/byte,
    //                       "date": Date(), "senderEmail": String, "isRead": boolean, "other_user_name" : string} ] }
    public func createNewConversation(with otherUserEmail: String,
                                      otherUserName : String,
                                      firstMessage : Message,
                                      completion : @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode = snapshot.value as? [String : Any] else {
                print("\(safeEmail)_\(otherUserName)_\(otherUserName)")
                print("user not found")
                completion(false)
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let text):
                message = text
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            // latest message == a breif message from recent conversation
            let conversationID = "conversation_\(firstMessage.messageId)"
            let newConversation: [String: Any] = [
                "id" : conversationID,
                "other_user_email": otherUserEmail,
                "other_user_name" : otherUserName,
                "latest_message": [
                    "date" : dateString,
                    "message" : message,
                    "is_read" : false
                ]
            ]
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // append new conversation
                conversations.append(newConversation)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error , _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                     otherUserName: otherUserName,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
            else {
                //create new conversations dictionary
                userNode["conversations"] = [
                    newConversation
                ]
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                     otherUserName: otherUserName,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
        })
    }
    
    public func getAllConversations(for email: String,
                                     completion : @escaping (Result<String, Error>) -> Void ) {
        
    }
    
    public func getAllMessagesForConversation(with id: String,
                                              completion : @escaping (Result<String, Error>) -> Void ) {
        
    }
    
    public func sendMessage(to conversation : String,
                            message : Message,
                            completion : @escaping (Bool) -> Void) {
        
    }
    
    private func finishCreatingConversation(conversationID : String,
                                            otherUserName : String,
                                            firstMessage: Message,
                                            completion : @escaping (Bool) -> Void ) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        var message = ""
        
        switch firstMessage.kind {
        case .text(let text):
            message = text
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        let messages : [String : Any] = [
            "id" :  firstMessage.messageId,
            "type": firstMessage.kind.rawData,
            "content" : message,
            "date" : dateString,
            "sender_email" : safeEmail,
            "is_read" : false,
            "other_user_name" : otherUserName
        ]
        let value : [String : Any] = [
            "messages" : [
                messages
            ]
        ]
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
}
