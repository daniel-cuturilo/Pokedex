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

class LoginViewController: UIViewController, UITextFieldDelegate, Progressable {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    
    var keyboardDismissTapGesture: UIGestureRecognizer?
    let defaults:UserDefaults = UserDefaults.standard
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        if let email:String = defaults.string(forKey: "email") {
            if let password:String = defaults.string(forKey: "password") {
                print(email + "   " + password)
                self.loginRequest(email: email, password: password)
            }
        }
        
        setBorders(textField: userNameTextField)
        setBorders(textField: passwordTextField)
        
        loginButton.setTitle("Login", for:UIControlState.normal)
        registerButton.setTitle("Sign up", for:UIControlState.normal)
        setTextFieldIcons()
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    func setBorders(textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width + 60, height: textField.frame.size.height)
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func userNameTextFieldEditingDidEnd(_ sender: Any) {
        guard let email = userNameTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty
            else {
                return
        }
        if (validatePassword(text: password)) {
            if (validateUserName(text: email)) {
                animateColorChange()
            }
        } else {
            return
        }
    }
    
    func validatePassword(text: String) -> Bool {
        let characters = text.characters.count
        if (characters > 8) {
            return true
        } else {
            return false
        }
    }
    
    func validateUserName(text: String) -> Bool {
        var result = false
        result = text.characters.contains { ["@"].contains($0) } && text.characters.contains { ["."].contains($0) }
        return result
    }
    
    @IBAction func passwordTextFieldEditingDidEnd(_ sender: Any) {
        guard let email = userNameTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty
            else {
                return
        }
        if (validateUserName(text: email)) {
            if (validatePassword(text: password)) {
                animateColorChange()
            }
        } else {
            return
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardDismissTapGesture == nil {
            keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            self.view.addGestureRecognizer(keyboardDismissTapGesture!)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if keyboardDismissTapGesture != nil {
            self.view.removeGestureRecognizer(keyboardDismissTapGesture!)
            keyboardDismissTapGesture = nil
        }
    }
    
    @objc func dismissKeyboard(sender: AnyObject) {
        userNameTextField?.resignFirstResponder()
        passwordTextField?.resignFirstResponder()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    @IBAction func loginButtonActionHandler(_ sender: UITextField) {
        
        // print("Username: " + userName +  " -- " + "Password: " + password)
        
        guard let email = userNameTextField.text,
            !email.isEmpty
            else {
                //animatePulse(userNameTextField)
                animateUserNameColorChange()
                return
        }
        
        guard let password = passwordTextField.text,
            !password.isEmpty
            else {
                //animatePulse(passwordTextField)
                animatePasswordColorChange()
                return
        }
        
        loginRequest(email: email, password: password)
    }
        
    func loginRequest (email: String, password: String) {
        
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
            .responseDecodableObject { [weak self](response: DataResponse<User>) in
                
                switch response.result {
                case .success(let user):
                    //print("DECODED: \(user)")
                    self?.defaults.set(password, forKey: "password")
                    self?.defaults.set(email, forKey: "email")
                    self?.showSuccess()
                    let bundle = Bundle.main
                    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
                    let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    homeViewController.user = user
                    self?.navigationController?.setViewControllers([homeViewController], animated: true)
                    
                case .failure(let error):
                    //self.showFailure()
                    print("FAILURE: \(error)")
                    let alertController = UIAlertController(title: "Login not successful.", message: "Wrong username or password. Try again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                    self?.present(alertController, animated: true, completion: nil)
                    self?.userNameTextField.text = ""
                    self?.passwordTextField.text = ""
                }
        }
    }
    
    @IBAction func registerButtonActionHandler(_ sender: Any) {
            let bundle = Bundle.main
            let storyboard = UIStoryboard(name: "Main", bundle: bundle)
            let registerViewController = storyboard.instantiateViewController(withIdentifier: "RegisterViewController")
            self.navigationController?.pushViewController(registerViewController, animated: true) 
        
        
        
         /* DispatchQueue.main.asyncAfter(deadline: .now()) {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.navigationController?.pushViewController(registerViewController, animated: true)
            } */
    }
    
    // MARK: Animations
    /*
    func animatePulse(_ sender: UITextField) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            let pulse = CASpringAnimation(keyPath: "transform.scale")
            pulse.duration = 0.3
            pulse.fromValue = 0.97
            pulse.toValue = 1.03
            pulse.autoreverses = true
            pulse.repeatCount = 1
            pulse.initialVelocity = 1
            pulse.damping = 1.0
            sender.layer.add(pulse, forKey: "pulse")
        } else {
            sender.layer.removeAnimation(forKey: "pulse")
        }
    } */
    
    func animatePasswordColorChange() {
        UIView.animate(
            withDuration: 1.0,
            delay: 0.3,
            options: [.autoreverse, .curveEaseInOut],
            animations: {
                self.passwordTextField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        },
            completion: { (finished) in
                self.passwordTextField.backgroundColor = UIColor.white
        })
    }
    
    func animateUserNameColorChange() {
        UIView.animate(
            withDuration: 1.0,
            delay: 0.3,
            options: [.autoreverse, .curveEaseInOut],
            animations: {
                self.userNameTextField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        },
            completion: { (finished) in
                self.userNameTextField.backgroundColor = UIColor.white
        })
    }
    
    
    func animateColorChange() {
        let color: UIColor = self.loginButton.backgroundColor!
        UIView.animate(
            withDuration: 1.2,
            delay: 0.4,
            options: [.autoreverse, .curveEaseInOut],
            animations: {
                self.loginButton.backgroundColor = UIColor.green.withAlphaComponent(0.6)
        },
            completion: { (finished) in
                self.loginButton.backgroundColor = color
        })
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
    }
    
}



