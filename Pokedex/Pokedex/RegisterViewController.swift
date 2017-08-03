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

    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
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
                    self?.showFailure()
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setTextFieldIcons()
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
        // Dispose of any resources that can be recreated.
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
