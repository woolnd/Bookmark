//
//  Friend.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation

struct Friend: Identifiable, Equatable, Codable {
    var id: String
    var name: String
    var initial: String
    var code: String
    var when: String
    var note: String
    var reading: [ReadingBook]
    var finished: [FinishedBook]

    var latestBook: ReadingBook? { reading.first }
    var feedTitle: String { latestBook?.title ?? "—" }
    var feedPercent: Int { latestBook?.percent ?? 0 }
    var feedProgress: Double { latestBook?.progress ?? 0 }
}
