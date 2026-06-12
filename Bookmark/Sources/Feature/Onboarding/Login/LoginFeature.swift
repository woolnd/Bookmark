//
//  LoginFeature.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/12/26.
//

import Foundation
import ComposableArchitecture
import AuthenticationServices

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
    }

    enum Action: Equatable {
        case appleLoginTapped
        case appleLoginCompleted(Result<String, LoginError>)
        case loginSucceeded(uid: String)
        case loginFailed
    }

    enum LoginError: Error, Equatable {
        case unknown
        case cancelled
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appleLoginTapped:
                state.isLoading = true
                return .none

            case .appleLoginCompleted(.success):
                state.isLoading = false
                return .none

            case .appleLoginCompleted(.failure):
                state.isLoading = false
                return .send(.loginFailed)

            case .loginSucceeded(let uid):
                print("Firebase 로그인 성공 : \(uid)")
                state.isLoading = false
                return .none

            case .loginFailed:
                state.isLoading = false
                return .none
            }
        }
    }
}
