//
//  Series.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation
import SwiftData
import UniformTypeIdentifiers
import SwiftUI

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
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID() // Default: new UUID
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Untitled"
        books = try container.decodeIfPresent([Book].self, forKey: .books) ?? []
        status = try container.decodeIfPresent(ReadStatus.self, forKey: .status) ?? .notStarted
        author = try container.decodeIfPresent(Author.self, forKey: .author) ?? Author(name: "Unknown")
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
    
    func shouldHide() -> Bool {
        if status == .abandoned || status == .completed {
            return true
        }
        return false
    }
    
    func lastReadBookName() -> String? {

        if let oldestObject = books.min(by: { $0.endDate ?? Date() > $1.endDate ?? Date() }) {
          //  print("The oldest object is \(oldestObject.title) with date \(oldestObject.endDate ?? Date.distantFuture)")
            return oldestObject.title
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
    
    static func seriesJSON(series: [Series]) -> Data {
        var jsonData: Data = Data()
        do {
            jsonData = try Series.exportToJSON(series: series)
        } catch {
            print("Error exporting series: \(error)")
        }
        return jsonData
    }
    
}

struct JSONFile: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var series: [Series] = []
    init(series: [Series]) {
        self.series = series
    }
    
    init(configuration: ReadConfiguration) throws {
        print("read config")
        // not used for reading
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try Series.exportToJSON(series: series)
        return FileWrapper(regularFileWithContents: data)
    }

}

