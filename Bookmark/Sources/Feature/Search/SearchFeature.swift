//
//  SearchFeature.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/16/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SearchFeature {
    @ObservableState
    struct State: Equatable {
        var query: String = ""
        var results: [KakaoBookResult] = []
        var isSearching: Bool = false
        var addedBookIds: Set<String> = []
        var errorMessage: String? = nil
        
        var selectedBook: KakaoBookResult? = nil
        var selectedBookPages: Int? = nil
        var isLoadingDetail: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case searchResponse(Result<[KakaoBookResult], Error>)
        case bookSelected(KakaoBookResult)
        case aladinResponse(Result<AladinBookInfo, Error>)
        case bookAdded(Book)
        case detailDismissed
    }
    
    enum CancelID { case search }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.kakaoBookClient) var kakaoBookClient
    @Dependency(\.aladinBookClient) var aladinBookClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.query):
                let query = state.query
                guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                    state.results = []
                    return .cancel(id: CancelID.search)
                }
                state.isSearching = true
                return .run { send in
                    try await clock.sleep(for: .milliseconds(300))
                    let result = await Result { try await kakaoBookClient.search(query) }
                    await send(.searchResponse(result))
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)
                
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
            }
        }
    }
}
