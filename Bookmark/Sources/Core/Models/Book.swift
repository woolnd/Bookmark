//
//  Book.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation

struct Book: Identifiable, Equatable, Codable {
    var id: String
    var title: String
    var author: String
    var totalPages: Int
    var currentPage: Int
    var note: String
    var seed: Int
    var coverURL: String?
    var loggedToday: Bool = false
    var logs: [ReadingLog] = []
    
    var progress: Double { totalPages > 0 ? Double(currentPage) / Double(totalPages) : 0}
    var percent: Int { Int(progress * 100) }
    var isFinished: Bool { currentPage >= totalPages }
}

extension Book {
    init(kakao: KakaoBookResult, totalPages: Int) {
        self.id = kakao.id
        self.title = kakao.title
        self.author = kakao.author
        self.totalPages = totalPages
        self.currentPage = 0
        self.note = ""
        self.seed = kakao.id.hashValue
        self.coverURL = kakao.thumbnail
    }
}
