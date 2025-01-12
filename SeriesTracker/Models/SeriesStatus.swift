//
//  SeriesStatus.swift
//  SeriesTracker
//
//  Created by Morgan Jones on 1/11/25.
//


import SwiftUI

enum SeriesStatus: String, Codable, CaseIterable {
    case notASeries = "Not a series"
    case inProgress = "In Progress"
    case completed = "Completed"
    case abandoned = "Abandoned"
    case waitingForNextBook = "Waiting For Next Book"
    case needsInvestigation = "Needs Investigation"
    case inactive = "Inactive"
    case undetermined = "Undetermined"

    func statusIcon() -> String {
        switch self {
        case .notASeries: return "circle.slash"
        case .inProgress: return "circle.lefthalf.filled"
        case .completed: return "checkmark.circle.fill"
        case .abandoned: return "xmark.circle.fill"
        case .waitingForNextBook: return "circle.lefthalf.filled"
        case .needsInvestigation: return "questionmark.circle.lefthalf.filled"
        case .inactive: return "circle.fill"
        case .undetermined: return "questionmark.triangle.fill"
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
        }
    }
}

