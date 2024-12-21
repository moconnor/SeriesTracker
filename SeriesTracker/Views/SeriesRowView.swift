//
//  SeriesRowView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/21/24.
//

import SwiftUI

struct SeriesRowView: View {
    var series: Series
    
    var body: some View {
        HStack {
            Text(series.name)
            Text("[\(series.books.count) books]")
            Spacer()
            Image(systemName: series.readStatus().statusIcon())
                .foregroundColor(series.readStatus().statusColor())
        }
    }
}

#Preview {
    let series = Series.randomSeries()
    SeriesRowView(series: series)
        .padding(.horizontal)
}

