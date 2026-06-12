//
//  AladinBookInfo.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation

struct AladinLookupResponse: Decodable {
    let item: [AladinBookInfo]
}

struct AladinBookInfo: Decodable, Equatable {
    let isbn13: String
    let subInfo: AladinSubInfo?
    
    var totalPages: Int { subInfo?.itemPage ?? 0 }
}

struct AladinSubInfo: Decodable, Equatable {
    let itemPage: Int?
}
