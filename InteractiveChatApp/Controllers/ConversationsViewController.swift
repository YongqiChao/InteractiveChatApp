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
        startListeningForConversations()
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
        table.register(ConversationTableViewCell.self,
                       forCellReuseIdentifier: ConversationTableViewCell.identifier)
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

    private var conversations = [Conversation]()
    
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
        let newConversationView = NewConversationViewController()
        newConversationView.completion = { [weak self] result in
            self?.createNewTemporaryConversation(result: result)
        }
        let newNaviagation = UINavigationController(rootViewController: newConversationView)
        present(newNaviagation, animated: true)
    }
    
    private func createNewTemporaryConversation(result: [String: String]) {
        guard let name = result["name"],
              let email = result["email"] else {
                  return
              }
        
        let chatView = ChatViewController(with: email, id: nil)
        chatView.isNewConversation = true
        chatView.title = name
        chatView.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatView, animated: true)
    }
    
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case.failure(let error) :
                print("failed to get all conversations : \(error)")
            case .success(let conversations) :
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversations = conversations
                DispatchQueue.main.async {
                    print("Yeah I got a message")
                    self?.tableView.reloadData()
                }
            }
        })
    }
    
}


// ===============================================================================================
extension ConversationsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        
        let chatView = ChatViewController(with: model.otherUserEmail, id: model.id)
        chatView.title = model.otherUserName
        chatView.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

struct Conversation {
    let id : String
    let otherUserName : String
    let otherUserEmail : String
    let latestMessage : LatestMessage
}

struct LatestMessage {
    let date : String
    let text : String
    let isRead : Bool
}
