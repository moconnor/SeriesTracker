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
    
    static func randomSeries() -> Series {
        let series = Series(name: randomSeriesTitles(), author: Author.randomAuthor())
        series.status = randomStatus()
        for _ in 0..<Int.random(in: 0..<5) {
            series.books.append(Book.randomBook(author: series.author))
        }
        return series
    }
    
    static func sampleDB(preview: Preview, author: Author) -> ModelContainer {
        let preview = Preview([Author.self])
        return preview.container
    }

}
