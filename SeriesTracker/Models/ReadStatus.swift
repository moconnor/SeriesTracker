//
//  ReadStatus.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/19/24.
//


import SwiftUI

enum ReadStatus: String, Codable, CaseIterable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
    case abandoned = "Abandoned"
    case waitingForNextBook = "Waiting For Next Book"
    
    func statusIcon() -> String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .completed: return "checkmark.circle.fill"
        case .abandoned: return "xmark.circle.fill"
        case .waitingForNextBook: return "circle.lefthalf.filled"
        }
    }
    
    func statusColor() -> Color {
        switch self {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .abandoned: return .red
        case .waitingForNextBook: return .yellow
        }
    }
}
