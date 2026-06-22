//
//  Book.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation

struct KakaoBookSearchResponse: Decodable {
    let documents: [KakaoBookResult]
}

struct KakaoBookResult: Codable, Equatable, Identifiable {
    let title: String
    let authors: [String]
    let isbn: String
    let thumbnail: String
    let publisher: String
    let contents: String
    let url: String
    let datetime: String
    let translators: [String]
    
    var id: String { isbn13 ?? isbn }
    var isbn13: String? {
        isbn.split(separator: " ").first{ $0.count == 13 }.map(String.init)
    }
    var author: String { authors.first ?? "" }
    
    /// "YYYY-MM-DD" 형태로 변환한 출판일 (실패 시 nil)
    var publishedDate: String? {
        guard datetime.count >= 10 else { return nil }
        return String(datetime.prefix(10))
    }
    
    enum CodingKeys: String, CodingKey {
        case title, authors, isbn, thumbnail, publisher, contents, url, datetime, translators
    }
}
