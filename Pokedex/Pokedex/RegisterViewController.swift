//
//  RegisterViewController.swift
//  Pokedex
//
//  Created by Daniel on 17/07/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let emailImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let nicknameImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let passwordImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let passwordConfirmImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
