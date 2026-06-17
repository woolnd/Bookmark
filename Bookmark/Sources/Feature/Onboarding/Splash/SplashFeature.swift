//
//  SplashFeature.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import ComposableArchitecture

@Reducer
struct SplashFeature {
    @ObservableState
    struct State: Equatable {
        var isVisible = false
    }
    
    enum Action {
        case onAppear
        case fadeInTriggered
        case tapped
        case finished(isLoggedIn: Bool)
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.authClient) var authClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    try await clock.sleep(for: .milliseconds(150))
                    await send(.fadeInTriggered)
                    try await clock.sleep(for: .seconds(2.2))
                    let isLoggedIn = authClient.currentUserId() != nil
                    await send(.finished(isLoggedIn: isLoggedIn))
                }
            case .fadeInTriggered:
                state.isVisible = true
                return .none
            case .tapped:
                let isLoggedIn = authClient.currentUserId() != nil
                return .send(.finished(isLoggedIn: isLoggedIn))
            case .finished:
                return .none
            }
        }
    }
}
