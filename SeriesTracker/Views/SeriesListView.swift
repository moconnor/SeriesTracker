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
    
    var sortedSeries: [Series] {
        // Sort the array by date, oldest first
        //series.sorted(by: { $0.lastReadBook() ?? Date() < $1.lastReadBook() ?? Date()  })
        if filterListBy == .everything {
            series.sorted(by: { $0.lastReadBook() ?? Date() < $1.lastReadBook() ?? Date()  })
        } else {
            series.filter { $0.status == filterListBy }.sorted(by: { $0.lastReadBook() ?? Date() < $1.lastReadBook() ?? Date()  })
        }
    }
    
    var hiddenSeries: Int {
        series.filter{ $0.shouldHide() }.count
    }
    
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack{
                    Text("Filter Series")
                    Picker("Show Series", selection: $filterListBy) {
                        ForEach(SeriesStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
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
//                        Section(header: Text("Series (\(sortedSeries.count)) + \(hiddenSeries) hidden, Total \(series.count)"))
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
                                    let newSeries = try decoder.decode([Series].self, from: data)
                                    url.stopAccessingSecurityScopedResource()

                                    // this appears to clear the database without errors
                                    try modelContext.delete(model: Series.self)
                                    try modelContext.delete(model: Book.self)
                                    try modelContext.delete(model: Author.self)

                                    // this inserts an author record the series and the books
                                    for series in newSeries {
                                        modelContext.insert(series)
                                    }
                                    try modelContext.save()

                                }

                            } catch DecodingError.keyNotFound(let key, let context) {
                                Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                            } catch DecodingError.valueNotFound(let type, let context) {
                                Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                            } catch DecodingError.typeMismatch(let type, let context) {
                                Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                            } catch DecodingError.dataCorrupted(let context) {
                                Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                            } catch let error as NSError {
                                NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                            } catch {
                                importError = error
                                showError = true
                            }
                        case .failure(let error):
                            print("Error reading JSON file: \(error.localizedDescription)")
                        }
                    }
                    .alert("Import Error", isPresented: $showError, presenting: importError) { _ in
                        Button("OK", role: .cancel) {}
                    } message: { error in
                        Text(error.localizedDescription)
                    }
                    
                    .fileExporter(isPresented: $isExporting,
                                  document: JSONFile(series: series),
                                  contentType: .json,
                                  defaultFilename: "Series-\(formatter.string(from: Date())).json") { result in
                        switch result {
                        case .success(let url):
                            print("JSON file saved successfully at: \(url.path)")
                        case .failure(let error):
                            print("Error saving JSON file: \(error.localizedDescription)")
                        }
                    }

                }
            }
            .sheet(isPresented: $createNewSeries) {
                SeriesEditorView()
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

