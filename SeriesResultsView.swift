//
//  SeriesResultsView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/19/24.
//

import SwiftUI

struct SeriesResultsView: View {
    let seriesName: String
    let authorName: String
    
    @State private var books: [BookInfo] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Searching for books...")
            } else {
                List {
                    ForEach(books, id: \.title) { book in
                        BookRowView(book: book)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Results")
        .task {
            await searchBooks()
        }
        .alert("Error", isPresented: .constant(error != nil)) {
            Button("OK") {
                error = nil
            }
        } message: {
            Text(error?.localizedDescription ?? "Unknown error")
        }
    }
    
    private func searchBooks() async {
        isLoading = true
        error = nil
        
        do {
            let encodedSeries = seriesName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let encodedAuthor = authorName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            let urlString = "https://www.googleapis.com/books/v1/volumes?q=intitle:\(encodedSeries)+inauthor:\(encodedAuthor)&maxResults=40"
            
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let result = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
            books = result.items.map { $0.volumeInfo }
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}

//#Preview {
//    SeriesResultsView()
//}

