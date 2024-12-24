//
//  BookDetailView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import SwiftUI

struct BookDetailsView: View {
    @Bindable var book: Book
    var series: Series
    
    @Environment(\.modelContext) private var modelContext
    @State private var showingAuthorPicker = false
    @State private var newAuthorName = ""
    @State private var showBookEditor = false
    
    var body: some View {
        Form {
            Section(header: Text("Book Details")) {
                Text("Title: \(book.title)")
                HStack {
                    Text("Author:")
                    if let author = book.author {
                        Text(author.name)
                    } else {
                        Text("Not Set")
                    }
                    Spacer()
                }
            }
            
            Section(header: Text("Reading Progress")) {
                Picker("Read Status", selection: $book.readStatus) {
                    ForEach(ReadStatus.allCases, id: \.self) { status in
                        Text(status.rawValue.capitalized).tag(status)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if book.readStatus != .notStarted {
                    DatePicker("Start Date",
                               selection: Binding(
                                get: { book.startDate ?? Date() },
                                set: { book.startDate = $0 }
                               ),
                               displayedComponents: .date)
                }
                
                if book.readStatus == .completed {
                    DatePicker("Completion Date",
                               selection: Binding(
                                get: { book.endDate ?? Date() },
                                set: { book.endDate = $0 }
                               ),
                               displayedComponents: .date)
                    
                    Picker("Rating", selection: $book.rating) {
                        ForEach(0...5, id: \.self) { rating in
                            Text(rating == 0 ? "No Rating" : "\(rating) ★").tag(rating as Int?)
                        }
                    }
                }
                
                TextField("Notes", text: $book.notes, axis: .vertical)
                    .lineLimit(3...5)
            }
        }
        .navigationTitle("Book Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showBookEditor = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
   
        }
        .sheet(isPresented: $showBookEditor) {
            BookEditorView(book: book, series: series)
        }
    }
}

#Preview {
    NavigationView {
        let series = Series.randomSeries()
        BookDetailsView(book: series.books.randomElement()!, series: series)
    }
}