//
//  ViewController.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/9/21.
//

import UIKit
import FirebaseAuth
import SwiftUI
import JGProgressHUD

class ConversationsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(tappedComposeButton))
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
        setupTableView()
        fetchConversations()
//        view.backgroundColor = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
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
    
    // ===============================================================================================
    // views
    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "No Chats !"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    // ===============================================================================================
    // funcs
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConversations() {
        tableView.isHidden = false
    }
    
    @objc private func tappedComposeButton() {
        let newConversation = NewConversationViewController()
        let newNaviagation = UINavigationController(rootViewController: newConversation)
        present(newNaviagation, animated: true)
    }
}


// ===============================================================================================
extension ConversationsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "hello"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chatView = ChatViewController()
        chatView.title = "some one "
        chatView.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatView, animated: true)
    }
}
