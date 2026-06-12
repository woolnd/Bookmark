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

struct KakaoBookResult: Decodable, Equatable, Identifiable {
    let title: String
    let authors: [String]
    let isbn: String
    let thumbnail: String
    let publisher: String
    
    var id: String { isbn13 ?? isbn }
    var isbn13: String? {
        isbn.split(separator: " ").first{ $0.count == 13 }.map(String.init)
    }
    var author: String { authors.first ?? "" }
    
    enum CodingKeys: String, CodingKey {
        case title, authors, isbn, thumbnail, publisher
    }
}
