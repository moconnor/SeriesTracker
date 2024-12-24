//
//  ContentView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/19/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "books.vertical.fill") {
                SeriesListView()
                    .modelContainer(for: [Series.self , Book.self, Author.self])
            }
            Tab("Search", systemImage: "magnifyingglass") {
                SeriesSearchView()
            }
        }
    }
}

#Preview {
    ContentView()
}