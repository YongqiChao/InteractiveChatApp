//
//  StorageManager.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/13/21.
//

import Foundation
import SwiftUI
import Amplify
import AmplifyPlugins

final class StorageManeger {
    
    static let shared = StorageManeger()
    
    //private let storage = Storage.storage(url: "gs://interactivechatapp.appspot.com/").reference()
//    private let storage = Storage.storage().reference()
//
//    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
//
//    public func uploadProfilePicture(with data : Data,
//                                     fileName: String,
//                                     completion : @escaping UploadPictureCompletion ) {
//        storage.child("images/\(fileName)").putData(data,
//                                                    metadata: nil,
//                                                    completion: { metadata, error in
//            guard error == nil else {
//                print("upload picture failed")
//                completion(.failure(StorageErrors.failedToUpload))
//                return
//            }
//            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
//                guard let url = url else {
//                    print("download url errors")
//                    completion(.failure(StorageErrors.failedToDownloadUrl))
//                    return
//                }
//                let urlString = url.absoluteString
//                completion(.success(urlString))
//            })
//        })
//
//    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToDownloadUrl
    }
    
//    public func downloadURL(for path : String,
//                            completion : @escaping (Result<URL, Error>) -> Void ) {
//        let reference = storage.child(path)
//        reference.downloadURL(completion: { url, error in
//            guard let url = url, error == nil else {
//                completion(.failure(StorageErrors.failedToDownloadUrl))
//                return
//            }
//            completion(.success(url))
//        })
//    }
    
    func uploadData() {
        let dataString = "Example file contents"
        let data = dataString.data(using: .utf8)!
        Amplify.Storage.uploadData(key: "ExampleKey", data: data,
            progressListener: { progress in
                print("Progress: \(progress)")
            }, resultListener: { (event) in
                switch event {
                case .success(let data):
                    print("Completed: \(data)")
                case .failure(let storageError):
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        })
    }
}
