//
//  LoginViewController.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/10/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login"
        view.backgroundColor = .white
        
        // in ios 15 the navigation bar is transparent
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // button actions
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister) )
        loginButton.addTarget(self,
                              action: #selector(tappedLoginButton),
                              for: .touchUpInside)
        
        // delegates
        emailField.delegate = self
        passwordField.delegate = self
        
        // add sub views
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        imageView.frame = CGRect(x: (scrollView.width - scrollView.width/3)/2  ,
                                 y: 50,
                                 width: scrollView.width/3,
                                 height: scrollView.width/3)
        imageView.layer.cornerRadius = imageView.width / 2
        emailField.frame = CGRect(x: 30 ,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 50)
        passwordField.frame = CGRect(x: 30 ,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 50)
        loginButton.frame = CGRect(x: 30 ,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 50)
    }
    
    // helper functions
    
    @objc private func didTapRegister() {
        let registerView = RegisterViewController()
        navigationController?.pushViewController(registerView, animated: true)
    }
    
    @objc private func tappedLoginButton() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                  alertUserLoginError()
                  return
              }
        
        spinner.show(in: view)
        
        // === Firebase log in logic
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
            }
            
            guard let result = authResult, error == nil else {
                print("failed to log in")
                strongSelf.alertUserLoginError()
                return
            }
            let user = result.user
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(password, forKey: "password")
            print("new user log in \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func alertUserLoginError(message : String = "Please enter valid information to log in") {
        let alert = UIAlertController(title: "Login Error",
                                      message: message,
                                      preferredStyle:  .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    // helper views
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.link.cgColor
        return imageView
    }()
    
    // helper fields, buttons
    
    private let emailField : UITextField = {
        let emailField = UITextField()
        emailField.returnKeyType = .continue
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        emailField.layer.cornerRadius = 10
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.lightGray.cgColor
        emailField.placeholder = "Enter email address"
        emailField.backgroundColor = .white
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        emailField.leftViewMode = .always
        return emailField
    }()
    
    private let passwordField : UITextField = {
        let passwordField = UITextField()
        passwordField.returnKeyType = .done
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.layer.cornerRadius = 10
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.lightGray.cgColor
        passwordField.placeholder = "Enter password"
        passwordField.backgroundColor = .white
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordField.leftViewMode = .always
        passwordField.isSecureTextEntry = true
        return passwordField
    }()
    
    private let loginButton : UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 10
        loginButton.backgroundColor = .link
        loginButton.layer.masksToBounds = true
        loginButton.titleLabel?.font = .systemFont(ofSize: 25, weight: .bold)
        return loginButton
    }()
}



extension LoginViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        if textField == passwordField {
            tappedLoginButton()
        }
        return true
    }
}
