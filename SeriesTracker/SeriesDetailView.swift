//
//  SeriesDetailView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import SwiftUI
import SwiftData

struct SeriesDetailView: View {
    @Bindable var series: Series
    @Environment(\.modelContext) private var modelContext
    
    @State private var newBookTitle = ""
    @State private var newBookOrder = 1
    @State private var addingNewBook = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    // Series Author Section
                    Section(header: Text("Series Author")) {
                        HStack {
                            Text(series.author?.name ?? "No Author")
                            Spacer()
                            Button("Change Author") {
                                showAuthorPicker()
                            }
                        }
                    }
                    
                    // Books in the Series
                    Section(header: Text("Books In The Series")) {
                        if series.books.isEmpty {
                            ContentUnavailableView {
                                Label("No Books in this Series", systemImage: "book.fill")
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
                            ForEach($series.books) { $book in
                                NavigationLink(destination: BookDetailView(book: book)) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(book.seriesOrder). \(book.title)")
                                            Text(book.readStatus.rawValue.capitalized)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: statusIcon(for: book.readStatus))
                                            .foregroundColor(statusColor(for: book.readStatus))
                                    }
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
                }
                
            }.navigationTitle(series.name)
            
        }
    }
    
    private func statusIcon(for status: ReadStatus) -> String {
        switch status {
        case .notStarted: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .completed: return "checkmark.circle.fill"
        case .abandoned: return "xmark.circle.fill"
        }
    }
    
    private func statusColor(for status: ReadStatus) -> Color {
        switch status {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .abandoned: return .red
        }
    }
    
    private func showAuthorPicker() {
        // Implement author selection for series
    }
    
    private func addNewBook() {
        let newBook = Book(title: newBookTitle, seriesOrder: newBookOrder)
        series.books.append(newBook)
        modelContext.insert(newBook)
        newBookTitle = ""
        newBookOrder += 1
    }
    
    private func deleteBooks(at offsets: IndexSet) {
        for index in offsets {
            let book = series.books[index]
            modelContext.delete(book)
            series.books.remove(at: index)
        }
    }
}

#Preview("No Books") {
    let author = Author(name: "Anonymous")
    let series = Series(name: "Empty Series", author: author)
    SeriesDetailView(series: series)
}

#Preview("With Books") {
    let series = Series.randomSeries()
    SeriesDetailView(series: series)
}
