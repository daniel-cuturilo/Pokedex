//
//  Pokemon.swift
//  Pokedex
//
//  Created by Daniel on 24/07/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import Foundation

struct Pokemon: Codable {
    let id: String
    let type: String
    
    struct PokeAttributes: Codable {
        let name: String
        let height: Float
        let weight: Float
        let gender: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case gender
            case height
            case weight
        }
    }
    
    let attributes: PokeAttributes
}
