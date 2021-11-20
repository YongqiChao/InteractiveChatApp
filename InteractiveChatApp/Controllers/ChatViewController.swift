//
//  ChatViewController.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/13/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Amplify
import Combine

class ChatViewController: MessagesViewController {
    public var sender : User?
    public var recipient : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.clearsContextBeforeDrawing = true
        messageInputBar.delegate = self
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        DatabaseManager.shared.getUser(for: currentUserEmail,
                                          completion: { result in
            switch result {
            case .failure(let error) :
                print("Failed fetch user \(error)")
            case .success(let user) :
                self.sender = User(id: user.id,
                              first_name: user.first_name,
                              last_name: user.last_name,
                              LatestMessages: user.LatestMessages)
            }
        })
        DatabaseManager.shared.getUser(for: otherUserEmail,
                                          completion: {result in
            switch result {
            case .failure(let error) :
                print("Failed fetch user \(error)")
            case .success(let user) :
                self.recipient = User(id: user.id,
                              first_name: user.first_name,
                              last_name: user.last_name,
                              LatestMessages: user.LatestMessages)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        unsubscribeFromConversations()
//    }
    
    init(with email: String, id : String?) {
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // data
    public let otherUserEmail: String
    private var conversationId: String?
    public var isNewConversation = false
    private var messages = [DisplayMessage]()
    public static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    // myself
    private var selfSender : Sender? = {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
              let name = UserDefaults.standard.value(forKey: "name") as? String
              //let photoUrl = UserDefaults.standard.value(forKey: "photoUrl") as? String
        else {
            return nil
        }
        //let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(senderId: email,
               displayName: name,
               photoURL: "")
    }()
    
    //funcs
    var messagesSubscription: AnyCancellable?
    private func listenForMessages(id : String, shouldScrollToBottom : Bool) {
//        DatabaseManager.shared.getAllMessagesForConversation(with: id,
//                                                             completion: { [weak self] result in
//            switch result {
//            case . failure(let error) :
//                print("Failed to listen all messages for a conversation: \(error)")
//            case .success(let messages) :
//                guard !messages.isEmpty else {
//                    print("There is no message in this chat")
//                    return
//                }
//                self?.messages = messages
//                DispatchQueue.main.async {
//                    print("reloading ... ... ... messages ...")
//                    self?.messagesCollectionView.reloadDataAndKeepOffset()
//                    if shouldScrollToBottom {
//                        self?.messagesCollectionView.scrollToLastItem()
//                    }
//                }
//            }
//        })

        let queryMessage = Message.keys
        guard let conversationId = conversationId  else {
            return
        }
        self.messagesSubscription = Amplify.DataStore.observeQuery(
            for: Message.self,
               where: queryMessage.conversationID.eq(conversationId))
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error \(error)")
                }
            } receiveValue: {
                print("receiging values : \(conversationId)")
                self.messages.removeAll()
                for mess in $0.items {
                    // add recipient photo here
                    print("receiging values : \(mess)")

                    let sender = Sender(senderId: mess.sender_email,
                                        displayName: mess.sender_name,
                                        photoURL: "")
                    guard let date = ChatViewController.dateFormatter.date(from: mess.date) else {
                        print("receiging values  error123: \(mess)")
                        return
                    }
                    self.messages.append(DisplayMessage(messageId: mess.id,
                                                   sentDate: date ,
                                                   kind: .text(mess.content),
                                                   sender: sender))
                }
                print("reloading $$$$$$ ... ... ... messages ...")

                DispatchQueue.main.async {
                    print("reloading ... ... ... messages ...")
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self.messagesCollectionView.scrollToLastItem()
                    }
                }
            }
    }
    // Then, when you're finished observing, cancel the subscription
    func unsubscribeFromConversations() {
        messagesSubscription?.cancel()
    }
//    private func convertMessages(with preConvertMessages : [Message]) -> [DisplayMessage] {
//        var convertedMessages = [DisplayMessage]()
//        guard let thissender = selfSender else {
//            return convertedMessages
//        }
//        for mes in preConvertMessages {
//            convertedMessages.append(DisplayMessage(messageId: mes.id,
//                                                    sentDate: Date(),
//                                                    kind: mes.type,
//                                                    sender: thissender))
//        }
//        return convertedMessages
//    }
    
}
struct DisplayMessage : MessageType {
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    public var sender: SenderType
}

extension MessageKind {
    var rawData : String {
        switch self {
        case .text(_):
            return "TEXT"
        case .attributedText(_):
            return "ATTRIBUTEDTEXT"
        case .photo(_):
            return "PHOTO"
        case .video(_):
            return "VIDEO"
        case .location(_):
            return "LOCATION"
        case .emoji(_):
            return "EMOJI"
        case .audio(_):
            return "AUDIO"
        case .contact(_):
            return "CONTACT"
        case .linkPreview(_):
            return "LINKPREVIEW"
        case .custom(_):
            return "CUSTOM"
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

        guard !text.replacingOccurrences(of: " ", with: "").isEmpty
              //let selfSender = self.selfSender,
             // let messageId = createMessageId(),
              else {
            return
        }

        let dateString = Self.dateFormatter.string(from: Date())
        guard let thisSender = self.sender,
              let thisRecipient = self.recipient else {
                  return
              }
        if (conversationId == nil)  {
            conversationId = createConversationId()
        }
        guard let conversationId = conversationId  else {
            return
        }
        let message = Message(id: conversationId + dateString,
                              content: text,
                              date: dateString,
                              recipient_email: thisRecipient.id,
                              recipient_name: thisRecipient.first_name + " " + thisRecipient.last_name,
                              sender_name: thisSender.first_name + " " + thisSender.last_name,
                              sender_email: thisSender.id,
                              is_read: false,
                              type: MesKind.text,
                              conversationID: conversationId)
        if isNewConversation {
            //create a new chat
            DatabaseManager.shared.addConversation(with: conversationId,
                                                   completion: { result in
                switch result {
                case false :
                    print("Failed to create new conversation")
                case true :
                    print("Created new conversation")
                    self.isNewConversation = false
                }
            })
        }
        DatabaseManager.shared.addMessage(with: message,
                                          completion: { result in
            switch result {
            case false :
                print("Failed to create new message")
            case true :
                print("Created new message")
                inputBar.inputTextView.text = ""
            }
        })
    }
    
    private func createConversationId() -> String? {
        //let dateString = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        //let safeCurrentUserEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let newIdentifier = "\(currentUserEmail)_\(otherUserEmail)"
        return newIdentifier
    }
    
}
