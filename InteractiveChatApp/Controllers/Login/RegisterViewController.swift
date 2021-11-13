//
//  RegisterViewController.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/10/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Register"
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
        registerButton.addTarget(self,
                              action: #selector(tappedRegisterButton),
                              for: .touchUpInside)
        
        // delegates
        emailField.delegate = self
        passwordField.delegate = self
        
        // add sub views
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapProfilePicture))
        gesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture)
        scrollView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        imageView.frame = CGRect(x: (scrollView.width - scrollView.width/3)/2  ,
                                 y: 50,
                                 width: scrollView.width/3,
                                 height: scrollView.width/3)
        imageView.layer.cornerRadius = imageView.width / 2
        firstNameField.frame = CGRect(x: 30 ,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 50)
        lastNameField.frame = CGRect(x: 30 ,
                                  y: firstNameField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 50)
        emailField.frame = CGRect(x: 30 ,
                                  y: lastNameField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 50)
        passwordField.frame = CGRect(x: 30 ,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 50)
        registerButton.frame = CGRect(x: 30 ,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 50)
    }
    
    // helper functions
    
    @objc private func didTapProfilePicture() {
        presentPhotoActionSheet()
    }
    
    @objc private func didTapRegister() {
        let registerView = RegisterViewController()
        navigationController?.pushViewController(registerView, animated: true)
    }
    
    @objc private func tappedRegisterButton() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        // == validation
        guard let firstname = firstNameField.text, let lastname = lastNameField.text,
              !firstname.isEmpty, !lastname.isEmpty,
              let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                  alertUserRegisterError()
                  return
              }
        
        spinner.show(in: view)
        
        // == Firebase register logic
        DatabaseManager.shared.userExists(with: email,
                                          completion: { [weak self] exists in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
            }
            
            guard !exists else {
                strongSelf.alertUserRegisterError(message: "Email address exists")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Creating user error")
                    return
                }
                let chatAppUser = ChatAppUser(firstName: firstname,
                                             lastName: lastname,
                                             emailAddress: email )
                DatabaseManager.shared.insertUser(with: chatAppUser,
                                                  completion: { success in
                    if success {
                        //upload image
                        guard let image = strongSelf.imageView.image,
                              let data = image.pngData() else {
                                  print("profile picture upload failed")
                                  return
                              }
                        let filename = chatAppUser.profilePictureName
                        StorageManeger.shared.uploadProfilePicture(with: data,
                                                                   fileName: filename,
                                                                   completion: { result in
                            switch result {
                            case .success(let downloadURL) :
                                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                            case .failure(let downloadError) :
                                print("Download url error, \(downloadError)")
                            }
                        })
                    }
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    func alertUserRegisterError(message : String = "Please enter valid information to register") {
        let alert = UIAlertController(title: "Register Error",
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
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.link.cgColor
        return imageView
    }()
    
    // helper fields, buttons
    
    private let firstNameField : UITextField = {
        let firstNameField = UITextField()
        firstNameField.returnKeyType = .continue
        firstNameField.autocorrectionType = .no
        firstNameField.autocapitalizationType = .none
        firstNameField.layer.cornerRadius = 10
        firstNameField.layer.borderWidth = 1
        firstNameField.layer.borderColor = UIColor.lightGray.cgColor
        firstNameField.placeholder = "Enter firstname"
        firstNameField.backgroundColor = .white
        firstNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        firstNameField.leftViewMode = .always
        return firstNameField
    }()
    
    private let lastNameField : UITextField = {
        let lastNameField = UITextField()
        lastNameField.returnKeyType = .continue
        lastNameField.autocorrectionType = .no
        lastNameField.autocapitalizationType = .none
        lastNameField.layer.cornerRadius = 10
        lastNameField.layer.borderWidth = 1
        lastNameField.layer.borderColor = UIColor.lightGray.cgColor
        lastNameField.placeholder = "Enter lastname"
        lastNameField.backgroundColor = .white
        lastNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        lastNameField.leftViewMode = .always
        return lastNameField
    }()
    
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
    
    private let registerButton : UIButton = {
        let registerButton = UIButton()
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 10
        registerButton.backgroundColor = .systemTeal
        registerButton.layer.masksToBounds = true
        registerButton.titleLabel?.font = .systemFont(ofSize: 25, weight: .bold)
        return registerButton
    }()
}

extension RegisterViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        if textField == passwordField {
            tappedRegisterButton()
        }
        return true
    }
}


extension RegisterViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture ? ",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take photo",
                                            style: .default,
                                            handler: { [weak self] _ in self?.presentCamera() }))
        actionSheet.addAction(UIAlertAction(title: "Choose photo",
                                            style: .default,
                                            handler: { [weak self] _ in self?.presentPhotoPicker() }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let viewController = UIImagePickerController()
        viewController.sourceType = .camera
        viewController.delegate = self
        viewController.allowsEditing = true
        present(viewController, animated: true)
    }
    
    func presentPhotoPicker() {
        let viewController = UIImagePickerController()
        viewController.sourceType = .photoLibrary
        viewController.delegate = self
        viewController.allowsEditing = true
        present(viewController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
