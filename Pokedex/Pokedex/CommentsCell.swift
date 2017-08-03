//
//  CommentsCell.swift
//  Pokedex
//
//  Created by Daniel on 02/08/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func layoutSubviews() {
        name.font = UIFont.boldSystemFont(ofSize: 16.0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
