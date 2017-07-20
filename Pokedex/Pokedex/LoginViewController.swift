//
//  LoginViewController.swift
//  Pokedex
//
//  Created by Daniel on 06/07/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import PKHUD
//import MBProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginButton.setTitle("Login", for:UIControlState.normal)
        registerButton.setTitle("Sign up", for:UIControlState.normal)
        setTextFieldIcons()
    }
    
    @IBAction func loginButtonActionHandler(_ sender: Any) {
        
        // print("Username: " + userName +  " -- " + "Password: " + password)
        
        guard
            let email = userNameTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty
            else {
                return
            }
        
        let params = [
            "data": [
                "type": "session",
                "attributes": [
                    "email": email,
                    "password": password
                ]
            ]
        ]
        
        
        Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/users/login",
                method: .post,
                parameters: params
            )
            .validate()
            .responseDecodableObject { (response: DataResponse<User>) in
                
                switch response.result {
                case .success(let user):
                    print("DECODED: \(user)")
                    HUD.flash(.success, delay: 1.0)
                    let bundle = Bundle.main
                    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
                    let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
                    self.navigationController?.setViewControllers([homeViewController], animated: true)
                case .failure(let error):
                    HUD.flash(.error, delay: 1.0)
                    print("FAILURE: \(error)")
                }
        }
        
    }

    
    @IBAction func registerButtonActionHandler(_ sender: Any) {
            let bundle = Bundle.main
            let storyboard = UIStoryboard(name: "Main", bundle: bundle)
            let registerViewController = storyboard.instantiateViewController(withIdentifier: "RegisterViewController")
            self.navigationController?.pushViewController(registerViewController, animated: true) 
        
        
        
         /*   DispatchQueue.main.asyncAfter(deadline: .now()) {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.navigationController?.pushViewController(registerViewController, animated: true)
            } */
         
 
    }
    
    func setTextFieldIcons () {
        let iconWidth = 24
        let iconHeight = 24
        
        let userNameImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight))
        let passwordImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight))
        
        userNameTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.rightViewMode = UITextFieldViewMode.always
        
        userNameImageView.image = UIImage(named: "ic-mail")
        passwordImageView.image = UIImage(named: "ic-lock")
        
        userNameTextField.leftView = userNameImageView
        passwordTextField.leftView = passwordImageView
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
}
