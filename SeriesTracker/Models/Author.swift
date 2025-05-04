//
//  Author.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation
import SwiftData

@Model
class Author: Codable, Hashable {
    var id: UUID
    var name: String
    //@Attribute(.unique) var name: String   // ← make each name unique in the SQLite schema
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }

    enum CodingKeys: String, CodingKey {
        case id, name//, books
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
}
