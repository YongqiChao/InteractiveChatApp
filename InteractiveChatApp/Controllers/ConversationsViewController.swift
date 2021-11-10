//
//  ViewController.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/9/21.
//

import UIKit

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        if !loggedIn {
            let loginView = LoginViewController()
            let navigationView = UINavigationController(rootViewController: loginView)
            navigationView.modalPresentationStyle = .fullScreen
            present(navigationView, animated: true)
        }
    }
}

