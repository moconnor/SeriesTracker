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
                                }
                            }
                            .onDelete(perform: deleteSeries)
                        }
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
                        print(result)
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
    
    private func deleteSeries(at offsets: IndexSet) {
        for index in offsets {
            let seriesItem = series[index]
            modelContext.delete(seriesItem)
            do {
                try modelContext.save()
            } catch {
                print("Error deleting books: \(error)")
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

