//
//  BookRowView.swift
//  BookSeries
//
//  Created by Michael O'Connor using Claude on 12/19/24.
//

import SwiftUI

struct BookRowView: View {
    let bookInfo: BookInfo
    @State private var importBook: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(bookInfo.title)
                    .font(.headline)
                Spacer()
                Button {
                    importBook.toggle()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
            
            if let authors = bookInfo.authors {
                Text("By: \(authors.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let publishedDate = bookInfo.publishedDate {
                Text("Published: \(publishedDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let description = bookInfo.description {
                Text(description)
                    .font(.caption)
                    .lineLimit(3)
                    .padding(.top, 4)
            }
            
            if let seriesInfo = bookInfo.seriesInfo?.bookDisplayNumber {
                Text("Book \(seriesInfo) in series")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $importBook) {
            let authorName = bookInfo.authors?.first ?? "Unknown"
            let newBook = Book(title: bookInfo.title, author: Author(name: authorName))
            ImportBookView(book: newBook)
        }
    }
}

#Preview {
    let books = BookInfo.loadSampleData()
    List {
        ForEach(books, id: \.title) { book in
            BookRowView(bookInfo: book)
        }
    }
}

