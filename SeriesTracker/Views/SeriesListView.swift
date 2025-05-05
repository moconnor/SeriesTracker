//
//  SeriesListView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SeriesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Series.name) var series: [Series]
    var formatter = DateFormatter()
    
    init() {
        formatter.dateFormat = "yyyyMMddHHmm"
    }
    
    @State private var newSeriesName = ""
    @State private var createNewSeries = false
    @State private var showMenu = false
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var showConfirmation = false
    @State private var seriesToDelete: Series?
    @State private var importError: Error?
    @State private var showError = false
    @State private var filterListBy:SeriesStatus = .everything
    @State private var showAlert = false
    @State private var alertTitle: String = "Error"
    @State private var alertMessage: String = ""
    
    var sortedSeries: [Series] {
        // Sort the array by date, oldest first
        //series.sorted(by: { $0.lastReadBook() ?? Date() < $1.lastReadBook() ?? Date()  })
        if filterListBy == .everything {
            series.sorted(by: { $0.lastReadBook() ?? Date() < $1.lastReadBook() ?? Date()  })
        } else {
            series.filter { $0.status == filterListBy }.sorted(by: { $0.lastReadBook() ?? Date() < $1.lastReadBook() ?? Date()  })
        }
    }
    
    var currentlyReading:String {
        if let inProgressSeries = series.filter({$0.status == .reading}).first {
            let books = inProgressSeries.books.filter({$0.readStatus == .inProgress})
            
            if books.isEmpty {
                return "None"
            } else if books.count > 1 {
                return "More than 1?"
            } else {
                if let book = books.first {
                    return book.title
                } else {
                    return "No Book Title"
                }
            }
        } else {
            return "No Series in Progress"
        }
    }
    
    var suggestedNextRead:String {
        // series needs to be inProgess
        // in progress series has the oldest last completed date
        // series needs a book not started
        
        var candidates:[[String:Any]] = []
        
        let inProgressSeries = series.filter({$0.status == .inProgress && $0.containsNotStartedBooks()})
        print("In progress series \(inProgressSeries.count)")
        for aSeries in inProgressSeries {
            if let lastReadbookDate = aSeries.lastReadBook(), let lastReadBookName = aSeries.lastReadBookName() {
                
                let candidate = ["series":aSeries.name,"book":lastReadBookName,"date":lastReadbookDate] as [String : Any]
                candidates.append(candidate)
            }
        }
        
        for candidate in candidates {
            print("\(candidate)")
        }
        
        var oldestTitle:String = ""
        if let oldest = candidates.min(by: {
            let date1 = $0["date"] as? Date ?? Date.distantFuture
            let date2 = $1["date"] as? Date ?? Date.distantFuture
            return date1 < date2
        }) {
            print("Oldest candidate: \(oldest)")
            oldestTitle = oldest["book"] as? String ?? ""
            
            if let candidateSeriesName = oldest["series"] as? String {
                let candidateSeries = inProgressSeries.filter({$0.name == candidateSeriesName })
                if candidateSeries.count == 1, let singleNotStartedSeries = candidateSeries.first {
                    let notStartedBooks = singleNotStartedSeries.books.filter({$0.readStatus == .notStarted})
                    if let oldestNotStartedBook = notStartedBooks.min(by: { $0.endDate ?? Date() > $1.endDate ?? Date() }) {
                        
                        print("Oldest notStarted Book: '\(oldestNotStartedBook.title)'")
                        oldestTitle = oldestNotStartedBook.title
                    }
                }
            }
        }
        
        return oldestTitle
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack{
                    Text("Filter Series").bold()
                    Picker("Show Series", selection: $filterListBy) {
                        ForEach(SeriesStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                HStack{
                    Text("Currently Reading").bold()
                    Text("\(currentlyReading)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                HStack{
                    Text("Suggested Next").bold()
                    Text("\(suggestedNextRead)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            VStack {
                if sortedSeries.isEmpty {
                    ContentUnavailableView("Enter a book series.", systemImage: "book.fill")
                } else {
                    List {
                        Section(header: seriesStatusCountView) {
                            ForEach(sortedSeries) { bookSeries in
                                NavigationLink(value: bookSeries) {
                                    SeriesRowView(series: bookSeries)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                seriesToDelete = bookSeries
                                                showConfirmation = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .confirmationDialog(
                        "Delete \"\(seriesToDelete?.name ?? "Series")\"?",
                        isPresented: $showConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) {
                            deleteASeries()
                        }
                    } message: {
                        Text("Are you sure you want to delete this series and all of its books? This action cannot be undone.")
                    }
                    
                    .navigationDestination(for: Series.self)  { series in
                        SeriesDetailView(series: series)
                    }
                    
                }
            }
            .navigationTitle("Series Tracker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        createNewSeries = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Export Series") {
                            isExporting = true
                        }
                        
                        Button("Import Series") {
                            isImporting = true
                        }
                        
                        Button("Version: \(Bundle.main.versionNumberString)") {}
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                            .foregroundColor(.primary)
                    }
                    .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
                        switch result {
                        case .success:
                            do {
                                let url = try result.get()
                                
                                if url.startAccessingSecurityScopedResource() {
                                    let data = try Data(contentsOf: url)
                                    let decoder = JSONDecoder()
                                    decoder.dateDecodingStrategy = .iso8601
                                    //let newSeries = try decoder.decode([Series].self, from: data)
                                    let newDTOSeries = try decoder.decode([SeriesDTO].self, from: data)
                                    url.stopAccessingSecurityScopedResource()
                                    
                                    // this appears to clear the database without errors
                                    try modelContext.delete(model: Series.self)
                                    try modelContext.delete(model: Book.self)
                                    try modelContext.delete(model: Author.self)
                                    
                                    for dto in newDTOSeries {
                                        let author = modelContext.author(named: dto.authorname)
                                        let series = Series(name: dto.name, author: author)
                                        series.notes = dto.notes
                                        series.status = dto.status
                                        modelContext.insert(series)
                                        for bookDTO in dto.books {
                                            let bookAuthor = modelContext.author(named: bookDTO.authorname)
                                            let book = Book(title: bookDTO.title,
                                                            seriesOrder: bookDTO.seriesOrder,
                                                            author: bookAuthor,
                                                            readStatus: bookDTO.readStatus)
                                            book.series = series
                                            book.startDate = bookDTO.startDate
                                            book.endDate = bookDTO.endDate
                                            book.notes = bookDTO.notes
                                            book.rating = bookDTO.rating
                                            modelContext.insert(book)
                                            series.books.append(book)
                                        }
                                    }
                                    
                                    
                                    
                                    // this inserts an author record the series and the books
//                                    for series in newSeries {
//                                        modelContext.insert(series)
//                                    }
                                    try modelContext.save()
                                }
                                
                            } catch let error {
                                switch error {
                                case DecodingError.keyNotFound(let key, let context):
                                    alertMessage = "Could not find key \(key) in JSON: \(context.debugDescription)"
                                    
                                case DecodingError.valueNotFound(let type, let context):
                                    alertMessage = "Could not find type \(type) in JSON: \(context.debugDescription)"
                                    
                                case DecodingError.typeMismatch(let type, let context):
                                    alertMessage = "Type mismatch for type \(type) in JSON: \(context.debugDescription)"
                                    
                                case DecodingError.dataCorrupted(let context):
                                    alertMessage = "Data found to be corrupted in JSON: \(context.debugDescription)"
                                    
                                case let error as NSError:
                                    alertMessage = "Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)"
                                }
                                showAlert = true
                            }
                        case .failure(let error):
                            alertMessage = "Error reading JSON file: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                    
                    .alert(alertTitle, isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(alertMessage)
                    }
                    
                    .fileExporter(isPresented: $isExporting,
                                  document: JSONFile(series: series),
                                  contentType: .json,
                                  defaultFilename: "Series-\(formatter.string(from: Date())).json") { result in
                        showAlert = true
                        
                        switch result {
                        case .success(let url):
                            alertTitle = "Success"
                            alertMessage = "JSON file saved successfully at: \(url.path)"
                        case .failure(let error):
                            alertMessage = "Error saving JSON file: \(error.localizedDescription)"
                        }
                    }
                    
                }
            }
            .sheet(isPresented: $createNewSeries) {
                SeriesEditorView()
            }
        }
        .onAppear {
            Task {
                // await checkForNewBooks() // TODO:  Uncomment to test async online check for new books... 
            }
        }
    }
    
    private func statusCount(_ status:SeriesStatus) -> Int {
        if status == .everything {
            return series.count
        } else {
            return series.filter({$0.status == status}).count
        }
    }

    
    private func deleteASeries() {
        guard let series = seriesToDelete else { return }
        
        modelContext.delete(series)
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting series: \(error)")
        }
        seriesToDelete = nil
    }
    
    private var seriesStatusCountView : some View {
        
        HStack(alignment: .center) {
            ForEach(SeriesStatus.allCases, id: \.self) { status in
                if status == filterListBy {
                    VStack {
                        Text(status.statusAbbreviation())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.accentColor)
                        Text("\(statusCount(status))")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.accentColor)
                    }
                    .frame(maxWidth: .infinity) // Expand each VStack to fill available space
                } else {
                    if statusCount(status) > 0 {
                        VStack {
                            Text(status.statusAbbreviation())
                                .font(.system(size: 10))
                                .foregroundColor(Color.primary)
                            Text("\(statusCount(status))")
                                .font(.system(size: 11))
                                .foregroundColor(Color.primary)
                        }
                        .frame(maxWidth: .infinity) // Expand each VStack to fill available space
                    }
                }
            }
        }
    }
    
    // MARK:  Debug... remove put someplace gooder ;)
    
    private func getCommonWords(seriesName: String, textSnippet: String) -> [String] {
        // Split the strings into words (based on whitespace and punctuation)
        let seriesNameWords = Set(seriesName.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })
        let textSnippetWords = Set(textSnippet.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })

        // Find common words
        let commonWords = seriesNameWords.intersection(textSnippetWords)
        return Array(commonWords)
    }
    
    private func isContainedInSnippet(_ candidate: String, _ snippet: String) -> Bool {
        
        let candidateWords = Set(candidate.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }).filter { $0.count > 2}
        let snippetWords = Set(snippet.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })

        // Find common words
        let commonWords = candidateWords.intersection(snippetWords)

        return commonWords.count >= candidateWords.count
    }
    
    func removeDiacritics(_ string: String) -> String {
        // Normalize the string to NFD (decomposed form) and remove diacritics
        string.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    private func searchForNewBooks(inSeries:Series) async -> [Book] {
       print("Checking '\(inSeries.name)'")
        do {
            let seriesName = inSeries.name
            var authorName = ""
            let author = inSeries.author
            authorName = removeDiacritics(author.name.lowercased()) //inSeries.author.name
            
//            let encodedSeries = seriesName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//            let encodedAuthor = authorName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            //let urlString = "https://www.googleapis.com/books/v1/volumes?q=intitle:\(encodedSeries)+inauthor:\(encodedAuthor)&maxResults=40"
            //let query = "\(seriesName) in title+inauthor:\(authorName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let query = "title+inauthor:\(authorName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

            let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(query)&maxResults=40"
            
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
//            let jsonstring = String(data: data, encoding: .utf8) ?? ""
            //print(jsonstring)
            let result = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
            //books = result.items.map { $0.volumeInfo }
            
            /// Tweaking this filter... I was getting false positives because the search criteria words were showing up in every entry's info and previewLinks, even if they didn't show up anywhere else
            /// based on a sample of one Series, I changed to series matching to title, description or searchInfo.
            
            let filteredBooks = result.items.filter { item in
                let book = item.volumeInfo
                let searchInfo = item.searchInfo
                let matchesTitleSeries = book.title.localizedCaseInsensitiveContains(seriesName)
                //let matchesDescription = book.description?.localizedCaseInsensitiveContains(seriesName) ?? false
                let matchesDescription = isContainedInSnippet(seriesName, book.description ?? "")
                //let matchesSearchInfo = searchInfo?.textSnippet?.localizedCaseInsensitiveContains(seriesName) ?? false
                let matchesSearchInfo = isContainedInSnippet(seriesName, searchInfo?.textSnippet?.description ?? "")
               //let matchesAuthor = book.authors?.contains { $0.localizedCaseInsensitiveContains(authorName) } ?? false
                
                let matchesAuthor = book.authors?.contains {removeDiacritics($0.lowercased()).contains(authorName) } ?? false
                return (matchesTitleSeries || matchesDescription || matchesSearchInfo ) && matchesAuthor
            }.map { $0.volumeInfo }
            
            if filteredBooks.count > 0 {
                print("Looking for new books in '\(seriesName)'... found (\(filteredBooks.count)) candidates")
                for filteredBook in filteredBooks {
                    if inSeries.contains(bookName: filteredBook.title) == false {
                        print("  New book Candidate: \(filteredBook.title)")
                    }
                }
            } else {
                print("Didn't find anything for '\(seriesName)'...")
            }
        } catch {
            print("Something went wrong! error='\(error)'")
        }
        
        return []
    }
    
    private func checkForNewBooks() async {
        let waitingForNextBookSeries = series.filter({$0.status == .waitingForNextBook })
        print("\n\n\nChecking for new books... in (\(waitingForNextBookSeries.count)) waiting series")
        for series in waitingForNextBookSeries {
            let _ = await searchForNewBooks(inSeries: series)
        }

    }
}

#Preview("Empty") {
    let authorDB = Author.authorDatabase(author: Author(name: "Unknown"))
    SeriesListView()
        .modelContainer(authorDB)
}

#Preview("With Series") {
    let preview = Preview([Series.self])
    for _ in 0..<Int.random(in: 1..<15) {
        let series = Series.randomSeries()
        preview.add(items: [series])
    }
    return SeriesListView().modelContainer(preview.container)
}

