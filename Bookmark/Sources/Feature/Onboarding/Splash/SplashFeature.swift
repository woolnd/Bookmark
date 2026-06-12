//
//  SplashFeature.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SplashFeature {
    @ObservableState
    struct State: Equatable {
        var isDrawn = false
    }
    
    enum Action {
        case onAppear
        case drawAnimationTriggered
        case finished
    }
    
    @Dependency(\.continuousClock) var clock
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    try await clock.sleep(for: .milliseconds(150))
                    await send(.drawAnimationTriggered)
                    try await clock.sleep(for: .seconds(2.2))
                    await send(.finished)
                }
                
            case .drawAnimationTriggered:
                state.isDrawn = true
                return .none
                
            case .finished:
                return .none
            }
        }
    }
}
