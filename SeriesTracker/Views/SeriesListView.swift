//
//  SeriesListView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import SwiftUI
import SwiftData

struct SeriesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Series.name) var series: [Series]
    
    @State private var newSeriesName = ""
    @State private var createNewSeries = false
    @State private var showMenu = false
    
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
                    // NavigationStack {
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
                // Move the following into another file?
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            do {
                                let jsonData = try Series.exportToJSON(series: series)
                                if let jsonString = String(data: jsonData, encoding: .utf8) {
                                    print(jsonString)
                                    if let tempURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                        print("Exported series to \(tempURL)")
                                        let pathURL = tempURL.appendingPathComponent("series.json")
                                        try jsonData.write(to: pathURL)
                                    }
                                }
                            } catch {
                                print("Error exporting series: \(error)")
                            }
                        } label: {
                            Text("Export Series")
                        }
                        Button {
                            
                        } label: {
                            Text("Import Series")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                            .foregroundColor(.primary)
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
