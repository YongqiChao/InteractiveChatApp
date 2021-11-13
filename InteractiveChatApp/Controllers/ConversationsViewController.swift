//
//  ViewController.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/9/21.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    private func validateAuth() {
        //let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        //if !loggedIn {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let loginView = LoginViewController()
            let navigationView = UINavigationController(rootViewController: loginView)
            navigationView.modalPresentationStyle = .fullScreen
            present(navigationView, animated: true)
        }
    }
}

