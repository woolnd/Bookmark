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
    }
    
    @Dependency(\.bookStoreClient) var bookStoreClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.search, action: \.search) {
            SearchFeature()
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
                
            case .search(.bookAdded(let book)):
                state.home.books.append(book)
                state.search.addedBookIds.insert(book.id)
                let uid = state.uid
                return .run { _ in
                    try await bookStoreClient.saveBook(uid, book)
                }
                
            default:
                return .none
            }
        }
    }
}
