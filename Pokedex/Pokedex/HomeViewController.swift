//
//  HomeViewController.swift
//  Pokedex
//
//  Created by Daniel on 19/07/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire

class HomeViewController: UIViewController {
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(user)
        getPokemons()
    }
    
    func getPokemons () {
        let tokenString = "Token token=" + user.authToken + ", email=" + user.email
        let headers = ["Authorization": tokenString]
        
        
        Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/pokemons",
                method: .get,
                headers: headers
            )
            .validate()
            .responseDecodableObject(keyPath: "data") { (response: DataResponse<[Pokemon]>) in
                
                switch response.result {
                case .success(let pokemons):
                    print("DECODED: \(pokemons)")
                case .failure(let error):
                    print("FAILURE: \(error)")
                }
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
