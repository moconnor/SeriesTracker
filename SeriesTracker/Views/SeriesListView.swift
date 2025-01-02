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
    
    var sortedSeries: [Series] {
        // Sort the array by date, oldest first
        series.sorted(by: { $0.lastReadBook() ?? Date() < $1.lastReadBook() ?? Date()  })
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if sortedSeries.isEmpty {
                    ContentUnavailableView("Enter a book series.", systemImage: "book.fill")
                } else {
                    List {
                        Section(header: Text("My Book Series")) {
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
                                
                                let data = try Data(contentsOf: url)
                                let decoder = JSONDecoder()
                                let newSeries = try decoder.decode([Series].self, from: data)
                                try modelContext.delete(model: Series.self)
                                for series in newSeries {
                                    modelContext.insert(series)
                                }

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

