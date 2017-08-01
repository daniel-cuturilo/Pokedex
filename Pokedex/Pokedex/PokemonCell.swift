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
