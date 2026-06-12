//
//  ReadingBook.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation

struct ReadingBook: Identifiable, Equatable, Codable {
    var id = UUID()
    var title: String
    var author: String
    var totalPages: Int
    var currentPage: Int
    var seed: Int
    var logs: [ReadingLog] = []

    var percent: Int { totalPages > 0 ? Int(Double(currentPage) / Double(totalPages) * 100) : 0 }
    var progress: Double { totalPages > 0 ? Double(currentPage) / Double(totalPages) : 0 }
}
