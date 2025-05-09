//
//  SeriesSearchView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/19/24.
//

import SwiftUI

struct SeriesSearchView: View {
    @State private var seriesName = ""
    @State private var authorName = ""
    @State private var isSearching = false
    @State private var showResults = false
    
    var body: some View {
        VStack {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Series Search")
                        .font(.largeTitle)
                        .padding(.top)
                    
                    VStack(spacing: 15) {
                        TextField("Series Name", text: $seriesName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        TextField("Author Name", text: $authorName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button(action: {
                            showResults = true
                        }) {
                            Text("Search *")
                                .foregroundColor(.white)
                                .frame(width: 200)
                                .padding()
                                .background(
                                    !seriesName.isEmpty && !authorName.isEmpty ?
                                    Color.blue : Color.gray
                                )
                                .cornerRadius(10)
                        }
                        .disabled(seriesName.isEmpty || authorName.isEmpty)
                    }
                    .padding()
                    .navigationDestination(isPresented: $showResults) {
                        SeriesResultsView(
                            seriesName: seriesName,
                            authorName: authorName
                        )
                    }
                    
                    Spacer()
                }
                .navigationBarHidden(true)
            }
            Spacer()
            Text("* This app uses the Google Books API and may not be complete or accurate.")
                .padding(.horizontal)
        }
    }
}

#Preview {
    SeriesSearchView()
}

