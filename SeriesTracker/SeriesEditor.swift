//
//  SeriesEditor.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/18/24.
//

import SwiftUI

struct SeriesEditor: View {
    var series: Series?
    
    private var editorMode: String {
        series == nil ? "Add " : "Update "
    }
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var authorName = ""
    
    var body: some View {
        VStack {
            TextField("Name", text: $name)
            //TextField("Author", text: $authorName)
            Button(action: save) {
                Text("\(editorMode) Series")
            }
        }
        .onAppear {
            if let series {
                name = series.name
               // authorName = series.author!.name
            }
        }
        
    }
    
    func save() {
        print("save it")
    }
}

#Preview("Add Series") {
    SeriesEditor(series: nil)
}

#Preview("Edit Series") {
    SeriesEditor(series: Series.randomSeries())
}
