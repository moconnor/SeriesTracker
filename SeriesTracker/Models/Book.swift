//
//  Book.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation
import SwiftData

@Model
class Book: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var seriesOrder: Int
    var readStatus: ReadStatus
    var startDate: Date?
    var endDate: Date?
    var rating: Int?
    var notes: String
    var series: Series?
    var author: Author?
    @Attribute(.externalStorage) var bookCover: Data?
    
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
    
    enum CodingKeys: String, CodingKey {
        case id, title, seriesOrder, readStatus, startDate, endDate, rating, notes, author
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID() // Default: new UUID
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Untitled" // Default: "Untitled"
        seriesOrder = try container.decodeIfPresent(Int.self, forKey: .seriesOrder) ?? 0 // Default: 0
        readStatus = try container.decodeIfPresent(ReadStatus.self, forKey: .readStatus) ?? .notStarted // Default: .unread
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) // Default: nil
        endDate = try container.decodeIfPresent(Date.self, forKey: .endDate) // Default: nil
        rating = try container.decodeIfPresent(Int.self, forKey: .rating) ?? 0 // Default: 0
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? "" // Default: empty string
        author = try container.decodeIfPresent(Author.self, forKey: .author) // Default: nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(seriesOrder, forKey: .seriesOrder)
        try container.encode(readStatus, forKey: .readStatus)
        try container.encodeIfPresent(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encode(notes, forKey: .notes)
        try container.encodeIfPresent(author, forKey: .author)
    }
}
