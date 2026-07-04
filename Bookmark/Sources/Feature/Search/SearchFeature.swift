//
//  SearchFeature.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/16/26.
//

import Foundation
import ComposableArchitecture

private let searchCache = SearchCache()

@Reducer
struct SearchFeature {
    @ObservableState
    struct State: Equatable {
        var query: String = ""
        var results: [KakaoBookResult] = []
        var isSearching: Bool = false
        var addedBookIds: Set<String> = []
        var errorMessage: String? = nil
        var autocompleteCandidates: [String] = []
        
        var selectedBook: KakaoBookResult? = nil
        var selectedBookPages: Int? = nil
        var isLoadingDetail: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case searchSubmitted
        case searchResponse(Result<[KakaoBookResult], Error>)
        case autocompleteUpdated([String])
        case autocompleteSelected(String)
        case bookSelected(KakaoBookResult)
        case aladinResponse(Result<AladinBookInfo, Error>)
        case bookAdded(Book)
        case detailDismissed
        case cacheReset
    }
    
    enum CancelID { case search }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.kakaoBookClient) var kakaoBookClient
    @Dependency(\.aladinBookClient) var aladinBookClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { _ in
                    await searchCache.restore()
                }
                
            case .binding(\.query):
                let query = state.query
                
                guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                    state.results = []
                    state.autocompleteCandidates = []
                    return .cancel(id: CancelID.search)
                }
                
                return .run { send in
                    let candidates = await searchCache.autocompleteCandidates(for: query)
                    await send(.autocompleteUpdated(candidates))
                }
                
            case .searchSubmitted:
                let query = state.query
                
                guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return .none
                }
                
                state.isSearching = true
                state.autocompleteCandidates = []
                return .run { send in
                    let start = Date()
                    if let cached = await searchCache.cachedResults(for: query) {
                        let elapsed = Date().timeIntervalSince(start) * 1000
                        await SearchMetrics.shared.recordCacheHit(elapsedMs: elapsed)
                        await send(.searchResponse(.success(cached)))
                        return
                    }
                    
                    let apiStart = Date()
                    let result = await Result { try await kakaoBookClient.search(query) }
                    let apiElapsed = Date().timeIntervalSince(apiStart) * 1000
                    await SearchMetrics.shared.recordApiCall(elapsedMs: apiElapsed)
                    
                    if case .success(let results) = result {
                        await searchCache.store(query: query, results: results)
                    }
                    
                    await send(.searchResponse(result))
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)
                
            case .autocompleteUpdated(let candidates):
                state.autocompleteCandidates = candidates
                return .none
                
            case .autocompleteSelected(let candidate):
                state.query = candidate
                state.autocompleteCandidates = []
                state.isSearching = true
                return .run { send in
                    let start = Date()
                    if let cached = await searchCache.cachedResults(for: candidate) {
                        let elapsed = Date().timeIntervalSince(start) * 1000
                        await SearchMetrics.shared.recordCacheHit(elapsedMs: elapsed)
                        await send(.searchResponse(.success(cached)))
                        return
                    }
                    let apiStart = Date()
                    let result = await Result { try await kakaoBookClient.search(candidate) }
                    let apiElapsed = Date().timeIntervalSince(apiStart) * 1000
                    await SearchMetrics.shared.recordApiCall(elapsedMs: apiElapsed)
                    if case .success(let results) = result {
                        await searchCache.store(query: candidate, results: results)
                    }
                    await send(.searchResponse(result))
                }
                
            case .searchResponse(.success(let results)):
                state.isSearching = false
                state.results = results
                return .none
                
            case .searchResponse(.failure):
                state.isSearching = false
                state.errorMessage = "검색에 실패했어요"
                return .none
                
            case .bookSelected(let result):
                state.selectedBook = result
                state.selectedBookPages = nil
                
                guard let isbn13 = result.isbn13 else {
                    state.selectedBookPages = 0
                    return .none
                }
                
                state.isLoadingDetail = true
                return .run { send in
                    let response = await Result { try await aladinBookClient.lookup(isbn13) }
                    await send(.aladinResponse(response))
                }
                
            case .aladinResponse(.success(let info)):
                state.isLoadingDetail = false
                state.selectedBookPages = info.totalPages
                return .none
                
            case .aladinResponse(.failure):
                state.isLoadingDetail = false
                state.selectedBookPages = 0
                return .none

            // MainFeature에서 uid를 주입해서 bookAdded 처리
            case .bookAdded(let book):
                state.addedBookIds.insert(book.id)
                state.selectedBook = nil
                state.selectedBookPages = nil
                return .none
                
            case .detailDismissed:
                state.selectedBook = nil
                state.selectedBookPages = nil
                state.isLoadingDetail = false
                return .none
                
            case .binding:
                return .none
                
            case .cacheReset:
                return .run { _ in
                    await searchCache.removeAll()
                    await SearchMetrics.shared.reset()
                    print("🗑️ 캐시 초기화 완료")
                }
            }
        }
    }
}
