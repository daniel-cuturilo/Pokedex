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
        let imageURL: String?
        let height: Float
        let weight: Float
        let gender: String
        let description: String
        let createdAt: String
        let totalVoteCount: Int
        
        enum CodingKeys: String, CodingKey {
            case imageURL = "image-url"
            case createdAt = "created-at"
            case totalVoteCount = "total-vote-count"
            case name
            case gender
            case height
            case weight
            case description
        }
    }
    
    let attributes: PokeAttributes
    
    var name: String  { return attributes.name }
    var height: Float  { return attributes.height }
    var weight: Float  { return attributes.weight }
    var gender: String  { return attributes.gender }
    var description: String  { return attributes.description }
    var createdAt: String { return attributes.createdAt}
    var totalVoteCount: Int { return attributes.totalVoteCount}
}
