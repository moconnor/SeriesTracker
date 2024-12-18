//
//  AuthorSampleData.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/17/24.
//

import Foundation

extension Author {
    static let samples: [Author] = [
        Author(name: "Mary Ross"),
        Author(name: "Sophie Russell"),
        Author(name: "William Sanchez"),
        Author(name: "Lily Shaw"),
        Author(name: "Joshua Takahashi"),
        Author(name: "James Watanabe"),
        Author(name: "Grace Jenkins"),
        Author(name: "Michael Saito"),
        Author(name: "Brian Walker"),
        Author(name: "Robert Smith"),
        Author(name: "Jessica Lee"),
        Author(name: "Jessica Nicholson"),
        Author(name: "Ruby Jones"),
        Author(name: "Thomas Dawson"),
        Author(name: "Olivia Hughes"),
        Author(name: "Melissa Jones"),
        Author(name: "Stephanie Rodriguez"),
        Author(name: "Christopher Robinson"),
        Author(name: "Daniel Owen"),
        Author(name: "Heather Baker"),
        Author(name: "Michelle Cunningham"),
        Author(name: "William Cox"),
        Author(name: "Julie Fisher"),
        Author(name: "Oliver Harvey"),
        Author(name: "Emily Rogers"),
        Author(name: "Chloe Reid"),
        Author(name: "John Bradley"),
        Author(name: "Nicole Ali"),
        Author(name: "Ella Kaur"),
        Author(name: "Mark Taylor"),
        Author(name: "Alfie Fraser"),
        Author(name: "Amelia Stewart"),
        Author(name: "Steven Edwards"),
        Author(name: "Jason Hussain"),
        Author(name: "David Nakamura"),
        Author(name: "Laura Simpson"),
        Author(name: "James Dixon"),
        Author(name: "Matthew Cooper"),
        Author(name: "Joseph Rose"),
        Author(name: "Amy Brown"),
        Author(name: "Rebecca Fox"),
        Author(name: "Elizabeth Murphy"),
        Author(name: "Kevin McDonald"),
        Author(name: "Eric Johnston"),
        Author(name: "Kelly Wilson"),
        Author(name: "Jeffrey Williams"),
        Author(name: "Richard Yamamoto"),
        Author(name: "Scott Berry"),
        Author(name: "Thomas Wilson"),
        Author(name: "Jennifer Davies")
    ]
    
    static func randomAuthor() -> Author {
        let randomIndex = Int.random(in: 0..<Author.samples.count)
        return Author.samples[randomIndex]
    }
}
