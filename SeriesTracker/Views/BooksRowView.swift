//
//  BooksRowView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/31/24.
//

import SwiftUI

struct BooksRowView: View {
    var book: Book
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(book.title)
                HStack {
                    Text(book.readStatus.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let endDate = book.endDate {
                        Text(endDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
            Image(systemName: book.readStatus.statusIcon())
                .foregroundColor(book.readStatus.statusColor())
        }
    }
}

#Preview {
    BooksRowView(book: Book.randomBook())
}
