//
//  Models.swift
//  BookSeries
//
//  Created by Michael O'Connor using Claude on 12/19/24.
//

import Foundation
import SwiftUI

struct GoogleBooksResponse: Codable {
    let items: [ItemInfo]
}

struct ItemInfo:  Codable {
    let searchInfo: SearchInfo?
    let volumeInfo: BookInfo
}

//struct VolumeInfo: Codable {
//    let volumeInfo: BookInfo
//}

struct SearchInfo: Codable {
    let textSnippet: String?
}

struct BookInfo: Codable {
    let title: String
    let authors: [String]?
    let publishedDate: String?
    let description: String?
    let seriesInfo: SeriesInfo?
    let imageLinks: ImageLinks?
    
    private enum CodingKeys: String, CodingKey {
        case title, authors, publishedDate, description, seriesInfo, imageLinks
    }
}

struct SeriesInfo: Codable {
    let bookDisplayNumber: String?
    let volumeNumber: Double?
}

struct ImageLinks: Codable {
    let thumbnail: String?
}
