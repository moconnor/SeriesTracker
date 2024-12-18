//
//  BookSampleData.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation

extension Book {
    static let samples: [Book] = [
        Book(title: "The Alchemist", author: Author.randomAuthor()),
        Book(title: "The Great Rabbit", author: Author.randomAuthor()),
        Book(title: "The Very Hungry Caterpillar", author: Author.randomAuthor()),
        Book(title: "The Lion and the Witch", author: Author.randomAuthor()),
        Book(title: "Tiny Princess", author: Author.randomAuthor()),
        Book(title: "Once Upon A Comet", author: Author.randomAuthor()),
        Book(title: "Book 01", author: Author.randomAuthor()),
        Book(title: "Book 02", author: Author.randomAuthor()),
        Book(title: "Book 03", author: Author.randomAuthor()),
        Book(title: "Book 04", author: Author.randomAuthor()),
        Book(title: "Book 05", author: Author.randomAuthor()),
        Book(title: "Book 06", author: Author.randomAuthor()),
        Book(title: "Book 07", author: Author.randomAuthor()),
        Book(title: "Book 08", author: Author.randomAuthor()),
        Book(title: "Book 09", author: Author.randomAuthor()),
        Book(title: "Book 10", author: Author.randomAuthor()),
        Book(title: "Book 11", author: Author.randomAuthor()),
        Book(title: "Book 12", author: Author.randomAuthor()),
        Book(title: "Book 13", author: Author.randomAuthor()),
        Book(title: "Book 14", author: Author.randomAuthor()),
        Book(title: "Book 15", author: Author.randomAuthor()),
        Book(title: "Book 16", author: Author.randomAuthor()),
        Book(title: "Book 17", author: Author.randomAuthor()),
        Book(title: "Book 18", author: Author.randomAuthor()),
        Book(title: "Book 19", author: Author.randomAuthor()),
        Book(title: "Book 20", author: Author.randomAuthor())
    ]
 
    static func randomStatus() -> ReadStatus {
        let randomIndex = Int.random(in: 0..<ReadStatus.allCases.count)
        return ReadStatus.allCases[randomIndex]
    }
    static func randomBook() -> Book {
        let randomIndex = Int.random(in: 0..<Book.samples.count)
        return Book.samples[randomIndex]
    }
    
    static func randomBook(series: Series) -> Book {
        let randomIndex = Int.random(in: 1..<Book.samples.count)
        let book = Book.samples[randomIndex]
        book.author = series.author
        book.readStatus = randomStatus()
        return book
    }
}
