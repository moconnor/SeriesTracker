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
    
    @State private var book: Book
    @State private var showingNewAuthorSheet = false
    @State private var newAuthorName = ""
    
    // Fetch available authors and series
    @Query(sort: \Author.name) private var authors: [Author]
    @Query(sort: \Series.name) private var allSeries: [Series]
    
    init(book: Book? = nil) {
        if let existingBook = book {
            _book = State(initialValue: existingBook)
        } else {
            let newBook = Book(title: "")
            _book = State(initialValue: newBook)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Title", text: $book.title)
                    
                    // Author picker with add new option
                    authorSelectionView
                    
                    // Series picker and order
                    seriesSelectionView
                    if book.series != nil {
                        Stepper("Series Order: \(book.seriesOrder)", value: $book.seriesOrder, in: 1...999)
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
                    Button(book.id == UUID() ? "Create Book" : "Update Book") {
                        saveBook()
                    }
                    .disabled(book.title.isEmpty)
                }
            }
            .navigationTitle(book.id == UUID() ? "New Book" : "Edit Book")
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
                Text(book.author?.name ?? "None")
                    .foregroundColor(book.author == nil ? .gray : .primary)
            }
        }
    }
    
    private var seriesSelectionView: some View {
        Menu {
            // Optional: No series
            Button(action: { book.series = nil }) {
                HStack {
                    Text("None")
                    if book.series == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            if !allSeries.isEmpty {
                Divider()
                
                // Existing series
                ForEach(allSeries) { series in
                    Button(action: { book.series = series }) {
                        HStack {
                            Text(series.name)
                            if series.id == book.series?.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text("Series")
                Spacer()
                Text(book.series?.name ?? "None")
                    .foregroundColor(book.series == nil ? .gray : .primary)
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
    BookEditorView()
}
