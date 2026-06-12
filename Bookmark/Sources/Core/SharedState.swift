//
//  SharedState.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation
import ComposableArchitecture

// MARK: - 온보딩 / 계정
extension SharedReaderKey where Self == AppStorageKey<Bool>.Default {
    static var isOnboared: Self {
        Self[.appStorage("bk_onboarded"), default: false]
    }
}

extension SharedReaderKey where Self == AppStorageKey<String>.Default {
    static var nickname: Self {
        Self[.appStorage("bk_nickname"), default: ""]
    }
}

// MARK: - 설정
extension SharedReaderKey where Self == AppStorageKey<AppSettings>.Default {
    static var settings: Self {
        Self[.appStorage("app_settings"), default: AppSettings()]
    }
}

// MARK: - 책/친구 데이터 (파일 저장)
extension SharedReaderKey where Self == FileStorageKey<IdentifiedArrayOf<Book>>.Default {
    static var books: Self {
        Self[.fileStorage(.documentsDirectory.appending(path: "books.json")), default: []]
    }
}

extension SharedReaderKey where Self == FileStorageKey<IdentifiedArrayOf<FinishedBook>>.Default {
    static var myFinished: Self {
        Self[.fileStorage(.documentsDirectory.appending(path: "finished_books.json")), default: []]
    }
}

extension SharedReaderKey where Self == FileStorageKey<IdentifiedArrayOf<Friend>>.Default {
    static var friends: Self {
        Self[.fileStorage(.documentsDirectory.appending(path: "friends.json")), default: []]
    }
}
