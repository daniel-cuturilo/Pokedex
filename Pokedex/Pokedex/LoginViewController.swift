//
//  LoginViewController.swift
//  Pokedex
//
//  Created by Daniel on 06/07/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loginButton.setTitle("Login", for:UIControlState.normal)
        registerButton.setTitle("Register", for:UIControlState.normal)
        
    }
    
    @IBAction func loginButtonActionHandler(_ sender: Any) {
        guard
            let userName = userNameTextField.text,
            let password = passwordTextField.text,
            !userName.isEmpty,
            !password.isEmpty
            else {
                return
            }
        
        print("Username: " + userName +  " -- " + "Password: " + password)
    }

    
    @IBAction func registerButtonActionHandler(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
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