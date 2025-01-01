//
//  Series.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation
import SwiftData

@Model
class Series: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var books: [Book]
    var status: ReadStatus = ReadStatus.notStarted
    var author: Author
    
    init(name: String, author: Author, books: [Book] = []) {
        self.id = UUID()
        self.name = name
        self.books = books
        self.author = author
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, books, status, author
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        books = try container.decode([Book].self, forKey: .books)
        status = try container.decode(ReadStatus.self, forKey: .status)
        author = try container.decode(Author.self, forKey: .author)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(books, forKey: .books)
        try container.encode(status, forKey: .status)
        try container.encode(author, forKey: .author)
    }

    func readStatus() -> ReadStatus {
        var status: ReadStatus = .inProgress
        if books.allSatisfy({$0.readStatus == .notStarted}) {
            status = .notStarted
        } else if books.allSatisfy({$0.readStatus == .completed}) {
            status = .completed
        } else if books.allSatisfy({$0.readStatus == .abandoned}) {
            status = .abandoned
        }
        return status
    }
    
    func lastReadBook() -> Date? {

        if let oldestObject = books.min(by: { $0.endDate ?? Date() > $1.endDate ?? Date() }) {
          //  print("The oldest object is \(oldestObject.title) with date \(oldestObject.endDate ?? Date.distantFuture)")
            return oldestObject.endDate
        } else {
          //  print("The array is empty")
            return nil
        }
    }
    
    static func exportToJSON(series: [Series]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(series)
    }
}


