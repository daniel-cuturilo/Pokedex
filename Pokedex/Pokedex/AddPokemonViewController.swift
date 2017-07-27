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

class AddPokemonViewController: UIViewController, Progressable {
    var user: User?
    weak var delegate: NewPokemonDelegate?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    // upload pokemon on API
    @IBAction func saveButtonActionHandler(_ sender: Any) {
        guard let user = user else { return }
        let tokenString = "Token token=" + user.authToken + ", email=" + user.email
        let headers =  ["Authorization": tokenString]
        
        guard
            let name = nameTextField.text,
            !name.isEmpty
            else {
                let alertController = UIAlertController(title: "Try again.", message: "You need to enter the name.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
        }
        
        let height = heightTextField.text
        let weight = weightTextField.text
        let description = descriptionTextField.text
        
        // change
        let attributes = [
            "name": name,
            "height": height,
            "weight": weight,
            "gender_id":"1",
            "base_experience":"30",
            "description": description
        ]
        
        // add image picker
        Alamofire
            .upload(multipartFormData: { multipartFormData in
                multipartFormData.append(UIImagePNGRepresentation(UIImage(named: "charmander")!)!,
                                         withName: "data[attributes][image]",
                                         fileName: "image.png",
                                         mimeType: "image/png")
                for (key, value) in attributes {
                    multipartFormData.append((value?.data(using: .utf8)!)!, withName: "data[attributes][" + key + "]")
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
        uploadRequest.responseDecodableObject(keyPath: "data") { (response: DataResponse<Pokemon>) in
            switch response.result {
            case .success(let pokemon):
                print("DECODED: \(pokemon)")
                self.delegate?.setNewPokemon(pokemon)
                self.showSuccess()
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("FAILURE: \(error)")
                self.showFailure()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

protocol NewPokemonDelegate: class {
    func setNewPokemon (_ pokemon: Pokemon?)
}
