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
import PKHUD

class HomeViewController: UIViewController {
    var user: User?
    var pokemon: Pokemon?
    var pokemons = [Pokemon]()
    var lastClickedRow = Int()
    
    lazy var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var toggleSort: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (pokemons.count > 0) {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = true
        
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
        
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
    
    @IBAction func segmentedControlIndexChanged(_ sender: Any) {
        selectedSegmentIndexAction()
    }
    
    func selectedSegmentIndexAction () {
        switch toggleSort.selectedSegmentIndex {
        case 0:
            pokemons.sort { $0.createdAt > $1.createdAt }
        case 1:
            pokemons.sort { $0.totalVoteCount > $1.totalVoteCount }
        case 2:
            pokemons.sort { $0.name.lowercased() < $1.name.lowercased() }
        default:
            break
        }
        self.tableView.reloadData()
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
                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                    UserDefaults.standard.synchronize()
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
                    switch strongSelf.toggleSort.selectedSegmentIndex {
                    case 0:
                        strongSelf.pokemons = pokemons.sorted { $0.createdAt > $1.createdAt }
                    case 1:
                        strongSelf.pokemons = pokemons.sorted { $0.totalVoteCount > $1.totalVoteCount }
                    case 2:
                        strongSelf.pokemons = pokemons.sorted { $0.name.lowercased() < $1.name.lowercased() }
                    default:
                        break
                    }
                   strongSelf.tableView.reloadData()
                case .failure(let error):
                    print("FAILURE: \(error)")
                }
        }
    }
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        getPokemons()
        refreshControl.endRefreshing()
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
        let date = convertDate(date: pokemon.createdAt)
        
        cell.label.text = pokemon.name
        cell.creationDateLabel.text = date
        cell.totalVoteCountLabel.text = String(describing: pokemon.totalVoteCount)
        
        guard let imageURL = pokemon.attributes.imageURL else { return cell }
        let url = URL(string: "https://pokeapi.infinum.co" + imageURL)
        cell.pokemonImage.kf.setImage(with: url)
        
        //cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.red : UIColor.white
        
        return cell
    }
    
    func convertDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = dateFormatter.date(from: date) else { return "" }
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        /* let row = indexPath.row
        print("Row: \(row)") */
        
        lastClickedRow = indexPath.row
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let pokemonDetailsViewController = storyboard.instantiateViewController(withIdentifier: "PokemonDetailsViewController") as! PokemonDetailsViewController
        pokemonDetailsViewController.pokemon = pokemons[indexPath.row]
        pokemonDetailsViewController.user = user
        pokemonDetailsViewController.delegate = self
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

// update pokemon according to actions in PokemonDetailsViewController (like, dislike)
extension HomeViewController: PokemonDetailsViewControllerDelegate {
    func updatePokemon (_ pokemon: Pokemon?) {
        guard let pokemon = pokemon else { return }
        pokemons[lastClickedRow] = pokemon
        selectedSegmentIndexAction()
    }
}

