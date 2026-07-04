//
//  MainFeature.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/16/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MainFeature {
    @ObservableState
    struct State: Equatable {
        var uid: String
        var selectedTab: Tab = .home
        var home: HomeFeature.State = .init()
        var search: SearchFeature.State = .init()
        var bookDetail: BookDetailFeature.State? = nil
    }
    
    enum Tab: Equatable {
        case home
        case search
        case friends
        case library
    }
    
    enum Action {
        case onAppear
        case booksLoaded([Book])
        case tabSelected(Tab)
        case home(HomeFeature.Action)
        case search(SearchFeature.Action)
        case bookDetail(BookDetailFeature.Action)
        case bookDetailDismissed
    }
    
    @Dependency(\.bookStoreClient) var bookStoreClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.search, action: \.search) {
            SearchFeature()
        }
        .ifLet(\.bookDetail, action: \.bookDetail) {
            BookDetailFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                let uid = state.uid
                return .run { send in
                    let books = try await bookStoreClient.fetchBooks(uid)
                    await send(.booksLoaded(books))
                }
                
            case .booksLoaded(let books):
                state.home.books = books
                state.search.addedBookIds = Set(books.map(\.id))
                return .none
                
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
                
            case .home(.goToSearchTapped):
                state.selectedTab = .search
                return .none
                
            case .home(.goToFriendsTapped):
                state.selectedTab = .friends
                return .none
                
            case .home(.bookCardTapped(let book)):
                state.bookDetail = BookDetailFeature.State(book: book)
                return .none

            case .search(.bookAdded(let book)):
                var updatedBook = book
                updatedBook.uid = state.uid
                state.home.books.append(updatedBook)
                state.search.addedBookIds.insert(updatedBook.id)
                let uid = state.uid
                let bookToSave = updatedBook
                return .run { _ in
                    try await bookStoreClient.saveBook(uid, bookToSave)
                }

            case .bookDetail(.pageUpdated(let book)):
                if let index = state.home.books.firstIndex(where: { $0.id == book.id }) {
                    state.home.books[index] = book
                }
                return .none

            case .bookDetail(.bookFinished(let book)):
                // 홈 읽는 중에서 제거
                state.home.books.removeAll { $0.id == book.id }
                state.search.addedBookIds.remove(book.id)
                // BookDetail dismiss
                state.bookDetail = nil
                // Firestore에서 읽는 중 목록 삭제
                let uid = state.uid
                let bookId = book.id
                return .run { _ in
                    try await bookStoreClient.deleteBook(uid, bookId)
                }

            case .bookDetail(.dismiss):
                state.bookDetail = nil
                return .none

            case .bookDetailDismissed:
                state.bookDetail = nil
                return .none
                
            default:
                return .none
            }
        }
    }
}
