//
//  SearchCache.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/18/26.
//


import Foundation

/// 검색어 → 검색 결과를 캐싱하여 동일 검색어 재요청 시 API 호출을 스킵하고,
/// Trie를 통해 접두사 기반 자동완성 후보를 제공한다.
/// actor로 선언하여 Swift 6 Strict Concurrency 하에서 별도 락 없이 안전한 동시 접근을 보장한다.
actor SearchCache {

    private var resultsByQuery: [String: [KakaoBookResult]] = [:]
    private let trie = Trie()

    /// 정확히 일치하는 검색어의 캐시된 결과를 반환. 없으면 nil.
    func cachedResults(for query: String) -> [KakaoBookResult]? {
        resultsByQuery[normalize(query)]
    }

    /// 검색 성공 결과를 캐시에 저장하고, 검색어를 Trie에 등록한다.
    func store(query: String, results: [KakaoBookResult]) {
        resultsByQuery[normalize(query)] = results
        trie.insert(query)
    }

    /// 주어진 접두사로 시작하는 과거 검색어 후보를 반환 (자동완성용)
    func autocompleteCandidates(for prefix: String, limit: Int = 5) -> [String] {
        trie.words(withPrefix: prefix, limit: limit)
    }

    /// 캐시 전체 비우기 (테스트/디버그용)
    func removeAll() {
        resultsByQuery.removeAll()
        trie.removeAll()
    }

    private func normalize(_ query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
