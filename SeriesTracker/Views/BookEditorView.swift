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
    @Environment(\.presentationMode) var presentationMode
    
    var series: Series
    @State private var book: Book
    @State private var showingNewAuthorSheet = false
    @State private var newAuthorName = ""
    
    // Fetch available authors and series
    @Query(sort: \Author.name) private var authors: [Author]

    private var editorTitle: String
    private var buttonName: String
    
    init(book: Book? = nil, series: Series) {
        if let existingBook = book {
            _book = State(initialValue: existingBook)
            editorTitle = "Edit Book"
            buttonName = "Update Book"
        } else {
            let newBook = Book(title: "")
            _book = State(initialValue: newBook)
            editorTitle = "Add Book"
            buttonName = "Add Book"
        }
        self.series =  series
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Title", text: $book.title)
                    
                    // Author picker with add new option
                    authorSelectionView
                    
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
                    .disabled(book.title.isEmpty)
                }
            }
            .navigationTitle(editorTitle)
            .navigationBarItems(trailing:
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingNewAuthorSheet) {
                newAuthorSheet
            }
        }
    }
    
    private var authorSelectionView: some View {
        Menu {
            // Optional: No author
            Button(action: { book.author = nil }) {
                HStack {
                    Text("None")
                    if book.author == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            if !authors.isEmpty {
                Divider()
            }
            
            // Existing authors
            ForEach(authors) { author in
                Button(action: { book.author = author }) {
                    HStack {
                        Text(author.name)
                        if author.id == book.author?.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            Divider()
            
            // Add new author option
            Button(action: {
                showingNewAuthorSheet = true
            }) {
                Label("Add New Author", systemImage: "plus.circle")
            }
        } label: {
            HStack {
                Text("Author")
                Spacer()
                Text(series.author.name)
                    .foregroundColor(book.author == nil ? .gray : .primary)
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
        guard !book.title.isEmpty else { return }
        
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
            if book.id == UUID() {
                modelContext.insert(book)
            }
            try modelContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving book: \(error)")
        }
    }
}

#Preview {
    let series = Series.randomSeries()
    BookEditorView(series: series)
}
