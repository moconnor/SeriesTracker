//
//  BookInfoSampleData.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/20/24.
//

import Foundation

extension BookInfo {
    static func loadSampleData() -> [BookInfo] {
        var books: [BookInfo] = []
        
        if let path = Bundle.main.path(forResource: "SearchSample", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let result = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
                books = result.items.map { $0.volumeInfo }
            } catch {
                print(error)
            }
        } else {
            print("file not found")
        }
        return books

    }
}
