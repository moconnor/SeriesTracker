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
                Text("\(books.count) books found for \(seriesName)")
                List {
                    ForEach(books, id: \.title) { book in
                        BookRowView(bookInfo: book)
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
    
    private func getCommonWords(seriesName: String, textSnippet: String) -> [String] {
        // Split the strings into words (based on whitespace and punctuation)
        let seriesNameWords = Set(seriesName.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })
        let textSnippetWords = Set(textSnippet.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })

        // Find common words
        let commonWords = seriesNameWords.intersection(textSnippetWords)
        return Array(commonWords)
    }
    
    private func isContainedInSnippet(_ candidate: String, _ snippet: String) -> Bool {
        
        let candidateWords = Set(candidate.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }).filter { $0.count > 2}
        let snippetWords = Set(snippet.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })

        // Find common words
        let commonWords = candidateWords.intersection(snippetWords)

        return commonWords.count >= candidateWords.count
    }
    
    private func searchBooks() async {
        isLoading = true
        error = nil
        
        do {
            let encodedSeries = seriesName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let encodedAuthor = authorName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            //let urlString = "https://www.googleapis.com/books/v1/volumes?q=intitle:\(encodedSeries)+inauthor:\(encodedAuthor)&maxResults=40"
            //let query = "\(seriesName) in title+inauthor:\(authorName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let query = "inauthor:\(authorName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

            let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(query)&maxResults=40"
            
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let jsonstring = String(data: data, encoding: .utf8) ?? ""
            print(jsonstring)
            let result = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
            //books = result.items.map { $0.volumeInfo }
            
            /// Tweaking this filter... I was getting false positives because the search criteria words were showing up in every entry's info and previewLinks, even if they didn't show up anywhere else
            /// based on a sample of one Series, I changed to series matching to title, description or searchInfo.
            
            let filteredBooks = result.items.filter { item in
                let book = item.volumeInfo
                let searchInfo = item.searchInfo
                let matchesTitleSeries = book.title.localizedCaseInsensitiveContains(seriesName)
                //let matchesDescription = book.description?.localizedCaseInsensitiveContains(seriesName) ?? false
                let matchesDescription = isContainedInSnippet(seriesName, book.description ?? "")
                //let matchesSearchInfo = searchInfo?.textSnippet?.localizedCaseInsensitiveContains(seriesName) ?? false
                let matchesSearchInfo = isContainedInSnippet(seriesName, searchInfo?.textSnippet?.description ?? "")
                let matchesAuthor = book.authors?.contains { $0.localizedCaseInsensitiveContains(authorName) } ?? false
                return (matchesTitleSeries || matchesDescription || matchesSearchInfo ) && matchesAuthor
            }.map { $0.volumeInfo }
            books = filteredBooks
            
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

