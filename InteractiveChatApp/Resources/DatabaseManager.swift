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
            completion(true)
        })
    }
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "+")
        safeEmail = safeEmail.replacingOccurrences(of: "[", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "]", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value,
                                                     with: { snapshot in
            guard snapshot.exists() else {
                completion(false)
                return
            }
            completion(true)
        })
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress : String
    
    var safeEmail : String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "+")
        safeEmail = safeEmail.replacingOccurrences(of: "[", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "]", with: "-")
        return safeEmail
    }
    
    var profilePictureName : String {
        return "\(safeEmail)_profile_picture.png"
    }
}
