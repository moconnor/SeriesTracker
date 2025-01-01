//
//  BookListView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/18/24.
//

import SwiftUI
import SwiftData

struct BookListView: View {
    var series: Series
    @State var addingNewBook: Bool = false
    @Environment(\.modelContext) private var modelContext
    
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
                    Section(header: Text("There Are \(series.books.count) Books In The Series")) {
                        ForEach(series.books) { book in
                            NavigationLink(value: book) {
                                BooksRowView(book: book)
                            }
                        }
                        .onDelete(perform: deleteBooks)
                        
                        Button {
                            addingNewBook = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .navigationDestination(for: Book.self)  { book in
                    BookDetailsView(book: book, series: series)
                }
            }
        }
        .sheet(isPresented: $addingNewBook) {
            BookEditorView(book: nil, series: series)
        }
    }
    
    // potential problem with deleting multiple books
    // since the array could get misaligned?
    func deleteBooks(at offsets: IndexSet) {
        for offset in offsets {
            let book = series.books[offset]
            modelContext.delete(book)
            series.books.remove(at: offset)
        }
        do {
            try modelContext.save()
        } catch {
            print("Error deleting books: \(error)")
        }
    }
}

#Preview("No Books") {
    let series: Series = .randomSeries(withBooks: false)
    BookListView(series: series)
}

#Preview("Books") {
    let series: Series = .randomSeries()
    NavigationStack {
        BookListView(series: series)
    }
}
