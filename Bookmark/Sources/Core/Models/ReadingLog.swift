//
//  ReadingLog.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

// ReadingLog.swift
// 책갈피 — 한 줄 기록
import Foundation

struct ReadingLog: Identifiable, Equatable, Codable {
    var id = UUID()
    var date: String      // 표시용 날짜 문자열 (실서비스: Date)
    var page: Int
    var note: String
}
