//
//  SearchCache.swift
//  Bookmark
//
//  Created by wodnd on 6/17/26.
//

import Foundation

/// 검색어 → 검색 결과를 캐싱하여 동일 검색어 재요청 시 API 호출을 스킵하고,
/// Trie를 통해 접두사 기반 자동완성 후보를 제공한다.
/// 검색 결과는 FileManager(JSON)로 영속화하여 앱 재시작 후에도 캐시 히트가 가능하다.
actor SearchCache {

    private var resultsByQuery: [String: [KakaoBookResult]] = [:]
    private let trie = Trie()
    private let cacheDirectory: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documents.appendingPathComponent("search_cache")
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    /// 앱 시작 시 캐시 폴더의 파일 이름으로 Trie 복원
    func restore() {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: cacheDirectory.path) else { return }
        for file in files {
            // NFD → NFC로 정규화해서 Trie에 삽입
            let query = file
                .replacingOccurrences(of: ".json", with: "")
                .precomposedStringWithCanonicalMapping  // NFD → NFC 변환
            trie.insert(query)
        }
    }

    /// 정확히 일치하는 검색어의 캐시된 결과를 반환.
    /// 메모리에 없으면 디스크에서 읽어옴.
    func cachedResults(for query: String) -> [KakaoBookResult]? {
        let key = normalize(query)

        // 메모리 캐시 먼저 확인
        if let cached = resultsByQuery[key] {
            return cached
        }

        // 디스크에서 로드
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        guard let data = try? Data(contentsOf: fileURL),
              let results = try? JSONDecoder().decode([KakaoBookResult].self, from: data) else {
            return nil
        }

        // 메모리 캐시에도 올려둠
        resultsByQuery[key] = results
        return results
    }

    /// 검색 성공 결과를 메모리 + 디스크에 저장하고, Trie에 검색어를 등록한다.
    func store(query: String, results: [KakaoBookResult]) {
        let key = normalize(query)
        resultsByQuery[key] = results
        trie.insert(query)

        // 디스크에 JSON으로 저장
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        if let data = try? JSONEncoder().encode(results) {
            try? data.write(to: fileURL)
        }
    }

    /// 주어진 접두사로 시작하는 과거 검색어 후보를 반환 (자동완성용)
    func autocompleteCandidates(for prefix: String, limit: Int = 5) -> [String] {
        trie.words(withPrefix: prefix, limit: limit)
    }

    /// 캐시 전체 비우기 (메모리 + 디스크)
    func removeAll() {
        resultsByQuery.removeAll()
        trie.removeAll()
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    private func normalize(_ query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
