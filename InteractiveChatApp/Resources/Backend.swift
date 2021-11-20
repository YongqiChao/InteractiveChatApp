//
//  Backend.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/17/21.
//

import Foundation
import Amplify
import AmplifyPlugins

class Backend {
    static let shared = Backend()
    
    static func initialize() -> Backend {
        return .shared
    }
    
    private init() {
        // initialize amplify
        //  let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
        do {
            Amplify.Logging.logLevel = .info
            let dataStorePlugin = AWSDataStorePlugin(modelRegistration:
                                                        AmplifyModels())
            try Amplify.add(plugin: dataStorePlugin)
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration:
                                                    AmplifyModels()))
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Initialized Amplify");
        } catch {
            print("Could not initialize Amplify: \(error)")
        }
    }
    
}
