//
//  RegisterViewController.swift
//  Pokedex
//
//  Created by Daniel on 17/07/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import PKHUD

class RegisterViewController: UIViewController, Progressable {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var lockConfirmButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    
    @IBAction func lockButtonActionHandler(_ sender: Any) {
        if (passwordTextField.isSecureTextEntry == true) {
            passwordTextField.isSecureTextEntry = false
        } else {
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    @IBAction func lockConfirmButtonActionHandler(_ sender: Any) {
        if (passwordConfirmTextField.isSecureTextEntry == true) {
            passwordConfirmTextField.isSecureTextEntry = false
        } else {
            passwordConfirmTextField.isSecureTextEntry = true
        }
    }
    
    @IBAction func signUpButtonActionHandler(_ sender: Any) {
        guard
            let email = emailTextField.text,
            let username = nicknameTextField.text,
            let password = passwordTextField.text,
            let passwordConfirm = passwordConfirmTextField.text,
            !email.isEmpty,
            !username.isEmpty,
            !password.isEmpty,
            !passwordConfirm.isEmpty
            else {
                print ("Mistake")
                return
        }
        
        // print("Email: " + email +  " -- " + "Username: " + username + " -- " + "Password: " + password)
        
        let params = [
            "data": [
                "type": "users",
                "attributes": [
                    "email": email,
                    "username": username,
                    "password": password,
                    "password-confirmation": password
                ]
            ]
        ]
        
        Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/users",
                method: .post,
                parameters: params
            )
            .validate()
            .responseDecodableObject { [weak self] (response: DataResponse<User>) in
                
                switch response.result {
                case .success(let user):
                    print("DECODED: \(user)")
                    self?.showSuccess()
                    let bundle = Bundle.main
                    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
                    let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    homeViewController.user = user
                    self?.navigationController?.setViewControllers([homeViewController], animated: true)
                    
                    
                case .failure(let error):
                    print("FAILURE: \(error)")
                    self?.handleRegisterMistakes()
                }
        }
    }
    
    func handleRegisterMistakes() {
        guard let email = self.emailTextField.text,
        let password = self.passwordTextField.text,
        let passwordConfirm = self.passwordConfirmTextField.text,
        let nickname = self.nicknameTextField.text
            else {
                return
        }
        
        if (email.isEmpty || password.isEmpty || passwordConfirm.isEmpty || nickname.isEmpty) {
            initializeAlert(message: "You didn't enter all the data.")
        }
        
        if (!(email.contains("@"))) {
            initializeAlert(message: "Check your e-mail.")
        } else if ((password.characters.count) < 8) {
            initializeAlert(message: "Password needs to have at least 8 characters.")
        } else if (password != passwordConfirm) {
            initializeAlert(message: "Passwords do not match.")
        }
    }
    
    func initializeAlert (message: String) {
        let alertController = UIAlertController(title: "Register not successful.", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldIcons()
        setBorders(textField: nicknameTextField)
        setBorders(textField: passwordTextField)
        setBorders(textField: passwordConfirmTextField)
        setBorders(textField: emailTextField)
        setBorders(button: lockButton)
        setBorders(button: lockConfirmButton)
        
        navigationItem.title = "Register"
    }
    
    func setBorders(textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  stackView.frame.size.width + 60, height: textField.frame.size.height)
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    func setBorders(button: UIButton) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        border.frame = CGRect(x: 0, y: button.frame.size.height - width, width:  button.frame.size.width, height: button.frame.size.height)
        border.borderWidth = width
        button.layer.addSublayer(border)
        button.layer.masksToBounds = true
    }
    
    
    func setTextFieldIcons () {
        let iconWidth = 24
        let iconHeight = 24
        
        let emailImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight))
        let nicknameImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight))
        let passwordImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight))
        let passwordConfirmImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight))
        
        emailTextField.leftViewMode = UITextFieldViewMode.always
        nicknameTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        passwordConfirmTextField.leftViewMode = UITextFieldViewMode.always
        
        emailImageView.image = UIImage(named: "ic-mail")
        nicknameImageView.image = UIImage(named: "ic-person")
        passwordImageView.image = UIImage(named: "ic-lock")
        passwordConfirmImageView.image = UIImage(named: "ic-lock")
        
        emailTextField.leftView = emailImageView
        nicknameTextField.leftView = nicknameImageView
        passwordTextField.leftView = passwordImageView
        passwordConfirmTextField.leftView = passwordConfirmImageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

protocol Progressable {
    func showSuccess()
    func showFailure()
    func showProgress()
    func hideProgress()
}

extension Progressable where Self: UIViewController {
    func showSuccess() {
        HUD.flash(.success, delay: 1.0)
    }
    func showFailure() {
        HUD.flash(.error, delay: 1.0)
    }
    func showProgress() {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.show()
    }
    func hideProgress() {
        PKHUD.sharedHUD.hide(afterDelay: 1.5)
    }
}
