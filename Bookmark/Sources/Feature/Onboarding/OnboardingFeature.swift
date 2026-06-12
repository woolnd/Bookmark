//
//  OnboardingFeature.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct OnboardingFeature {
    @ObservableState
    struct State: Equatable {
        var splash = SplashFeature.State()
    }

    enum Action {
        case splash(SplashFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.splash, action: \.splash) {
            SplashFeature()
        }
    }
}
