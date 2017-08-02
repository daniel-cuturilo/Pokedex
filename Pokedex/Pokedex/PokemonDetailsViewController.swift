//
//  PokemonDetailsViewController.swift
//  Pokedex
//
//  Created by Daniel on 01/08/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import CodableAlamofire
import PKHUD

class PokemonDetailsViewController: UIViewController {
    var pokemon: Pokemon?
    var user: User?
    var likePressed: Bool?
    var dislikePressed: Bool?
    
    weak var delegate: PokemonDetailsViewControllerDelegate?
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var pokemonDescription: UITextView!
    @IBOutlet weak var pokemonName: UILabel!
    @IBOutlet weak var pokemonImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    @IBAction func dislikeButtonActionHandler(_ sender: Any) {
        guard let user = user else { return }
        guard let pokemon = pokemon else { return }
        let tokenString = "Token token=" + user.authToken + ", email=" + user.email
        let headers =  ["Authorization": tokenString]
        print(pokemon)
        Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/pokemons/" + pokemon.id + "/downvote",
                method: .post,
                headers: headers
            )
            .validate()
            .responseDecodableObject(keyPath: "data") { [weak self] (response: DataResponse<Pokemon>) in
                guard let strongSelf = self else { return }
                switch response.result {
                case .success(let pokemon):
                    strongSelf.pokemon = pokemon
                    strongSelf.delegate?.updatePokemon(pokemon)
                    print("Disliked")
                    print(pokemon)
                case .failure(let error):
                    print("FAILURE: \(error)")
                }
        }
    }
    
    @IBAction func likeButtonActionHandler(_ sender: Any) {
        guard let user = user else { return }
        guard let pokemon = pokemon else { return }
        let tokenString = "Token token=" + user.authToken + ", email=" + user.email
        let headers =  ["Authorization": tokenString]
        print(pokemon)
        Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/pokemons/" + pokemon.id + "/upvote",
                method: .post,
                headers: headers
            )
            .responseDecodableObject(keyPath: "data") { [weak self] (response: DataResponse<Pokemon>) in
                guard let strongSelf = self else { return }
                switch response.result {
                case .success(let pokemon):
                    strongSelf.pokemon = pokemon
                    strongSelf.delegate?.updatePokemon(pokemon)
                    print("Liked")
                    print(pokemon)
                case .failure(let error):
                    print("FAILURE: \(error)")
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let pokemon = pokemon else { return }
        heightLabel.text = String(describing: pokemon.height)
        genderLabel.text = pokemon.gender
        weightLabel.text = String(describing: pokemon.weight)
        pokemonDescription.text = pokemon.description
        pokemonName.text = pokemon.name
        setImage()
        
    }
    
    func setImage() {
        guard let imageURL = pokemon?.attributes.imageURL else { return }
        let url = URL(string: "https://pokeapi.infinum.co" + imageURL)
        pokemonImage.kf.setImage(with: url)
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

protocol PokemonDetailsViewControllerDelegate: class {
    func updatePokemon(_ pokemon: Pokemon?)
}
