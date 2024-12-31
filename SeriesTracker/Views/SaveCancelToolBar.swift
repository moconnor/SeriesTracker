//
//  SaveCancelToolBar.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/30/24.
//

// Thought this would be a good way to keep the Save/Cancel toolbar common
// but can't get dismiss to work. May be impossible
//
import SwiftUI

struct SaveCancelToolBar: ToolbarContent {
   @Environment(\.dismiss) var dismiss
  //  @Environment(\.navigationPath) private var navigationPath // ???
    @Binding var navigationPath: NavigationPath

    var buttonName: String
    var saveAction: () -> Void
    var fields: [String: String]
    
    private var hasEmptyFields: Bool {
        fields.values.contains(where: { $0.isEmpty })
    }
    
    var body: some ToolbarContent {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    print("want to cancel")
                    navigationPath.removeLast() // Use this instead of dismiss()

                   dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(buttonName) {
                    saveAction()
                }
                .buttonStyle(.borderedProminent)
                .tint(hasEmptyFields ? .gray : .green)
                .disabled(hasEmptyFields)
            }
    }
}

#Preview {

//    var saveMe: () -> Void { }
//    SaveCancelToolBar(buttonName: "Save Me", saveAction: saveMe, fields: [:])
}
