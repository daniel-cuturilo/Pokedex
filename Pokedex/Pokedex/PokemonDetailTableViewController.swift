//
//  PokemonDetailTableViewController.swift
//  Pokedex
//
//  Created by Daniel on 02/08/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import Kingfisher

class PokemonDetailTableViewController: UITableViewController, Progressable, UITextFieldDelegate {
    var pokemon: Pokemon?
    var user: User?
    var comments = Comment(data: [], included: [])
    var likePressed: Bool?
    var dislikePressed: Bool?
    let alertController = UIAlertController(title: "Add New Comment", message: "", preferredStyle: .alert)
    
    var shouldAnimateFirstRow = false
    
    var keyboardDismissTapGesture: UIGestureRecognizer?
    
    weak var delegate: PokemonDetailTableViewControllerDelegate?
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var pokemonName: UILabel!
    @IBOutlet weak var pokemonDescription: UITextView!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var rectangle: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "ic-edit"),
            style: .plain,
            target: self,
            action: #selector(edit)
        )
        
        imageView.alpha = 0
        UIView.animate(withDuration: 1.0) {
            self.imageView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.75, delay: 0, options: [.curveEaseOut], animations: {
            self.pokemonDescription.center.y -= self.view.bounds.height - 625
        }, completion: nil)
        
        
        guard let pokemon = pokemon else { return }
        heightLabel.text = String(describing: pokemon.height)
        genderLabel.text = pokemon.gender
        weightLabel.text = String(describing: pokemon.weight)
        likesLabel.text = String(describing: pokemon.totalVoteCount)
        pokemonDescription.text = pokemon.description
        pokemonName.text = pokemon.name
        setImage()
        getComments()
        setBorders(textField: commentTextField)
        
        commentTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        commentTextField?.resignFirstResponder()
    }
    
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async {
            self.setTextViewSize()
        }
    }
    
    func setTextViewSize () {
        let fixedWidth = pokemonDescription.frame.size.width
        let initialHeight = pokemonDescription.frame.size.height
        pokemonDescription.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newSize = pokemonDescription.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newHeightInitial = newSize.height
        if (newSize.height > initialHeight) {
            newSize.height = initialHeight
        }
        var newFrameText = pokemonDescription.frame
        newFrameText.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        pokemonDescription.frame = newFrameText;
        var newFrameRectangle = rectangle.frame
        if (newHeightInitial > initialHeight) {
            newFrameRectangle.size = CGSize(width: rectangle.frame.size.width, height: pokemonDescription.frame.size.height + pokemonName.frame.size.height)
        } else {
            newFrameRectangle.size = CGSize(width: rectangle.frame.size.width, height: pokemonDescription.frame.size.height + pokemonName.frame.size.height - 15)
        }
        rectangle.frame = newFrameRectangle
        self.view.layoutIfNeeded()
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
    
    func setImage() {
        guard let imageURL = pokemon?.attributes.imageURL else { return }
        let url = URL(string: "https://pokeapi.infinum.co" + imageURL)
        imageView.kf.setImage(with: url)
    }
    
    func getComments() {
        getCommentsRequest()
    }
    
    @IBAction func likeButtonActionHandler(_ sender: UIButton) {
        likeRequest()
        likeAnimation(sender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            guard let pokemon = self.pokemon else { return }
            self.likesLabel.text = String(describing: pokemon.totalVoteCount)
        }
    }
    
    @IBAction func dislikeButtonActionHandler(_ sender: UIButton) {
        dislikeRequest()
        likeAnimation(sender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            guard let pokemon = self.pokemon else { return }
            self.likesLabel.text = String(describing: pokemon.totalVoteCount)
        }
    }
    
    @IBAction func commentButtonActionHandler(_ sender: Any) {
        if (commentTextField.text!.isEmpty) {
            let alertController = UIAlertController(title: "Add New Comment", message: "", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak self] alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                guard let text = textField.text else {
                    return
                }
                self?.newCommentRequest(text: text)
                self?.alertController.dismiss(animated: true, completion: nil)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter your comment here!"
            }
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            guard let text = commentTextField.text else {
                return
            }
            self.newCommentRequest(text: text)
            commentTextField.text = ""
        }
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
    func getCommentsRequest() {
        guard let user = user else { return }
        guard let pokemon = pokemon else { return }
        let tokenString = "Token token=" + user.authToken + ", email=" + user.email
        let headers =  ["Authorization": tokenString]
        print(pokemon)
        Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/pokemons/" + pokemon.id + "/comments",
                method: .get,
                headers: headers
            )
            .responseDecodableObject { [weak self] (response: DataResponse<Comment>) in
                guard let strongSelf = self else { return }
                switch response.result {
                case .success(let comments):
                    strongSelf.comments = comments
                    strongSelf.tableView.reloadData()
                case .failure( _):
                    print("No comments or failure in request.")
                }
        }
    }
    
    
    func getCommentsSize() -> Int {
        return self.comments.data.count
    }
    
    func newCommentRequest (text: String) {
        guard let user = user else { return }
        guard let pokemon = self.pokemon else { return }
        let tokenString = "Token token=" + user.authToken + ", email=" + user.email
        let headers =  ["Authorization": tokenString]
        let attributes = [
            "content": text
        ]
        let URL = "https://pokeapi.infinum.co//api/v1/pokemons/" + pokemon.id + "/comments"
        
        Alamofire
            .upload(multipartFormData: { multipartFormData in
                for (key, value) in attributes {
                    multipartFormData.append((value.data(using: .utf8)!), withName: "data[attributes][" + key + "]")
                }
            }, to: URL, method: .post, headers: headers) { [weak self] result in
                switch result {
                case .success(let uploadRequest, _, _):
                    uploadRequest.responseDecodableObject { [weak self] (response: DataResponse<PostedComment>) in
                        guard let strongSelf = self else { return }
                        switch response.result {
                        case .success(let comment):
                            print("DECODED: \(comment)")
                            strongSelf.tableView.beginUpdates()
                            let commentsSize = strongSelf.getCommentsSize()
                            strongSelf.comments.data.insert(comment.data, at: commentsSize)
                            strongSelf.comments.included.insert(comment.included[0], at: 0)
                            let indexPath = IndexPath(row: commentsSize, section: 0)
                            strongSelf.tableView.insertRows(at: [indexPath], with: .none)
                            strongSelf.tableViewScrollToBottom(animated: true)
                            strongSelf.tableView.endUpdates()
                            strongSelf.showSuccess()
                        case .failure(let error):
                            print("FAILURE: \(error)")
                            self?.showFailure()
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
    }
    
    func likeRequest () {
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
    
    func dislikeRequest() {
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
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommentsCell = tableView.dequeueReusableCell(
            withIdentifier: "CommentsCell",
            for: indexPath
            ) as! CommentsCell
        
        let comment = comments.data[indexPath.row]
        
        let date = DateFormatter.convertDate(date: comment.createdAt)
        cell.date.text = date
        cell.date.sizeToFit()
        
        cell.comment.text = comment.content
        cell.comment.sizeToFit()
        
        let userId = comment.userId
        let users = comments.included
        guard let index = users.index(where: { $0.id == userId}) else { return cell }
        cell.name.text = users[index].username
        cell.name.sizeToFit()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        animateIn(cell: cell, withDelay: 0.1)
        
    }
    
    func animateIn(cell: UITableViewCell, withDelay delay: TimeInterval) {
        let initialScale: CGFloat = 1.2
        let duration: TimeInterval = 0.5
        
        cell.alpha = 0.0
        cell.layer.transform = CATransform3DMakeScale(initialScale, initialScale, 1)
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseOut, animations: {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }, completion: nil)
    }
    
    
    func likeAnimation(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5,
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                            sender.transform = CGAffineTransform.identity
                        })
        }
        )}
    
    
    @objc func edit () {
        let alertController = UIAlertController(title: "Edit Pokemon Name", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak self] alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            guard let text = textField.text else {
                return
            }
            self?.editPokemonNameRequest(text: text)
            
            self?.showSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self?.pokemonName.text = self?.pokemon?.name
            }
            
            self?.alertController.dismiss(animated: true, completion: nil)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
        })
        
        alertController.addTextField { [weak self] (textField : UITextField!) -> Void in
            textField.text = self?.pokemon?.name
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func editPokemonNameRequest(text: String) {
        guard let user = user else { return }
        guard let pokemon = pokemon else { return }
        let tokenString = "Token token=" + user.authToken + ", email=" + user.email
        let headers =  ["Authorization": tokenString]
        let attributes = [
            "name": text
        ]
        let URL = "https://pokeapi.infinum.co//api/v1/pokemons/" + pokemon.id
        
        Alamofire
            .upload(multipartFormData: { multipartFormData in
                for (key, value) in attributes {
                    multipartFormData.append((value.data(using: .utf8)!), withName: "data[attributes][" + key + "]")
                }
            }, to: URL, method: .put, headers: headers) { [weak self] result in
                switch result {
                case .success(let uploadRequest, _, _):
                    uploadRequest.responseDecodableObject(keyPath: "data") { [weak self] (response: DataResponse<Pokemon>) in
                        guard let strongSelf = self else { return }
                        switch response.result {
                        case .success(let pokemon):
                            print("DECODED: \(pokemon)")
                            strongSelf.pokemon = pokemon
                        case .failure(let error):
                            print("FAILURE: \(error)")
                            strongSelf.showFailure()
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
    }

}

protocol PokemonDetailTableViewControllerDelegate: class {
    func updatePokemon(_ pokemon: Pokemon?)
}
