//
//  BookListView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/18/24.
//

import SwiftUI

struct BookListView: View {
    var series: Series
    @State var addingNewBook: Bool = false
    
    var body: some View {
        VStack {
            if series.books.isEmpty {
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
                        
                        ForEach(series.books) { book in
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
        .sheet(isPresented: $addingNewBook) {
            BookEditorView(book: nil, series: series)
        }
    }


}

#Preview("No Books") {
    BookListView(series: Series.randomSeries())
}

#Preview("Books") {
    let series: Series = .randomSeries()
    BookListView(series: series)
}
