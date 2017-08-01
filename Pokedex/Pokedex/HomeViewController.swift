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
import Kingfisher

class HomeViewController: UIViewController {
    var user: User?
    var pokemon: Pokemon?
    var pokemons = [Pokemon]()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (pokemons.count > 0) {
            //orderPokemonsAlphabetically()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "ic-logout"),
            style: .plain,
            target: self,
            action: #selector(logout)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "ic-plus"),
            style: .plain,
            target: self,
            action: #selector(add)
        )
        
        navigationItem.title = "Pokedex"
        
        guard let user = user else { return }
        print(user)
        
        getPokemons()
    }
    
    // correct?
    @objc func add () {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let addPokemonViewController = storyboard.instantiateViewController(withIdentifier: "AddPokemonViewController") as! AddPokemonViewController
        addPokemonViewController.delegate = self
        addPokemonViewController.user = user
        self.navigationController?.pushViewController(addPokemonViewController, animated: true)
    }
    
    // correct?
    @objc func logout () {
        guard let user = user else { return }
        let tokenString = "Token token=" + user.authToken + ", email=" + user.email
        let headers: HTTPHeaders =  [
            "Content-Type": "text/html",
            "Authorization": tokenString
        ]
        
        Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/users/logout",
                method: .delete,
                headers: headers
            )
            .validate()
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                switch response.result {
                case .success:
                    let bundle = Bundle.main
                    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
                    let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    strongSelf.navigationController?.setViewControllers([loginViewController], animated: true)
                    
                case .failure(let error):
                    print("FAILURE: \(error)")
                }
            }
    }
    
    
    func getPokemons () {
        guard let user = user else { return }
        let tokenString = "Token token=" + user.authToken + ", email=" + user.email
        let headers = ["Authorization": tokenString]
        
        
        Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/pokemons",
                method: .get,
                headers: headers
            )
            .validate()
            .responseDecodableObject(keyPath: "data") { [weak self] (response: DataResponse<[Pokemon]>) in
                guard let strongSelf = self else { return }
                
                switch response.result {
                case .success(let pokemons):
                    strongSelf.pokemons = pokemons
                    //print(pokemons)
                    //pokemons.sort
                    //strongSelf.orderPokemonsAlphabetically()
                    strongSelf.tableView.reloadData()
                case .failure(let error):
                    print("FAILURE: \(error)")
                }
        }
    }
    
    func orderPokemonsAlphabetically() {
        pokemons = pokemons.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - TableView -
extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        /*
         struct Section {
             let name: String
             let items: [Int]
         }
         
         let sections: [Section]
         
         return sections.count
         */
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /* Number of rows in each section */
        return pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PokemonCell = tableView.dequeueReusableCell(
            withIdentifier: "PokemonCell",
            for: indexPath
            ) as! PokemonCell
        
        cell.pokemonImage?.kf.cancelDownloadTask()
        
        let pokemon = pokemons[indexPath.row]
        cell.label.text = pokemon.name
        cell.creationDateLabel.text = pokemon.createdAt
        cell.totalVoteCountLabel.text = String(describing: pokemon.totalVoteCount)
        guard let imageURL = pokemon.attributes.imageURL else { return cell }
        let url = URL(string: "https://pokeapi.infinum.co" + imageURL)
        cell.pokemonImage.kf.setImage(with: url)
        
        //cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.red : UIColor.white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        /* let row = indexPath.row
        print("Row: \(row)") */
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let pokemonDetailsViewController = storyboard.instantiateViewController(withIdentifier: "PokemonDetailsViewController") as! PokemonDetailsViewController
        pokemonDetailsViewController.pokemon = pokemons[indexPath.row]
        self.navigationController?.pushViewController(pokemonDetailsViewController, animated: true)
    }
    
}

extension HomeViewController: UITableViewDelegate {
    // change later
}

extension HomeViewController: NewPokemonDelegate {
    func setNewPokemon(_ pokemon: Pokemon?) {
        guard let pokemon = pokemon else { return }
        pokemons.insert(pokemon, at: 0)
        //pokemons.append(pokemon)
    }
}

