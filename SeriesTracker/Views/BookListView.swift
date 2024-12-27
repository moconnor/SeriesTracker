//
//  BookListView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/18/24.
//

import SwiftUI

struct BookListView: View {
    var bookSeries: Series
    @State var addingNewBook: Bool = false
    @Environment(\.modelContext) private var modelContext
   // @Query(sort: \Series.name) var series: [Series]
    
    var body: some View {
        VStack {
            if bookSeries.books.isEmpty {
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
                        ForEach(bookSeries.books) { book in
                            NavigationLink(destination: BookDetailsView(book: book, series: bookSeries)) {
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
        .sheet(isPresented: $addingNewBook) {
            BookEditorView(book: nil, series: bookSeries)
        }
    }
}

#Preview("No Books") {
    let series: Series = .randomSeries(withBooks: false)
    BookListView(bookSeries: series)
}

#Preview("Books") {
    let series: Series = .randomSeries()
    NavigationStack {
        BookListView(bookSeries: series)
    }
}
