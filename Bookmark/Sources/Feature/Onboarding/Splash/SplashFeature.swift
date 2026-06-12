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
        case finished
    }

    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    try await clock.sleep(for: .milliseconds(150))
                    await send(.fadeInTriggered)
                    try await clock.sleep(for: .seconds(2.2))
                    await send(.finished)
                }
            case .fadeInTriggered:
                state.isVisible = true
                return .none
            case .finished:
                return .none
            }
        }
    }
}
