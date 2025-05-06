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
    var status: SeriesStatus = SeriesStatus.inProgress
    var author: Author
    var notes: String

    // TODO:  I sorta overrode both this var and the readStatus var farther below with the manually set seriesStatus
    //        I need to think about how best to use these or stick with manual settings
    
//    var seriesStatus: ReadStatus {
//        var status: ReadStatus = .inProgress
//        if books.allSatisfy({$0.readStatus == .notStarted}) {
//            status = .notStarted
//        } else if books.allSatisfy({$0.readStatus == .completed}) {
//            status = .completed
//        } else if books.allSatisfy({$0.readStatus == .abandoned}) {
//            status = .abandoned
//        }
//        return status
//    }
    
    init(name: String, author: Author, books: [Book] = []) {
        self.id = UUID()
        self.name = name
        self.books = books
        self.author = author
        self.notes = ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, books, status, author, notes
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID() // Default: new UUID
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Untitled"
        books = try container.decodeIfPresent([Book].self, forKey: .books) ?? []
        status = try container.decodeIfPresent(SeriesStatus.self, forKey: .status) ?? .inProgress
        author = try container.decodeIfPresent(Author.self, forKey: .author)  ?? Author(name: "Couldn't Decode Series Author, FIX!")
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? "" // Default: empty string
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(books, forKey: .books)
        try container.encode(self.status, forKey: .status)
        try container.encode(author, forKey: .author)
        try container.encode(notes, forKey: .notes)
    }

//    func readStatus() -> ReadStatus {
//        var status: ReadStatus = .inProgress
//        if books.allSatisfy({$0.readStatus == .notStarted}) {
//            status = .notStarted
//        } else if books.allSatisfy({$0.readStatus == .completed}) {
//            status = .completed
//        } else if books.allSatisfy({$0.readStatus == .abandoned}) {
//            status = .abandoned
//        }
//        return status
//    }

    func containsNotStartedBooks() -> Bool {
        books.contains(where: {$0.readStatus == .notStarted})
    }
    
    func lastReadBook() -> Date? {
//        let completedBooks = books.filter({$0.readStatus == .completed})
//        for abook in completedBooks {
//            print("'\(abook.title)' was completed on \(abook.endDate ?? Date.distantFuture)")
//        }
        if let oldestObject = books.filter({$0.readStatus == .completed}).min(by: { $0.endDate ?? Date() > $1.endDate ?? Date() }) {
           //print("The oldest completed object is \(oldestObject.title) with date \(oldestObject.endDate ?? Date.distantFuture)")
            return oldestObject.endDate
        } else {
          //print("The array is empty")
            return nil
        }
    }
    
    func contains(bookName:String) -> Bool {
       return books.contains(where: {$0.title == bookName})
    }
    
    func shouldHide() -> Bool {
        if status == .abandoned || status == .completed || status == .notASeries {
            return true
        }
        return false
    }
    
    func lastReadBookName() -> String? {
        if let oldestObject = books.filter({$0.readStatus == .completed}).min(by: { $0.endDate ?? Date() > $1.endDate ?? Date() }) {
          //  print("The oldest object is \(oldestObject.title) with date \(oldestObject.endDate ?? Date.distantFuture)")
            return oldestObject.title
        } else {
          //  print("The array is empty")
            return nil
        }
    }
    
    func nextBookToRead() -> String {
        var candidate = ""
        if let nextBook = books.filter({$0.readStatus == .notStarted}).first {
            candidate = nextBook.title
        }
        
        return candidate
    }
    
    static func exportToJSON(series: [Series]) throws -> Data {
        
        // Convert to DTO
        let dtos = series.map { s in
          SeriesDTO(
            name: s.name,
            status: s.status,
            authorname: s.author.name,
            notes: s.notes,
            books: s.books.map { b in
              BookDTO(
                title: b.title,
                seriesOrder: b.seriesOrder,
                readStatus: b.readStatus,
                startDate: b.startDate,
                endDate: b.endDate,
                rating: b.rating,
                notes: b.notes,
                authorname: b.author?.name ?? "No Author")
            }
          )
        }
        
        
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        //return try encoder.encode(series)
        return try encoder.encode(dtos)
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

struct SeriesDTO: Codable {
    var name: String
//    @Relationship(deleteRule: .cascade) var books: [Book]
    var status: SeriesStatus
//    var author: Author
    var authorname: String
    var notes: String
    var books: [BookDTO]
}
