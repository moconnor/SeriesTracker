//
//  SeriesSampleData.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation
import SwiftData

extension Series {
    static let seriesNames: [String] = [
        "Abstract",
        "Balanced",
        "Cascade",
        "Diamond",
        "Elegant",
        "Fountain",
        "Gateway",
        "Harmony",
        "Inspire",
        "Journey",
        "Kingdom",
        "Liberty",
        "Mansion",
        "Natural",
        "Pattern",
        "Quality",
        "Rainbow",
        "Silence",
        "Triumph",
        "Vibrant",
        "Whisper"
    ]
    
    static func randomStatus() -> ReadStatus {
        let randomIndex = Int.random(in: 0..<ReadStatus.allCases.count)
        return ReadStatus.allCases[randomIndex]
    }
    
    static func randomSeriesTitles() -> String {
        let randomIndex = Int.random(in: 0..<seriesNames.count)
        let word = seriesNames[randomIndex]
        return word.capitalized + " Series"
    }
    
    static func randomSeries(withBooks: Bool = true) -> Series {
        let series = Series(name: randomSeriesTitles(), author: Author.randomAuthor())
        if withBooks {
            for _ in 0..<Int.random(in: 1..<5) {
                series.books.append(Book.randomBook(author: series.author))
            }
        }
        return series
    }
    
    static func sampleSeries() -> ModelContainer {
        var sampleTestSeries: [Series] = []
        sampleTestSeries.append(randomSeries())
        
        for _ in 0..<Int.random(in: 0..<seriesNames.count) {
            let sample = randomSeries()
            if sampleTestSeries.contains(where: {$0.name == sample.name}) {
                continue
            }
            sampleTestSeries.append(sample)
        }
        let preview = Preview([Series.self , Book.self, Author.self])
        preview.add(items: sampleTestSeries)
        return preview.container
    }
    
    static func sampleDB() -> ModelContainer {
        var bookSeries: [Series] = []
        let preview = Preview([Author.self, Book.self, Series.self])
        let seriesCount = Int.random(in: 0..<seriesNames.count)
        for _ in 0..<seriesCount {
            bookSeries.append(randomSeries())
        }
        preview.add(items: bookSeries)
        return preview.container
    }

}
