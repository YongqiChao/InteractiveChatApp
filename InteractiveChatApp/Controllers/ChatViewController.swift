//
//  ChatViewController.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/13/21.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        messages.append(Message(messageId: "",
                                sentDate: Date(),
                                kind: .text("first chat"),
                                sender: selfsender))
                        
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    // datas
    private var messages = [Message]()
    
    // test
    private let selfsender = Sender(senderId: "3",
                                    displayName: "123",
                                    photoURL: "")
    
}


struct Message : MessageType {
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var sender: SenderType
}

struct Sender : SenderType {
    var senderId: String
    var displayName: String
    var photoURL: String
}


extension ChatViewController : MessagesLayoutDelegate,
                               MessagesDisplayDelegate,
                               MessagesDataSource {
    func currentSender() -> SenderType {
        return selfsender
    }
    
    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
