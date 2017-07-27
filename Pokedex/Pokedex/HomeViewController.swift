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
            orderPokemonsAlphabetically()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    strongSelf.pokemons = pokemons.map { (pokemon: Pokemon) -> Pokemon in
                        return pokemon
                    }
                    strongSelf.orderPokemonsAlphabetically()
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
        
        let pokemon = pokemons[indexPath.row]
        cell.label.text = pokemon.name
        
        //cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.red : UIColor.white
        
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    // change later
}

extension HomeViewController: NewPokemonDelegate {
    func setNewPokemon(_ pokemon: Pokemon?) {
        guard let pokemon = pokemon else { return }
        pokemons.append(pokemon)
    }
}

