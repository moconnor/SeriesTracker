//
//  BookRowView.swift
//  BookSeries
//
//  Created by Michael O'Connor using Claude on 12/19/24.
//

import SwiftUI

struct BookRowView: View {
    let book: BookInfo
    @State private var importBook: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(book.title)
                    .font(.headline)
                Spacer()
                Button {
                    importBook.toggle()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }

            if let authors = book.authors {
                Text("By: \(authors.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let publishedDate = book.publishedDate {
                Text("Published: \(publishedDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let description = book.description {
                Text(description)
                    .font(.caption)
                    .lineLimit(3)
                    .padding(.top, 4)
            }
            
            if let seriesInfo = book.seriesInfo?.bookDisplayNumber {
                Text("Book \(seriesInfo) in series")
                    .font(.caption)
                    .foregroundColor(.blue)
            }

        }
        .padding(.vertical, 8)
        .sheet(isPresented: $importBook) {
            ImportBookView()
        }
    }
}

//#Preview {
//    BookRowView()
//}

struct ImportBookView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Select the series to import into:")
            Text("Pompt for the book and author of the book")
            Text("Eventually, prompt for the other book data")
        }
    }
}

#Preview {
    ImportBookView()
}
