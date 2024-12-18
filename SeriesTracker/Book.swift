//
//  Book.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation
import SwiftData

enum ReadStatus: String, Codable, CaseIterable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
    case abandoned = "Abandoned"
}

@Model
class Book {
    var id: UUID
    var title: String
    var seriesOrder: Int
    var readStatus: ReadStatus
    var startDate: Date?
    var endDate: Date?
    var rating: Int? // Optional rating out of 5
    var notes: String
    var series: Series?
    var author: Author?
    
    init(title: String,
         seriesOrder: Int = 1,
         author: Author? = nil,
         readStatus: ReadStatus = .notStarted) {
        self.id = UUID()
        self.title = title
        self.seriesOrder = seriesOrder
        self.readStatus = readStatus
        self.startDate = nil
        self.endDate = nil
        self.rating = nil
        self.notes = ""
        self.author = author
    }
    
    // Computed property for overall read progress
    var isRead: Bool {
        return readStatus == .completed
    }
}
