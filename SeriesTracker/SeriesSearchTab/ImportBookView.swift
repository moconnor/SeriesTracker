//
//  ImportBookView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/20/24.
//

// Almost totally rewritten by Claude 12/21/24

import SwiftUI
import SwiftData
struct ImportBookView: View {
    var book: Book
    @Query(sort: \Series.name) var series: [Series]
    @State var selectedSeries: Series?
    @State private var showingAddConfirmation = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        if !series.isEmpty {
            VStack(spacing: 20) {
                // Book Info Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Import: ")
                            .font(.title2)
                            .bold()
                        
                        Text(book.title)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
     
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Series Picker Section
                VStack(spacing: 12) {
                    Text("Select A Series:")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker("Series", selection: .init( // because we're using switdata values
                        get: { selectedSeries ?? series[0] },
                        set: { selectedSeries = $0 }
                    )) {
                        ForEach(series) { bookSeries in
                            Text(bookSeries.name)
                                .tag(bookSeries as Series)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 240)
                }
                .padding(.horizontal)
                
                if let bookSeries = selectedSeries {
                    Button(action: {
                        bookSeries.books.append(book)
                        try? modelContext.save()
                        showingAddConfirmation = true
                    }) {
                        Text("Add book to the \(bookSeries.name)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
            .padding(.top)
            .alert("Book Added", isPresented: $showingAddConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("\(book.title) has been added to the \(selectedSeries?.name ?? "")")
            }
            .onAppear {
                if selectedSeries == nil {
                    selectedSeries = series[0]
                }
            }
        } else {
            ContentUnavailableView("Please add a series", systemImage: "book.fill")
        }
    }
}

#Preview("Without Series") {
    ImportBookView(book: Book.randomBook())
}

#Preview("With Series") {
    let seriesDB = Series.sampleSeries()
    ImportBookView(book: Book.randomBook())
        .modelContainer(seriesDB)
}

