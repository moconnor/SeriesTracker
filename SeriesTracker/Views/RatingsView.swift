//
//  RatingsView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/27/24.
//  Based on example from Paul Hudson

import SwiftUI

struct RatingsView: View {
    var book: Book
    var maxRating: Int = 5
    var offColor: Color = .gray
    var onColor: Color = .yellow
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Text("Rating:")
            ForEach(1..<maxRating + 1, id: \.self) { number in
                Button {
                    book.rating = number
                } label: {
                    Image(systemName: "star.fill")
                        .foregroundColor(number > book.rating ?? 0 ? offColor : onColor)
                }
                .buttonStyle(.plain)
            }
            .onChange(of: book.rating) {
                do {
                    try modelContext.save()
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    let book = Book.randomBook()
    RatingsView(book: book)
}
