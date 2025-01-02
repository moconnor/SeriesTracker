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
            }
            Tab("Search", systemImage: "magnifyingglass") {
                SeriesSearchView()
            }
        }
    }
}

#Preview {
    let preview = Preview([Series.self])
    for _ in 0..<Int.random(in: 1..<15) {
        let series = Series.randomSeries()
        preview.add(items: [series])
    }
    return ContentView().modelContainer(preview.container)
}
