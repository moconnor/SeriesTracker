//
//  SeriesSampleData.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation

extension Series {
    static let samples: [Series] = [
        Series(name: "Series One", author: Author.randomAuthor()),
        Series(name: "Series Two", author: Author.randomAuthor()),
        Series(name: "Series Three", author: Author.randomAuthor()),
        Series(name: "Series Four", author: Author.randomAuthor()),
        Series(name: "Series Five", author: Author.randomAuthor()),
        Series(name: "Series Six", author: Author.randomAuthor()),
        Series(name: "Series Seven", author: Author.randomAuthor()),
        Series(name: "Series Eight", author: Author.randomAuthor()),
        Series(name: "Series Nine", author: Author.randomAuthor()),
        Series(name: "Series Ten", author: Author.randomAuthor()),
        Series(name: "Series Eleven", author: Author.randomAuthor()),
        Series(name: "Series Twelve", author: Author.randomAuthor()),
        Series(name: "Series Thirteen", author: Author.randomAuthor()),
        Series(name: "Series Fourteen", author: Author.randomAuthor()),
        Series(name: "Series Fifteen", author: Author.randomAuthor()),
        Series(name: "Series Sixteen", author: Author.randomAuthor()),
        Series(name: "Series Seventeen", author: Author.randomAuthor()),
        Series(name: "Series Eighteen", author: Author.randomAuthor()),
        Series(name: "Series Nineteen", author: Author.randomAuthor()),
        Series(name: "Series Twenty", author: Author.randomAuthor()),
        Series(name: "Series Twenty One", author: Author.randomAuthor())
    ]
    
    static func randomSeries() -> Series {
        let randomIndex = Int.random(in: 0..<Series.samples.count)
        let series = Series.samples[randomIndex]
        for _ in 0..<Int.random(in: 1..<5) {
            series.books.append(Book.randomBook(series: series))
        }
        return series
    }
}
