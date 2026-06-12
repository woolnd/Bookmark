//
//  FinishedBook.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation

struct FinishedBook: Identifiable, Equatable, Codable {
    var id = UUID()
    var title: String
    var author: String
    var totalPages: Int
    var seed: Int
    var rating: Int = 0
    var review: String = ""
    var hidden: Bool = false
    var logs: [ReadingLog] = []
}
