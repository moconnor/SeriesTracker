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
        NavigationStack {
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
                
                Section(header: Text("Reading Progress")) {
                    Picker("Read Status", selection: $book.readStatus) {
                        ForEach(ReadStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
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
                
                Section(header: Text("Rating")) {
                    RatingsView(book: book)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $book.notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(editorTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(buttonName) {
                        saveBook()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(title.isEmpty ? .gray : .green)
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingNewAuthorSheet) {
                newAuthorSheet
            }
        }
    }
    
    private var newAuthorSheet: some View {
        NavigationStack {
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
            book.series = series
            series.books.append(book)
            try modelContext.save() // redundant?
            dismiss()
        } catch {
            print("Error saving book: \(error)")
        }
    }
}

#Preview("Add Book") {
    let series = Series.randomSeries()
    let authorDB = Series.sampleDB()
    BookEditorView(series: series)
        .modelContainer(authorDB)
}

#Preview("Edit Book") {
    let series = Series.randomSeries()
    let authorDB = Series.sampleDB()
    BookEditorView(book: series.books.first, series: series)
        .modelContainer(authorDB)
}
