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
