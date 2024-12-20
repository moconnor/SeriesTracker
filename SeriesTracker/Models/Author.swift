//
//  Author.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation
import SwiftData

@Model
class Author {
    var id: UUID
    var name: String
    var books: [Book]
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.books = []
    }
}
