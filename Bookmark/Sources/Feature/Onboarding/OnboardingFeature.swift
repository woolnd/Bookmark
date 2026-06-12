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
    enum State: Equatable {
        case splash(SplashFeature.State = .init())
        case appIntro(AppIntroFeature.State = .init())
        case login(LoginFeature.State = .init())
        case nickname(NicknameFeature.State)
    }
    
    enum Action {
        case splash(SplashFeature.Action)
        case appIntro(AppIntroFeature.Action)
        case login(LoginFeature.Action)
        case nickname(NicknameFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce{ state, action in
            switch action {
            case .splash(.finished):
                state = .appIntro()
                return .none
                
            case .appIntro(.startTapped):
                state = .login()
                return .none
                
            case .login(.loginSucceeded(let uid)):
                state = .nickname(NicknameFeature.State(uid: uid))
                return .none
                
            case .nickname(.saveCompleted(.success)):
                return .none
                
            default:
                return .none
            }
        }
        .ifCaseLet(\.splash, action: \.splash) { SplashFeature() }
        .ifCaseLet(\.appIntro, action: \.appIntro) { AppIntroFeature() }
        .ifCaseLet(\.login, action: \.login) { LoginFeature() }
        .ifCaseLet(\.nickname, action: \.nickname) { NicknameFeature() }
    }
}
