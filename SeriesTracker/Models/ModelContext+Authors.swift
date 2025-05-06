//
//  ModelContext+Authors.swift
//  SeriesTracker
//
//  Created by Morgan Jones on 5/4/25.
//

import SwiftData
import Foundation

extension ModelContext {
    func author(named name: String) -> Author {
        // specify the root type on the key path
        do {
            let descriptor = FetchDescriptor<Author> (predicate: #Predicate<Author> { $0.name == name })
            
            let existing: [Author] = try fetch(descriptor)
            if let first = existing.first { return first }
            let new = Author(name: name)
            insert(new)
            return new
        } catch {
            fatalError("Unable to fetch author \(name): \(error)")
        }
    }
}

extension Bundle {
    /// CFBundleShortVersionString
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    /// CFBundleVersion
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    /// e.g. "1.2.3 (45)"
    var versionNumberString: String {
        "\(appVersion)"
    }
}
