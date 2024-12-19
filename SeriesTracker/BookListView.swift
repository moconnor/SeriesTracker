//
//  BookListView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/18/24.
//

import SwiftUI

struct BookListView: View {
    var books: [Book]
    @State var addingNewBook: Bool = false
    
    var body: some View {
 
        if books.isEmpty {
            ContentUnavailableView {
                Label("No Books in this Series", systemImage: "book.closed")
            } actions: {
                Button {
                    addingNewBook = true
                } label: {
                    Text("Add a Book")
                        .font(.title2)
                        .bold()
                }
            }
        } else {
            List {
                Section(header: Text("Books In The Series")) {
                    
                    ForEach(books) { book in
                        NavigationLink(destination: BookDetailsView(book: book)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(book.title)
                                    Text(book.readStatus.rawValue.capitalized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: book.readStatus.statusIcon())
                                    .foregroundColor(book.readStatus.statusColor())
                            }
                        }
                    }
                    Button {
                        addingNewBook = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
//        .onDelete(perform: deleteBooks)
    }

}

#Preview("No Books") {
    BookListView(books: [])
}

#Preview("Books") {
    let series: Series = .randomSeries()
    BookListView(books: Book.randomBookArray(author: series.author))
}
