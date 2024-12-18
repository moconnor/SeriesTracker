//
//  BookDetailView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import SwiftUI

struct BookDetailView: View {
    @Bindable var book: Book
    @Environment(\.modelContext) private var modelContext
    @State private var showingAuthorPicker = false
    @State private var newAuthorName = ""
    
    var body: some View {
        Form {
            Section(header: Text("Book Details")) {
                Text("Title: \(book.title)")
                
                // Author Selection
                HStack {
                    Text("Author:")
                    if let author = book.author {
                        Text(author.name)
                    } else {
                        Text("Not Set")
                    }
                    Spacer()
                    Button {
                        showingAuthorPicker = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
            
            Section(header: Text("Reading Progress")) {
                Picker("Read Status", selection: $book.readStatus) {
                    ForEach([ReadStatus.notStarted, .inProgress, .completed, .abandoned], id: \.self) { status in
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
//        .sheet(isPresented: $showingAuthorPicker) {
//            AuthorSelectionView(selectedAuthor: Binding(
//                get: { book.author },
//                set: { newAuthor in
//                    book.author = newAuthor
//                }
//            ))
//        }
    }
}

#Preview {
    BookDetailView(book: Book.randomBook())
}
