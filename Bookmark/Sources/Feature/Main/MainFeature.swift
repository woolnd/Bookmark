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
        case tabSelected(Tab)
        case home(HomeFeature.Action)
        case search(SearchFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.search, action: \.search) {
            SearchFeature()
        }
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
                
            case .home(.goToSearchTapped):
                state.selectedTab = .search
                return .none
                
            case .home(.goToFriendsTapped):
                state.selectedTab = .friends
                return .none
                
            default:
                return .none
            }
        }
    }
}
