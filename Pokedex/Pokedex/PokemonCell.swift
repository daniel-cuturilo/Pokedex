///Users/daniel/Desktop/isa-2017-ios-daniel-cuturilo/Pokedex/Pokedex/PokemonDetailsViewController.swift
//  PokemonCell.swift
//  Pokedex
//
//  Created by Daniel on 25/07/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import UIKit

class PokemonCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pokemonImage: UIImageView!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var totalVoteCountLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pokemonImage.layer.cornerRadius = self.pokemonImage.bounds.size.width / 2.0
        self.pokemonImage.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        // Clear up image view
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
