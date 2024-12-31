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
    @Relationship(deleteRule: .cascade) var books: [Book]
    var status: ReadStatus = ReadStatus.notStarted
    var author: Author
    
    init(name: String, author: Author, books: [Book] = []) {
        self.id = UUID()
        self.name = name
        self.books = books
        self.author = author
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
            print("The oldest object is \(oldestObject.title) with date \(oldestObject.endDate ?? Date.distantFuture)")
            return oldestObject.endDate
        } else {
            print("The array is empty")
            return nil
        }
    }
    
}
  

