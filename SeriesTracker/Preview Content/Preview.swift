//
//  Preview.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation
import SwiftData

struct Preview {
    let container: ModelContainer!
    
    init(_ types: [any PersistentModel.Type]) {
        let schema = Schema(types)
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        self.container = try! ModelContainer(for: schema, configurations: [config])
    }
    
    func add(items: [any PersistentModel]) {
        Task {  @MainActor in
            items.forEach {
                container.mainContext.insert($0)
            }
        }
    }
}
