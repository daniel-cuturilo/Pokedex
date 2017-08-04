//
//  AddPokemonViewController.swift
//  Pokedex
//
//  Created by Daniel on 27/07/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire

class AddPokemonViewController: UIViewController, Progressable, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var user: User?
    weak var delegate: NewPokemonDelegate?
    var chosenImage: UIImage?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func imageButtonActionHandler(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self 
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = chosenImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // upload pokemon on API
    @IBAction func saveButtonActionHandler(_ sender: Any) {
        guard let user = user else { return }
        let tokenString = "Token token=" + user.authToken + ", email=" + user.email
        let headers =  ["Authorization": tokenString]
        
        guard
            let name = nameTextField.text,
            let height = heightTextField.text,
            let weight = weightTextField.text,
            let description = descriptionTextField.text,
            !name.isEmpty,
            !height.isEmpty,
            !weight.isEmpty,
            !description.isEmpty
            else {
                let alertController = UIAlertController(title: "Try again.", message: "You didn't enter some data.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
        }
        
        // change?
        let attributes = [
            "name": name,
            "height": height,
            "weight": weight,
            "order":"19",
            "is_default":"1",
            "gender_id":"1",
            "base_experience":"30",
            "description": description
        ]
        
        Alamofire
            .upload(multipartFormData: { multipartFormData in
                multipartFormData.append(UIImageJPEGRepresentation(self.chosenImage!, 0.5)!,
                                         withName: "data[attributes][image]",
                                         fileName: "image.jpeg",
                                         mimeType: "image/jpeg")
                for (key, value) in attributes {
                    multipartFormData.append((value.data(using: .utf8)!), withName: "data[attributes][" + key + "]")
                }
            }, to: "https://pokeapi.infinum.co/api/v1/pokemons", method: .post, headers: headers) { [weak self] result in
                switch result {
                case .success(let uploadRequest, _, _):
                    self?.processUploadRequest(uploadRequest)
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
    }
    
    private func processUploadRequest(_ uploadRequest: UploadRequest) {
        uploadRequest.responseDecodableObject(keyPath: "data") { [weak self] (response: DataResponse<Pokemon>) in
            switch response.result {
            case .success(let pokemon):
                print("DECODED: \(pokemon)")
                self?.delegate?.setNewPokemon(pokemon)
                self?.showSuccess()
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("FAILURE: \(error)")
                self?.showFailure()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldIcons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTextFieldIcons () {
        let iconWidth = 24
        let iconHeight = 24
        
        let nameImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight))
        let descriptionImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight))
        let heightImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight))
        let weightImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight))
        
        
        nameTextField.leftViewMode = UITextFieldViewMode.always
        descriptionTextField.leftViewMode = UITextFieldViewMode.always
        weightTextField.leftViewMode = UITextFieldViewMode.always
        heightTextField.leftViewMode = UITextFieldViewMode.always
        
        
        nameImageView.image = UIImage(named: "ic-mail")
        descriptionImageView.image = UIImage(named: "ic-sheet")
        
        nameTextField.leftView = nameImageView
        descriptionTextField.leftView = descriptionImageView
        weightTextField.leftView = weightImageView
        heightTextField.leftView = heightImageView
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

protocol NewPokemonDelegate: class {
    func setNewPokemon (_ pokemon: Pokemon?)
}
