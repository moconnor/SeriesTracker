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
    
    var body: some View {
        NavigationStack {
            VStack {
                if series.isEmpty {
                    ContentUnavailableView("Enter a book series.", systemImage: "book.fill")
                } else {
                    List {
                        Section(header: Text("My Book Series")) {
                            ForEach(series) { bookSeries in
                                NavigationLink(destination: SeriesDetailView(series: bookSeries)) {
                                    HStack {
                                        Text(bookSeries.name)
                                        Text("[\(bookSeries.books.count) books]")
                                        Spacer()
                                        if bookSeries.isCompleted {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: deleteSeries)
                        }
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
            }
        }
    }
    
    private func addNewSeries() {
        let newSeries = Series(name: newSeriesName)
        modelContext.insert(newSeries)
        newSeriesName = ""
    }
    
    private func deleteSeries(at offsets: IndexSet) {
        for index in offsets {
            let seriesItem = series[index]
            modelContext.delete(seriesItem)
        }
    }
    
}

#Preview("Empty") {
    SeriesListView()
}

#Preview("With Data") {
    let preview = Preview([Series.self])
    for _ in 0..<10 {
        let series = Series.randomSeries()
        preview.add(items: [series])
    }

    return SeriesListView().modelContainer(preview.container)
}
