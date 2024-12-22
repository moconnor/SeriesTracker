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
            VStack(alignment: .leading) {
                
                Text(series.name + " Details")
                    .font(.title)
                    .bold()
                Text("Status: " + series.readStatus().rawValue)
                    .font(.headline)
                
                Divider()
                Section(header: Text("Author")
                    .font(.headline)) {
                        HStack {
                            Text(series.author.name)
                                .font(.headline)
                            Spacer()
                            Button {
                                showAuthorPicker()
                            } label: {
                                Image(systemName: "pencil")
                            }
                        }
                        .padding(.horizontal)
                    }
                Divider()
                
                BookListView(series: series)
                
                Divider()
            }
            .padding()
        }
        
    }
}

private func showAuthorPicker() {
    // Implement author selection for series
}

//    private func addNewBook() {
//        let newBook = Book(title: newBookTitle, seriesOrder: newBookOrder)
//        series.books.append(newBook)
//        modelContext.insert(newBook)
//        newBookTitle = ""
//        newBookOrder += 1
//    }

//    private func deleteBooks(at offsets: IndexSet) {
//        for index in offsets {
//            let book = series.books[index]
//            modelContext.delete(book)
//            series.books.remove(at: index)
//        }
//    }
//}

#Preview("No Books") {
    let author = Author(name: "Anonymous")
    let series = Series(name: "Empty Series", author: author)
    SeriesDetailView(series: series)
}

#Preview("With Books") {
    let series = Series.randomSeries()
    SeriesDetailView(series: series)
}

