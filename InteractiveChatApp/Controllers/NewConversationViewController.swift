//
//  NewConversationViewController.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/10/21.
//

import UIKit
import JGProgressHUD
import RealmSwift

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
        view.addSubview(noResultLabel)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width/4,
                                     y: (view.height - 200)/2,
                                     width: view.width / 2,
                                     height: 100)
    }
    
    // views
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [User]()
    private var userFilterResult = [User]()
    private var hasFetchedUsers = false
    
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
    
    public var completion : ((User) -> (Void))?
    
}

extension NewConversationViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " " ,
                                                                    with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        spinner.show(in: view)
        userFilterResult.removeAll()
        self.searchUsers(username : text)
    }
    
    func searchUsers(username : String) {
        if hasFetchedUsers {
            //have result
            filterUsers(with: username)
            self.updateUI()
        } else {
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .failure(let error) :
                    print("Failed fetch all useres \(error)")
                    self?.updateUI()
                case .success(let usersCollection) :
                    self?.hasFetchedUsers = true
                    self?.users = usersCollection
                    self?.filterUsers(with: username)
                    self?.updateUI()
                }
            })
//            // no result, create new
//            DatabaseManager.shared.fetchAllUsers(completion: { [weak self] result in
//                switch result {
//                case .failure(let error) :
//                    print("Failed fetch all useres \(error)")
//                    self?.updateUI()
//                case .success(let usersCollection) :
//                    self?.hasFetchedUsers = true
//                    self?.users = usersCollection
//                    self?.filterUsers(with: username)
//                    self?.updateUI()
//                }
//            })
        }
    }
    
    func updateUI() {
        if userFilterResult.isEmpty {
            self.noResultLabel.isHidden = false
            self.tableView.isHidden = true
        }
        else {
            self.noResultLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    func filterUsers(with inputName : String) {
        spinner.dismiss(animated: true)
        guard hasFetchedUsers else {
            return
        }

        let userFilterResult : [User] = self.users.filter({
            guard let firstname = $0.first_name.lowercased() as? String else {
                return false
            }
            guard let lastname = $0.last_name.lowercased() as? String else {
                return false
            }
            
            return firstname.hasPrefix(inputName.lowercased()) || lastname.hasPrefix(inputName.lowercased())
        })
        self.userFilterResult = userFilterResult
    }
    
}

extension NewConversationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = userFilterResult[indexPath.row].first_name + " " +
        userFilterResult[indexPath.row].last_name // ["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userFilterResult.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start new conversation
        let targetUserData = userFilterResult[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }
    
}
