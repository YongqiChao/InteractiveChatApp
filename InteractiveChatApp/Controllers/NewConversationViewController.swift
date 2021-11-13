//
//  NewConversationViewController.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/10/21.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    // views
    private let spinner = JGProgressHUD()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for friends ... "
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let noResultLabel : UILabel = {
        let noResultLabel = UILabel()
        noResultLabel.text = "No Results"
        noResultLabel.textAlignment = .center
        noResultLabel.font = .systemFont(ofSize: 20, weight: .medium)
        noResultLabel.textColor = .red
        noResultLabel.isHidden = true
        return noResultLabel
    }()
    
    // funcs
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
