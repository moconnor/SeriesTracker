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
    @Query(sort: \Author.name) private var authors: [Author]

    @State  var title = ""
    @State  var author: Author = Author(name: "Unknown")
    @State  var genre: String = ""
    @State  var readStatus: ReadStatus = .notStarted
    @State  var rating: Int = 0
    @State private var selectedAuthor: Author?

    var editorTitle: String {
        book == nil ? "Add Book" : "Edit Book"
    }
    var saveButtonTitle: String {
        book == nil ? "Add Book" : "Update Book"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Title", text: $title)

                    Text("Pick one of \(authors.count) authors") // have 5 authors but none displayed!!!???!!!
                    
                    Picker("Author:", selection: $selectedAuthor) {
                        ForEach(authors) { author in
                            Text(author.name)
                                .tag(author as Author?)
                        }
                    }
                    .onChange(of: selectedAuthor) { _, newAuthor in
                        if let newAuthor {
                            author = newAuthor
                        }
                    }
                    .onAppear {
                        if let book {
                            selectedAuthor = book.author
                        }
                    }
                }
            }
        }
        .onAppear {
            if let book {
                title = book.title
                author = book.author!
                readStatus = book.readStatus
            }
        }
        .navigationTitle(editorTitle)
    }
    
}

#Preview {
    let series = Series.randomSeries()
    let book = series.books.randomElement()
    let authorDB = Author.authorDatabase(author: Author(name: "Unknown"))

    BookEditor(book: book, series: series)
        .modelContainer(authorDB)
}

#Preview {
    let series = Series.randomSeries()
    let book = series.books.randomElement()
    let authorDB = Author.authorDatabase(author: series.author)

    BookEditor(book: book, series: series)
        .modelContainer(authorDB)

}

