//
//  ReadingLog.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation

struct ReadingLog: Identifiable, Equatable, Codable {
    var id: String = UUID().uuidString
    var bookId: String
    var date: Date = Date()
    var fromPage: Int
    var toPage: Int
    var memo: String
    var type: LogType
    
    enum LogType: String, Codable {
        case progress   // 진행 중 기록
        case finished   // 완독 소감
    }
    
    /// 표시용 날짜 문자열
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
