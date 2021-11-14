//
//  ChatViewController.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/13/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
//        messages.append(Message(messageId: "",
//                                sentDate: Date(),
//                                kind: .text("first chat"),
//                                sender: selfSender))
                        
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // data
    public let otherUserEmail: String
    public var isNewConversation = false
    private var messages = [Message]()
    public static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    // myself
    private var selfSender : Sender? = {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        return Sender(senderId: email,
               displayName: "123",
               photoURL: "")
    }()
    
}


struct Message : MessageType {
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    public var sender: SenderType
}

extension MessageKind {
    var rawData : String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom_data"
        }
    }
}

struct Sender : SenderType {
    public var senderId: String
    public var displayName: String
    public var photoURL: String
}


extension ChatViewController : MessagesLayoutDelegate,
                               MessagesDisplayDelegate,
                               MessagesDataSource {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Error : self sender is nil, no email was cached")
        return Sender(senderId: "", displayName: "", photoURL: "")
    }
    
    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

extension ChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
        }
        
        if isNewConversation {
            //create a new chat
            let message = Message(messageId: messageId,
                                  sentDate: Date(),
                                  kind: .text(text),
                                  sender: selfSender)
            DatabaseManager.shared.createNewConversation(with: otherUserEmail,
                                                         otherUserName: self.title ?? "Unknown User",
                                                         firstMessage: message,
                                                         completion: { [weak self] success in
                if success {
                    print("Sent message")
                } else {
                    print("Sent message Failed")
                }
            })
        } else {
            // append existing chat
            
        }
    }
    
    private func createMessageId() -> String? {
        let dateString = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeCurrentUserEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentUserEmail)_\(dateString)"
        return newIdentifier
    }
    
}
