//
//  SeriesTrackerApp.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import SwiftUI

@main
struct SeriesTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
