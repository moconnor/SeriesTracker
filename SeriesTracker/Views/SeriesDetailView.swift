//
//  SeriesDetailView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import SwiftUI
import SwiftData

struct SeriesDetailView: View {
    @Bindable var series: Series
    @Environment(\.modelContext) private var modelContext
    
    @State private var newBookTitle = ""
    @State private var newBookOrder = 1
    @State private var addingNewBook = false
    @State private var editSeries: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                
                Text(series.name + " Details")
                    .font(.title)
                    .bold()
                Text("Status: " + series.readStatus().rawValue)
                    .font(.headline)
                
                Divider()
                Section(header: Text("Author")
                    .font(.headline)) {
                        HStack {
                            Text(series.author.name)
                                .font(.headline)
                        }
                        .padding(.horizontal)
                    }
                Divider()
                
                BookListView(series: series)
                
                Divider()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editSeries = true
                    } label: {
                        Image(systemName: "pencil")
                            .imageScale(.large)
                    }
                }
            }
            .padding()
            .sheet(isPresented: $editSeries) {
                SeriesEditorView(series: series)
            }
        }
        
    }
}

#Preview("No Books") {
    let author = Author(name: "Anonymous")
    let series = Series(name: "Empty Series", author: author)
    SeriesDetailView(series: series)
}

#Preview("With Books") {
    let series = Series.randomSeries()
    SeriesDetailView(series: series)
}
