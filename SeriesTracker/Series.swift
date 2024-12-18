//
//  Series.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation
import SwiftData

@Model
class Series {
    var id: UUID
    var name: String
    var books: [Book]
    var isCompleted: Bool
    var author: Author?
    
    init(name: String, author: Author? = nil, books: [Book] = []) {
        self.id = UUID()
        self.name = name
        self.books = books
        self.isCompleted = false
        self.author = author
    }
    
    // Computed property to check series completion
    var computeSeriesStatus: Bool {
        return books.allSatisfy { $0.readStatus == .completed }
    }
    
    // Update series status based on book statuses
    func updateSeriesStatus() {
        isCompleted = computeSeriesStatus
    }
}
