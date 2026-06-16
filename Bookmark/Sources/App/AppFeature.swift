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
        case main(MainFeature.State = .init())
    }
    enum Action {
        case onboarding(OnboardingFeature.Action)
        case main(MainFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onboarding(.nickname(.saveCompleted(.success))):
                state = .main()
                return .none
                
            default:
                return .none
            }
            
        }
        .ifCaseLet(\.onboarding, action: \.onboarding) { OnboardingFeature() }
        .ifCaseLet(\.main, action: \.main) { MainFeature() }
    }
}
