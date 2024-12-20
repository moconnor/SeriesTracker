//
//  BookRowView.swift
//  BookSeries
//
//  Created by Michael O'Connor using Claude on 12/19/24.
//

import SwiftUI

struct BookRowView: View {
    let book: BookInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(book.title)
                .font(.headline)
            
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
    }
}

//#Preview {
//    BookRowView()
//}
