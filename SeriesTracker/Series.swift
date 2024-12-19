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
    var status: ReadStatus = ReadStatus.notStarted
    var author: Author
    
    init(name: String, author: Author, books: [Book] = []) {
        self.id = UUID()
        self.name = name
        self.books = books
       // self.readStatus = .notStarted
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
    
}
  

