//
//  BookSampleData.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation

extension Book {
    static let bookTitles: [String] = [
        "The Alchemist",
        "The Great Rabbit",
        "The Very Hungry Caterpillar",
        "The Lion and the Witch",
        "Tiny Princess",
        "Once Upon A Comet",
        "The Enchanted Garden",
        "The Enchanted Forest",
        "Whispers of the Clockmaker",
        "The Last Quantum Garden",
        "Echoes from Tomorrow's Dawn",
        "Beyond the Crystal Horizon",
        "The Midnight Cartographer",
        "Secrets of the Paper Phoenix",
        "The Forgotten Algorithm",
        "Dreams in Binary",
        "The Alabaster Chronicle",
        "Shadows of the Brass Tower",
        "The Silent Mathematician",
        "Riddles of the Autumn King",
        "The Emerald Equations",
        "Mysteries of the Digital Forest",
        "The Prismatic Paradox",
        "Legends of the Neon Sage",
        "The Temporal Architect",
        "Whispers from the Data Stream",
        "The Quantum Librarian",
        "Chronicles of the Glass Desert"
    ]
 
    static func randomStatus() -> ReadStatus {
        let randomIndex = Int.random(in: 0..<ReadStatus.allCases.count)
        return ReadStatus.allCases[randomIndex]
    }
    
    static func randomBookTitle() -> String {
        let randomIndex = Int.random(in: 0..<Book.bookTitles.count)
        return Book.bookTitles[randomIndex]
    }
    
    static func randomBook() -> Book {
        let book = Book(title: Book.randomBookTitle(), author: Author.randomAuthor())
        book.readStatus = randomStatus()
        if book.readStatus != .notStarted {
            book.startDate = Date()
            if book.readStatus != .inProgress {
                book.endDate = Date()
            }
        }
        book.rating = Int.random(in: 1..<5)
        return book
    }
    
    static func randomBook(author: Author) -> Book {
        let book = Book.randomBook()
        book.author = author
        return book
    }
    
    static func randomBookArray(author: Author) -> [Book] {
        var books: [Book] = []
        for _ in 0..<Int.random(in: 1..<5) {
            books.append(Book.randomBook(author: author))
        }
        return books
    }
}
