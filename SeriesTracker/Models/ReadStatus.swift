//
//  ReadStatus.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/19/24.
//


import SwiftUI

enum ReadStatus: String, Codable, CaseIterable {
    case notPurchased = "Not Purchased"
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
    case abandoned = "Abandoned"
    
    func statusIcon() -> String {
        switch self {
        case .notPurchased: return "dollarsign.ring.dashed"
        case .notStarted: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .completed: return "checkmark.circle.fill"
        case .abandoned: return "xmark.circle.fill"
        }
    }
    
    func statusColor() -> Color {
        switch self {
        case .notPurchased: return .teal
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .abandoned: return .red
        }
    }
}
