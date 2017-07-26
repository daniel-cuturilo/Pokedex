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
    var pokemons = [Pokemon]()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let user = user else { return }
        print(user)
        getPokemons()
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
                case .success(var pokemons):
                    pokemons = pokemons.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                    
                    // pokemons = strongSelf.pokemons.map { (pokemon: Pokemon) -> Pokemon in
                     //   return pokemon
                    pokemons.forEach({ pokemon in
                        strongSelf.pokemons.append(pokemon)
                    })
                    strongSelf.tableView.reloadData()
                    //print("DECODED: \(pokemons)")
                    
                case .failure(let error):
                    print("FAILURE: \(error)")
                }
        }
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
