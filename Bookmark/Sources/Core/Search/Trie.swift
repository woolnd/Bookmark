//
//  Trie.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/17/26.
//

import Foundation
/// 검색어 자동완성을 위한 Trie 자료구조.
/// 카카오 책 검색 API 호출 비용 절감을 위해, 한 번 검색해서 받은 책 제목을
/// 로컬에 캐싱해두고 동일/유사 접두사 검색 시 API 호출 없이 후보를 제공한다.
final class Trie {
    
    private final class Node {
        var children: [Character: Node] = [:]
        var isEndOfWord = false
        /// 이 노드(접두사)로 끝나는 완성된 단어 — 자동완성 후보 추출 시 사용
        var word: String? = nil
    }
    
    private let root = Node()
    private(set) var wordCount = 0
    
    /// 단어를 Tire에 삽입한다. 이미 존재하면 아무 동작 없음.
    func insert(_ word: String) {
        let normalized = word.lowercased()
        guard !normalized.isEmpty else { return  }
        
        var current = root
        for char in normalized {
            if let next = current.children[char] {
                current = next
            } else {
                let newNode = Node()
                current.children[char] = newNode
                current = newNode
            }
        }
        
        if !current.isEndOfWord {
            wordCount += 1
        }
        
        current.isEndOfWord = true
        current.word = word
    }
    
    /// 정확히 일치하는 단어가 캐시에 있는지 확인
    func contains(_ word: String) -> Bool {
        guard let node = node(for: word.lowercased()) else { return false }
        return node.isEndOfWord
    }
    
    /// 주어진 접두사로 시작하는 캐시된 단어가 하나 이상 있는지 확인
    func hasPrefix(_ prefix: String) -> Bool {
        node(for: prefix.lowercased()) != nil
    }
    
    /// 주어진 접두사로 시작하는 단어들을 최대 limit개까지 반환 (자동완성 후보)
    func words(withPrefix prefix: String, limit: Int = 10) -> [String] {
        guard let startNode = node(for: prefix.lowercased()) else { return [] }
        var results: [String] = []
        collectWords(from: startNode, into: &results, limit: limit)
        return results
    }
    
    /// 캐시 전체 비우기
    func removeAll() {
        root.children.removeAll()
        wordCount = 0
    }
    
    // MARK: - Private
    private func node(for prefix: String) -> Node? {
        var current = root
        for char in prefix {
            guard let next = current.children[char] else { return nil }
            current = next
        }
        return current
    }
    
    private func collectWords(from node: Node, into results: inout [String], limit: Int) {
        guard results.count < limit else { return }
        if let word = node.word {
            results.append(word)
        }
        for child in node.children.values {
            guard results.count < limit else { return }
            collectWords(from: child, into: &results, limit: limit)
        }
    }
}
