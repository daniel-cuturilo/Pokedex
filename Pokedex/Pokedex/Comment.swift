//
//  Comment.swift
//  Pokedex
//
//  Created by Daniel on 02/08/2017.
//  Copyright © 2017 Daniel Cuturilo. All rights reserved.
//

import Foundation

struct Comment: Codable {
    var data: [Data]
    var included: [Included]
}

struct Data: Codable {
    let id: String
    let type: String
    
    struct DataAttributes: Codable {
        let content: String
        let createdAt: String?
        
        enum CodingKeys: String, CodingKey {
            case createdAt = "created-at"
            case content
        }
    }
    
    struct DataRelationships: Codable {
        let author: DataAuthor
    }
    
    struct DataAuthor: Codable {
        let data: Data
    }
    
    struct Data: Codable {
        let id: String
        let type: String
    }
    
    private let attributes: DataAttributes
    private let relationships: DataRelationships
    
    var content: String  { return attributes.content }
    var createdAt: String  { return attributes.createdAt! }
    var commentId: String { return id }
    var userId: String { return relationships.author.data.id }
}

struct Included: Codable {
    let id: String
    let type: String
    
    struct DataAttributes: Codable {
        let email: String
        let username: String
    }
    
    private let attributes: DataAttributes
    
    var username: String  { return attributes.username }
}


struct PostedComment: Codable {
    let data: Data
    var included: [Included]
}
