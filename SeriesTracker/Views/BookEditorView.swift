//
//  BookEditorView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/18/24.
//

import SwiftUI
import SwiftData

struct BookEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    var series: Series
    @State private var book: Book
    @State private var showingNewAuthorSheet = false
    @State private var newAuthorName = ""
    @State private var isNewBook: Bool = false
    @State private var title: String = ""
    @State private var selectedAuthor: Author?
    @State private var author: Author = Author(name: "Not Selected")
 
    @Query(sort: \Author.name) private var authors: [Author]

    private var editorTitle: String
    private var buttonName: String
    
    init(book: Book? = nil, series: Series) {
        if let existingBook = book {
            _book = State(initialValue: existingBook)
            editorTitle = "Edit Book"
            buttonName = "Update Book"
            title = existingBook.title
            author = existingBook.author ?? Author(name: "Not Selected")
        } else {
            let newBook = Book(title: "")
            _book = State(initialValue: newBook)
            editorTitle = "Add Book"
            buttonName = "Add Book"
            isNewBook = true
        }
        self.series =  series
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Title", text: $title)
                    //Text("Pick from \(authors.count) authors")
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
                        selectedAuthor = series.author
                    }
                }
                
                Section(header: Text("Reading Status")) {
                    Picker("Status", selection: $book.readStatus) {
                        ForEach(ReadStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    if book.readStatus != .notStarted {
                        DatePicker("Start Date", selection: Binding(
                            get: { book.startDate ?? Date() },
                            set: { book.startDate = $0 }
                        ), displayedComponents: .date)
                    }
                    
                    if book.readStatus == .completed || book.readStatus == .abandoned {
                        DatePicker("End Date", selection: Binding(
                            get: { book.endDate ?? Date() },
                            set: { book.endDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                
                if book.readStatus == .completed {
                    Section(header: Text("Rating")) {
                        ratingView
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $book.notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(buttonName) {
                        saveBook()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle(editorTitle)
            .navigationBarItems(trailing:
                Button("Cancel") {
                    dismiss()
                }
            )
            .sheet(isPresented: $showingNewAuthorSheet) {
                newAuthorSheet
            }
        }
    }
        
    private var ratingView: some View {
        HStack {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= (book.rating ?? 0) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .onTapGesture {
                        book.rating = index
                    }
            }
            if book.rating != nil {
                Button(action: { book.rating = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var newAuthorSheet: some View {
        NavigationView {
            Form {
                TextField("Author Name", text: $newAuthorName)
            }
            .navigationTitle("New Author")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingNewAuthorSheet = false
                },
                trailing: Button("Add") {
                    addNewAuthor()
                }
                .disabled(newAuthorName.isEmpty)
            )
        }
    }
    
    private func addNewAuthor() {
        let newAuthor = Author(name: newAuthorName)
        modelContext.insert(newAuthor)
        book.author = newAuthor
        newAuthorName = ""
        showingNewAuthorSheet = false
    }
    
    private func saveBook() {
        guard !title.isEmpty else { return }
        
        // Validate and adjust dates based on status
        switch book.readStatus {
        case .notStarted:
            book.startDate = nil
            book.endDate = nil
            book.rating = nil
        case .inProgress:
            book.endDate = nil
            book.rating = nil
        case .completed, .abandoned:
            if book.startDate == nil {
                book.startDate = book.endDate
            }
        }
        
        do {
            book.title = title
            book.series = series
            book.author = selectedAuthor
            if isNewBook {
                modelContext.insert(book)
            }
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving book: \(error)")
        }
    }
}

#Preview {
    let series = Series.randomSeries()
    let authorDB = Series.sampleDB()
    BookEditorView(series: series)
        .modelContainer(authorDB)
}

#Preview {
    let series = Series.randomSeries()
    let authorDB = Series.sampleDB()
    BookEditorView(book: series.books.first, series: series)
        .modelContainer(authorDB)

}