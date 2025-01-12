//
//  SeriesStatus.swift
//  SeriesTracker
//
//  Created by Morgan Jones on 1/11/25.
//


import SwiftUI

enum SeriesStatus: String, Codable, CaseIterable {
    case everything = "Everything" // I'm not thrilled with this, but seems simpler than the obvious alternatives.
    case reading = "Reading"
    case inProgress = "In Progress"
    case completed = "Completed"
    case waitingForNextBook = "Waiting For Next Book"
    case inactive = "Inactive"
    case notASeries = "Not a series"
    case abandoned = "Abandoned"
    case needsInvestigation = "Needs Investigation"
    case undetermined = "Undetermined"

    func statusIcon() -> String {
        switch self {
        case .notASeries: return "notequal.square.fill"
        case .inProgress: return "progress.indicator"
        case .completed: return "checkmark.seal.fill"
        case .abandoned: return "xmark.circle.fill"
        case .waitingForNextBook: return "pause.circle.fill"
        case .needsInvestigation: return "rectangle.and.text.magnifyingglass"
        case .inactive: return "stop.circle.fill"
        case .undetermined: return "questionmark.diamond"
        case .reading: return "book.pages.fill"
        case .everything: return ""
        }
    }
    
    func statusColor() -> Color {
        switch self {
        case .notASeries: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .abandoned: return .red
        case .waitingForNextBook: return .yellow
        case .needsInvestigation: return .orange
        case .inactive: return .purple
        case .undetermined: return .yellow
        case .everything: return .red
        case .reading: return .blue

        }
    }
    
    func statusAbbreviation() -> String {
        switch self {
        case .notASeries: return "not"
        case .inProgress: return "prg"
        case .completed: return "cmp"
        case .abandoned: return "abnd"
        case .waitingForNextBook: return "wait"
        case .needsInvestigation: return "nvst"
        case .inactive: return "!act"
        case .undetermined: return "!det"
        case .everything: return "all"
        case .reading: return "read"

        }
    }
}

