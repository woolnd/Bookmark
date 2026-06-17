//
//  LoginFeature.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/12/26.
//


import Foundation
import ComposableArchitecture
import AuthenticationServices
import FirebaseFirestore

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
        case userCheckResponse(uid: String, hasNickname: Bool)
        case loginSucceeded(uid: String, hasNickname: Bool)
        case toastDismissed
    }

    enum LoginError: Error, Equatable {
        case unknown
        case cancelled
        case timeout
        case networkError
    }

    @Dependency(\.userClient) var userClient

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

            case .appleLoginCompleted(.success(let uid)):
                // 로그인 성공 → 닉네임 존재 여부 확인
                return .run { send in
                    do {
                        let hasNickname = try await withTimeout(seconds: 10) {
                            try await userClient.hasNickname(uid)
                        }
                        await send(.userCheckResponse(uid: uid, hasNickname: hasNickname))
                    } catch {
                        // 확인 실패해도 일단 닉네임 입력으로 보내는 게 안전
                        await send(.userCheckResponse(uid: uid, hasNickname: false))
                    }
                }

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

            case .userCheckResponse(let uid, let hasNickname):
                state.isLoading = false
                return .send(.loginSucceeded(uid: uid, hasNickname: hasNickname))

            case .loginSucceeded:
                return .none

            case .toastDismissed:
                state.toastMessage = nil
                return .none
            }
        }
    }
}
