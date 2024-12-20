//
//  BookEditor.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import SwiftUI
import SwiftData

struct BookEditor: View {
    var book: Book?
    var series: Series
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    
    @State  var title = ""
    @State  var author: Author = Author(name: "Unknown")
    @State  var genre: String = ""
    @State  var readStatus: ReadStatus = .notStarted
    @State  var rating: Int = 0
    @State  var isComplete: Bool = false
    @State  var review: String = ""
    
    var editorTitle: String {
        book == nil ? "Add Book" : "Edit Book"
    }
    var saveButtonTitle: String {
        book == nil ? "Add Book" : "Update Book"
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Book")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author.name)
                    TextField("Genre", text: $genre)
                    
//                    HStack {
//                        Button("Cancel") {
//                            dismiss()
//                        }
//                        
//                        Spacer()
//                        
//                        Button(saveButtonTitle) {
//                            if book == nil {
//                                let newBook = Book(title: title, author: author)
//                                newBook.genre = genre
//                                newBook.status = readStatus
//                                series.books.append(newBook)
//                                context.insert(newBook)
//                            }
//                            try? context.save()
//                            dismiss()
//                        }
//                        .disabled(title.isEmpty || author.isEmpty)
//                    }
//                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                if let book {
                    title = book.title
                    author = book.author!
                   // genre = book.genre
                    readStatus = book.readStatus
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editorTitle)
                }
            }
        }
    }
}

#Preview {
    let series = Series.randomSeries()
    let book = series.books.randomElement()
    BookEditor(book: book, series: series)
}
