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
        var toastMessage: String? = nil
    }

    enum Action: Equatable {
        case appleLoginTapped
        case appleLoginCompleted(Result<String, LoginError>)
        case loginSucceeded(uid: String)
        case toastDismissed
    }

    enum LoginError: Error, Equatable {
        case unknown
        case cancelled
        case timeout
        case networkError
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appleLoginTapped:
                guard NetworkMonitor.shared.isConnected else {
                    state.toastMessage = "네트워크 연결을 확인해주세요"
                    return .none
                }
                state.isLoading = true
                return .none

            case .appleLoginCompleted(.success):
                state.isLoading = false
                return .none

            case .appleLoginCompleted(.failure(let error)):
                state.isLoading = false
                switch error {
                case .cancelled:
                    return .none
                case .timeout:
                    state.toastMessage = "요청 시간이 초과됐어요. 다시 시도해주세요"
                    return .none
                case .networkError:
                    state.toastMessage = "네트워크 연결을 확인해주세요"
                    return .none
                case .unknown:
                    state.toastMessage = "로그인에 실패했어요. 다시 시도해주세요"
                    return .none
                }

            case .loginSucceeded(let uid):
                print("Firebase 로그인 성공 : \(uid)")
                state.isLoading = false
                return .none

            case .toastDismissed:
                state.toastMessage = nil
                return .none
            }
        }
    }
}
