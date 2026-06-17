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
    enum State: Equatable {
        case onboarding(OnboardingFeature.State = .splash())
        case main(MainFeature.State)
    }

    enum Action {
        case onboarding(OnboardingFeature.Action)
        case main(MainFeature.Action)
    }

    @Dependency(\.authClient) var authClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onboarding(.splash(.finished(let isLoggedIn))):
                if isLoggedIn, let uid = authClient.currentUserId() {
                    state = .main(MainFeature.State(uid: uid))
                }
                return .none
                
            case .onboarding(.login(.loginSucceeded(let uid, let hasNickname))):
                if hasNickname {
                    state = .main(MainFeature.State(uid: uid))
                }
                return .none
                
            case .onboarding(.nickname(.saveCompleted(.success))):
                if let uid = authClient.currentUserId() {
                    state = .main(MainFeature.State(uid: uid))
                }
                return .none
                
            default:
                return .none
            }
        }
        .ifCaseLet(\.onboarding, action: \.onboarding) { OnboardingFeature() }
        .ifCaseLet(\.main, action: \.main) { MainFeature() }
    }
}
