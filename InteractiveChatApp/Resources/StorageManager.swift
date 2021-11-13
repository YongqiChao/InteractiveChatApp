//
//  StorageManager.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/13/21.
//

import Foundation
import FirebaseStorage

final class StorageManeger {
    
    static let shared = StorageManeger()
    
    //private let storage = Storage.storage(url: "gs://interactivechatapp.appspot.com/").reference()
    private let storage = Storage.storage().reference()

    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data : Data,
                                     fileName: String,
                                     completion : @escaping UploadPictureCompletion ) {
        storage.child("images/\(fileName)").putData(data,
                                                    metadata: nil,
                                                    completion: { metadata, error in
            guard error == nil else {
                print("upload picture failed")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("download url errors")
                    completion(.failure(StorageErrors.failedToDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                completion(.success(urlString))
            })
        })
        
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToDownloadUrl
    }
}
