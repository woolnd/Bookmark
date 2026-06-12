//
//  AppFeature.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var onboarding = OnboardingFeature.State()
    }
    enum Action {
        case onboarding(OnboardingFeature.Action)
    }
    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
    }
}
