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
    @State var bookToDelete: Book?
    @State var showConfirmation: Bool = false
    
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
                        ForEach(series.books.sorted(by: { $0.seriesOrder < $1.seriesOrder })) { book in
                           // ForEach(series.books) { book in
                            NavigationLink(value: book) {
                                BooksRowView(book: book)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            bookToDelete = book
                                            showConfirmation = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
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
                .confirmationDialog(
                    "Delete \"\(bookToDelete?.title ?? "this book")\"?",
                    isPresented: $showConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        deleteABook()
                    }
                } message: {
                    Text("Are you sure you want to delete this book? This action cannot be undone.")
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
    
    private func deleteABook() {
        guard let book = bookToDelete else { return }
        modelContext.delete(book)
        do {
            try modelContext.save()
        } catch {
            print("Error deleting book: \(error)")
        }
        bookToDelete = nil
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
