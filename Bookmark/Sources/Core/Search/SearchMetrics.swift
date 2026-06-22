//
//  SearchMetrics.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/17/26.
//

import Foundation

/// 캐시 히트율, API 호출 횟수, 응답 시간을 추적하여
/// Trie 기반 캐싱의 실제 효과를 정량적으로 측정한다.
actor SearchMetrics {
    static let shared = SearchMetrics()

    private var cacheHitCount = 0
    private var apiCallCount = 0
    private var cacheResponseTimesMs: [Double] = []
    private var apiResponseTimesMs: [Double] = []

    func recordCacheHit(elapsedMs: Double) {
        cacheHitCount += 1
        cacheResponseTimesMs.append(elapsedMs)
    }

    func recordApiCall(elapsedMs: Double) {
        apiCallCount += 1
        apiResponseTimesMs.append(elapsedMs)
    }

    func reset() {
        cacheHitCount = 0
        apiCallCount = 0
        cacheResponseTimesMs.removeAll()
        apiResponseTimesMs.removeAll()
    }

    var summary: Summary {
        let total = cacheHitCount + apiCallCount
        let hitRate = total > 0 ? Double(cacheHitCount) / Double(total) * 100 : 0
        return Summary(
            cacheHits: cacheHitCount,
            apiCalls: apiCallCount,
            cacheHitRate: hitRate,
            avgCacheResponseMs: average(cacheResponseTimesMs),
            avgApiResponseMs: average(apiResponseTimesMs)
        )
    }

    private func average(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    struct Summary: Sendable {
        var cacheHits: Int
        var apiCalls: Int
        var cacheHitRate: Double
        var avgCacheResponseMs: Double
        var avgApiResponseMs: Double
    }
}
