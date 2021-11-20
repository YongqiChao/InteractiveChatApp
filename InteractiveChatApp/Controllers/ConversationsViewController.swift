//
//  ViewController.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/9/21.
//

import UIKit
import SwiftUI
import JGProgressHUD
import Amplify
import AmplifyPlugins
import Combine

class ConversationsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(tappedComposeButton))
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
        setupTableView()
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
        noConversationLabel.frame = CGRect(x: view.width / 2 - 180 ,
                                           y: view.height / 2 - 50,
                                           width: 350,
                                           height: 200)
    }
    
    private func validateAuth() {
//        let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
//        if !loggedIn {
//        }
        Amplify.Auth.fetchAuthSession { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let session):
                if !session.isSignedIn {
                    DispatchQueue.main.async {
                        strongSelf.showLoginViewController()
                    }
                }
                print("Is user signed in - \(session.isSignedIn)")
            case .failure(let error):
                print("Fetch session failed with error \(error)")
                DispatchQueue.main.async {
                    strongSelf.showLoginViewController()
                }
            }
        }
    }
    
    private func showLoginViewController() {
        let loginView = LoginViewController()
        let navigationView = UINavigationController(rootViewController: loginView)
        navigationView.modalPresentationStyle = .fullScreen
        self.present(navigationView, animated: true)
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
        label.text = "No Chats ! \n \n To add a chat by clicking the top right \"Compose\" button"
        label.textAlignment = .center
        label.textColor = .link
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.isHidden = false
        label.numberOfLines = 0
        return label
    }()
    
    private var latestMessages = [LatestMessage]()
    
    // ===============================================================================================

 //  private var conversations = [Conversation]()
    
    // ===============================================================================================
    // funcs
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    
    @objc private func tappedComposeButton() {
        let newConversationView = NewConversationViewController()
        newConversationView.completion = { [weak self] result in
            self?.createNewTemporaryConversation(result: result)
        }
        let newNaviagation = UINavigationController(rootViewController: newConversationView)
        present(newNaviagation, animated: true)
    }
    
    private func createNewTemporaryConversation(result: User) {
        guard let firstname = result.first_name as? String,
              let lastname = result.last_name as? String,
              let recipientEmail = result.id as? String else {
                  return
              }
        let conversationId = findConversationId(with : recipientEmail)
        let chatView = ChatViewController(with: recipientEmail, id: conversationId)
        print("123\(conversationId)")
        chatView.isNewConversation = true
        chatView.title = firstname + " " + lastname
        chatView.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatView, animated: true)
    }
    
    private func findConversationId(with recipientEmail : String) -> String? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let conversationId = recipientEmail + "_" + email
        let reverseConversationId = email + "_" + recipientEmail
        var returnValue : String = ""
        DatabaseManager.shared.getConversation(for: conversationId,
                                                  completion: { result in
            switch result {
            case .failure(let error) :
                print("Failed fetch user \(error)")
                DatabaseManager.shared.getConversation(for: reverseConversationId,
                                                          completion: { result in
                    switch result {
                    case .failure(let error) :
                        print("Failed fetch user \(error)")
                        // if no conversation Id , use a temporary id,
                        // to be changed in the future
                        returnValue = reverseConversationId
                    case .success(_) :
                        returnValue = reverseConversationId
                    }
                })
            case .success(_) :
                returnValue = conversationId
            }
        })
        while returnValue == "" {
            sleep(1)
        }
        return returnValue
    }
    
    var latestMessageSubscription: AnyCancellable?
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        //let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
//        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
//            switch result {
//            case.failure(let error) :
//                print("failed to get all conversations : \(error)")
//            case .success(let conversations) :
//                guard !conversations.isEmpty else {
//                    return
//                }
//                self?.conversations = conversations
//                DispatchQueue.main.async {
//                    print("Yeah I got a message")
//                    self?.tableView.reloadData()
//                }
//            }
//        })
        let queryLatestMessages = LatestMessage.keys
        self.latestMessageSubscription = Amplify.DataStore.observeQuery(
            for: LatestMessage.self,
               where: queryLatestMessages.id.beginsWith("\(email)"))
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error \(error)")
                }
            } receiveValue: { querySnapshot in
                self.latestMessages = querySnapshot.items
                DispatchQueue.main.async {
                    if (querySnapshot.items.count > 0) {
                        self.noConversationLabel.isHidden = true
                        self.tableView.isHidden = false
                        self.tableView.backgroundColor = .systemGray6
                    }
                    print("Yeah I got all latest message")
                    self.tableView.reloadData()
                }
            }
        
    }
    // Then, when you're finished observing, cancel the subscription
    func unsubscribeFromConversations() {
        latestMessageSubscription?.cancel()
    }
    
}


// ===============================================================================================
extension ConversationsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = latestMessages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latestMessages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = latestMessages[indexPath.row]
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let recipientEmail = model.recipient_email.elementsEqual(currentUserEmail) ? model.sender_email : model.recipient_email
        guard let currentUserName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        let recipientName = model.recipient_name.elementsEqual(currentUserName) ? model.sender_name : model.recipient_name
        
        let conversationId = findConversationId(with : recipientEmail)
        let chatView = ChatViewController(with: recipientEmail, id: conversationId)
        chatView.title = recipientName
        chatView.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
